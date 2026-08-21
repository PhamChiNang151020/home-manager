-- Bank credit accounts + statement periods. RLS via is_home_member.

create table public.bank_accounts (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  bank_name text not null,
  credit_limit numeric not null check (credit_limit >= 0),
  statement_day int not null check (statement_day between 1 and 31),
  due_day int not null check (due_day between 1 and 31),
  note text,
  created_at timestamptz not null default now()
);

create index bank_accounts_home on public.bank_accounts (home_id);

alter table public.bank_accounts enable row level security;

create policy "bank_accounts_member_all"
  on public.bank_accounts for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

create table public.bank_account_periods (
  id uuid primary key default gen_random_uuid(),
  bank_account_id uuid not null references public.bank_accounts (id) on delete cascade,
  period_month date not null,
  balance_used numeric not null check (balance_used >= 0),
  payment_due numeric not null check (payment_due >= 0),
  payment_made numeric not null default 0 check (payment_made >= 0),
  is_paid boolean not null default false,
  note text,
  recorded_at timestamptz not null default now(),
  unique (bank_account_id, period_month)
);

create index bank_account_periods_account_month
  on public.bank_account_periods (bank_account_id, period_month desc);

alter table public.bank_account_periods enable row level security;

create policy "bank_account_periods_member_all"
  on public.bank_account_periods for all
  using (
    exists (
      select 1 from public.bank_accounts a
      where a.id = bank_account_id and public.is_home_member(a.home_id)
    )
  )
  with check (
    exists (
      select 1 from public.bank_accounts a
      where a.id = bank_account_id and public.is_home_member(a.home_id)
    )
  );
