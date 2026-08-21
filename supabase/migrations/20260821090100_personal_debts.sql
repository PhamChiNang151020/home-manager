-- Personal debts (two-way) + payments. Remaining updated via RPC.

create table public.personal_debts (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  direction text not null check (direction in ('i_owe', 'owed_to_me')),
  counterparty_name text not null,
  principal_amount numeric not null check (principal_amount > 0),
  remaining_amount numeric not null check (remaining_amount >= 0),
  due_date date,
  interest_rate numeric,
  is_settled boolean not null default false,
  note text,
  created_by uuid not null references public.profiles (id),
  created_at timestamptz not null default now()
);

create index personal_debts_home on public.personal_debts (home_id);

alter table public.personal_debts enable row level security;

create policy "personal_debts_member_all"
  on public.personal_debts for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

create table public.personal_debt_payments (
  id uuid primary key default gen_random_uuid(),
  debt_id uuid not null references public.personal_debts (id) on delete cascade,
  amount numeric not null check (amount > 0),
  paid_date date not null,
  note text,
  created_at timestamptz not null default now()
);

create index personal_debt_payments_debt
  on public.personal_debt_payments (debt_id, paid_date desc);

alter table public.personal_debt_payments enable row level security;

create policy "personal_debt_payments_member_all"
  on public.personal_debt_payments for all
  using (
    exists (
      select 1 from public.personal_debts d
      where d.id = debt_id and public.is_home_member(d.home_id)
    )
  )
  with check (
    exists (
      select 1 from public.personal_debts d
      where d.id = debt_id and public.is_home_member(d.home_id)
    )
  );

create or replace function public.add_personal_debt_payment(
  p_debt_id uuid,
  p_amount numeric,
  p_paid_date date,
  p_note text default null
)
returns public.personal_debt_payments
language plpgsql
security definer
set search_path = public
as $$
declare
  payment public.personal_debt_payments;
  debt public.personal_debts;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select * into debt from public.personal_debts where id = p_debt_id for update;
  if debt.id is null then
    raise exception 'debt not found';
  end if;
  if not public.is_home_member(debt.home_id) then
    raise exception 'not a home member';
  end if;
  if p_amount is null or p_amount <= 0 then
    raise exception 'invalid amount';
  end if;

  insert into public.personal_debt_payments (debt_id, amount, paid_date, note)
  values (p_debt_id, p_amount, p_paid_date, p_note)
  returning * into payment;

  update public.personal_debts
  set
    remaining_amount = greatest(0, remaining_amount - p_amount),
    is_settled = (remaining_amount - p_amount) <= 0
  where id = p_debt_id;

  return payment;
end;
$$;

grant execute on function public.add_personal_debt_payment(uuid, numeric, date, text)
  to authenticated;
