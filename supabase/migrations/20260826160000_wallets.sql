-- Liquid wallets + ledger. Balance changes only via RPCs.

create table public.wallets (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  kind text not null check (kind in ('cash', 'bank', 'ewallet')),
  name text not null,
  balance_vnd numeric not null default 0,
  bank_name text,
  note text,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index wallets_home on public.wallets (home_id);

alter table public.wallets enable row level security;

create policy "wallets_member_all"
  on public.wallets for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

create table public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  wallet_id uuid not null references public.wallets (id) on delete cascade,
  kind text not null check (
    kind in ('adjust', 'expense', 'transfer_out', 'transfer_in')
  ),
  signed_amount numeric not null check (signed_amount <> 0),
  note text,
  expense_id uuid references public.expenses (id) on delete set null,
  transfer_group_id uuid,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

create index wallet_transactions_wallet_created
  on public.wallet_transactions (wallet_id, created_at desc);

create index wallet_transactions_expense
  on public.wallet_transactions (expense_id)
  where expense_id is not null;

alter table public.wallet_transactions enable row level security;

create policy "wallet_transactions_member_select"
  on public.wallet_transactions for select
  using (public.is_home_member(home_id));

-- Mutations only via RPCs (security definer).
create policy "wallet_transactions_no_direct_write"
  on public.wallet_transactions for insert
  with check (false);

alter table public.expenses
  add column if not exists wallet_id uuid references public.wallets (id)
    on delete set null;

create index if not exists expenses_wallet
  on public.expenses (wallet_id)
  where wallet_id is not null;

-- Adjust balance (positive = deposit, negative = withdraw).
create or replace function public.wallet_adjust(
  p_wallet_id uuid,
  p_signed_amount numeric,
  p_note text default null
)
returns public.wallets
language plpgsql
security definer
set search_path = public
as $$
declare
  w public.wallets;
  new_balance numeric;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if p_signed_amount is null or p_signed_amount = 0 then
    raise exception 'invalid amount';
  end if;

  select * into w from public.wallets where id = p_wallet_id for update;
  if w.id is null then
    raise exception 'wallet not found';
  end if;
  if not public.is_home_member(w.home_id) then
    raise exception 'not a home member';
  end if;

  new_balance := w.balance_vnd + p_signed_amount;
  if new_balance < 0 then
    raise exception 'insufficient balance';
  end if;

  update public.wallets
  set balance_vnd = new_balance, updated_at = now()
  where id = p_wallet_id
  returning * into w;

  insert into public.wallet_transactions (
    home_id, wallet_id, kind, signed_amount, note, created_by
  ) values (
    w.home_id, w.id, 'adjust', p_signed_amount, p_note, auth.uid()
  );

  return w;
end;
$$;

create or replace function public.wallet_transfer(
  p_from_wallet_id uuid,
  p_to_wallet_id uuid,
  p_amount numeric,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  from_w public.wallets;
  to_w public.wallets;
  grp uuid := gen_random_uuid();
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if p_from_wallet_id = p_to_wallet_id then
    raise exception 'same wallet';
  end if;
  if p_amount is null or p_amount <= 0 then
    raise exception 'invalid amount';
  end if;

  -- Lock in stable order to avoid deadlocks.
  if p_from_wallet_id::text < p_to_wallet_id::text then
    select * into from_w from public.wallets where id = p_from_wallet_id for update;
    select * into to_w from public.wallets where id = p_to_wallet_id for update;
  else
    select * into to_w from public.wallets where id = p_to_wallet_id for update;
    select * into from_w from public.wallets where id = p_from_wallet_id for update;
  end if;

  if from_w.id is null or to_w.id is null then
    raise exception 'wallet not found';
  end if;
  if from_w.home_id <> to_w.home_id then
    raise exception 'wallets must share a home';
  end if;
  if not public.is_home_member(from_w.home_id) then
    raise exception 'not a home member';
  end if;
  if from_w.balance_vnd < p_amount then
    raise exception 'insufficient balance';
  end if;

  update public.wallets
  set balance_vnd = balance_vnd - p_amount, updated_at = now()
  where id = from_w.id;

  update public.wallets
  set balance_vnd = balance_vnd + p_amount, updated_at = now()
  where id = to_w.id;

  insert into public.wallet_transactions (
    home_id, wallet_id, kind, signed_amount, note, transfer_group_id, created_by
  ) values
    (from_w.home_id, from_w.id, 'transfer_out', -p_amount, p_note, grp, auth.uid()),
    (to_w.home_id, to_w.id, 'transfer_in', p_amount, p_note, grp, auth.uid());
end;
$$;

-- Apply expense debit to a wallet (idempotent per expense_id).
create or replace function public.wallet_apply_expense(
  p_expense_id uuid,
  p_wallet_id uuid,
  p_amount numeric
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  w public.wallets;
  e public.expenses;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if p_amount is null or p_amount <= 0 then
    raise exception 'invalid amount';
  end if;

  select * into e from public.expenses where id = p_expense_id;
  if e.id is null then
    raise exception 'expense not found';
  end if;
  if not public.is_home_member(e.home_id) then
    raise exception 'not a home member';
  end if;

  -- Already applied for this expense?
  if exists (
    select 1 from public.wallet_transactions
    where expense_id = p_expense_id and kind = 'expense'
  ) then
    raise exception 'expense already applied to wallet';
  end if;

  select * into w from public.wallets where id = p_wallet_id for update;
  if w.id is null then
    raise exception 'wallet not found';
  end if;
  if w.home_id <> e.home_id then
    raise exception 'wallet home mismatch';
  end if;
  if w.balance_vnd < p_amount then
    raise exception 'insufficient balance';
  end if;

  update public.wallets
  set balance_vnd = balance_vnd - p_amount, updated_at = now()
  where id = w.id;

  update public.expenses
  set wallet_id = p_wallet_id
  where id = p_expense_id;

  insert into public.wallet_transactions (
    home_id, wallet_id, kind, signed_amount, note, expense_id, created_by
  ) values (
    w.home_id, w.id, 'expense', -p_amount, e.note, p_expense_id, auth.uid()
  );
end;
$$;

-- Undo expense debit (before delete or re-apply).
create or replace function public.wallet_revert_expense(p_expense_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  txn public.wallet_transactions;
  w public.wallets;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select * into txn
  from public.wallet_transactions
  where expense_id = p_expense_id and kind = 'expense'
  limit 1;

  if txn.id is null then
    update public.expenses set wallet_id = null where id = p_expense_id;
    return;
  end if;

  select * into w from public.wallets where id = txn.wallet_id for update;
  if w.id is not null then
    if not public.is_home_member(w.home_id) then
      raise exception 'not a home member';
    end if;
    update public.wallets
    set balance_vnd = balance_vnd - txn.signed_amount, updated_at = now()
    where id = w.id;
  end if;

  delete from public.wallet_transactions where id = txn.id;

  update public.expenses set wallet_id = null where id = p_expense_id;
end;
$$;

grant execute on function public.wallet_adjust(uuid, numeric, text) to authenticated;
grant execute on function public.wallet_transfer(uuid, uuid, numeric, text) to authenticated;
grant execute on function public.wallet_apply_expense(uuid, uuid, numeric) to authenticated;
grant execute on function public.wallet_revert_expense(uuid) to authenticated;
