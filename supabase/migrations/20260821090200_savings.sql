-- Savings (term deposit + goal) + contributions. Balance via RPC.

create table public.savings (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  type text not null check (type in ('term_deposit', 'goal')),
  name text not null,
  bank_name text,
  interest_rate numeric,
  term_months int,
  maturity_date date,
  target_amount numeric,
  current_amount numeric not null default 0 check (current_amount >= 0),
  note text,
  created_at timestamptz not null default now()
);

create index savings_home on public.savings (home_id);

alter table public.savings enable row level security;

create policy "savings_member_all"
  on public.savings for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

create table public.savings_contributions (
  id uuid primary key default gen_random_uuid(),
  savings_id uuid not null references public.savings (id) on delete cascade,
  amount numeric not null check (amount > 0),
  contributed_date date not null,
  note text,
  created_at timestamptz not null default now()
);

create index savings_contributions_savings
  on public.savings_contributions (savings_id, contributed_date desc);

alter table public.savings_contributions enable row level security;

create policy "savings_contributions_member_all"
  on public.savings_contributions for all
  using (
    exists (
      select 1 from public.savings s
      where s.id = savings_id and public.is_home_member(s.home_id)
    )
  )
  with check (
    exists (
      select 1 from public.savings s
      where s.id = savings_id and public.is_home_member(s.home_id)
    )
  );

create or replace function public.add_savings_contribution(
  p_savings_id uuid,
  p_amount numeric,
  p_contributed_date date,
  p_note text default null
)
returns public.savings_contributions
language plpgsql
security definer
set search_path = public
as $$
declare
  contrib public.savings_contributions;
  item public.savings;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select * into item from public.savings where id = p_savings_id for update;
  if item.id is null then
    raise exception 'savings not found';
  end if;
  if not public.is_home_member(item.home_id) then
    raise exception 'not a home member';
  end if;
  if p_amount is null or p_amount <= 0 then
    raise exception 'invalid amount';
  end if;

  insert into public.savings_contributions (
    savings_id, amount, contributed_date, note
  ) values (p_savings_id, p_amount, p_contributed_date, p_note)
  returning * into contrib;

  update public.savings
  set current_amount = current_amount + p_amount
  where id = p_savings_id;

  return contrib;
end;
$$;

grant execute on function public.add_savings_contribution(uuid, numeric, date, text)
  to authenticated;
