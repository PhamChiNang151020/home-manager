-- Monthly income per member. RLS from day one.

create table public.incomes (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  user_id uuid not null references public.profiles (id),
  amount_vnd numeric not null check (amount_vnd >= 0),
  income_month date not null,
  source text,
  note text,
  created_at timestamptz not null default now(),
  unique (home_id, user_id, income_month)
);

create index incomes_home_month
  on public.incomes (home_id, income_month desc);

alter table public.incomes enable row level security;

create policy "incomes_member_all"
  on public.incomes for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));
