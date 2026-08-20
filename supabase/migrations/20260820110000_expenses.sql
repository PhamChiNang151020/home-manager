-- Expense categories + expenses. RLS from day one. Seed 5 defaults per home.

create table public.expense_categories (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  name text not null,
  icon_key text not null,
  color_key text not null,
  is_default boolean not null default false,
  unique (home_id, name)
);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  category_id uuid not null references public.expense_categories (id) on delete restrict,
  paid_by uuid not null references public.profiles (id),
  amount_vnd numeric not null check (amount_vnd > 0),
  expense_date date not null default (current_date),
  note text,
  receipt_photo_path text,
  created_at timestamptz not null default now()
);

create index expenses_home_date
  on public.expenses (home_id, expense_date desc);

create index expense_categories_home
  on public.expense_categories (home_id);

alter table public.expense_categories enable row level security;
alter table public.expenses enable row level security;

create policy "expense_categories_member_select"
  on public.expense_categories for select
  using (public.is_home_member(home_id));

create policy "expense_categories_owner_write"
  on public.expense_categories for insert
  with check (public.is_home_owner(home_id));

create policy "expense_categories_owner_update"
  on public.expense_categories for update
  using (public.is_home_owner(home_id))
  with check (public.is_home_owner(home_id));

create policy "expense_categories_owner_delete"
  on public.expense_categories for delete
  using (public.is_home_owner(home_id) and is_default = false);

create policy "expenses_member_all"
  on public.expenses for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

create or replace function public.seed_default_expense_categories()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.expense_categories (home_id, name, icon_key, color_key, is_default)
  values
    (new.id, 'Ăn uống/Chợ', 'restaurant', 'food', true),
    (new.id, 'Vay/Trả góp', 'payments', 'loan', true),
    (new.id, 'Bảo hiểm/Y tế', 'health_and_safety', 'health', true),
    (new.id, 'Học phí con', 'school', 'tuition', true),
    (new.id, 'Khác', 'more_horiz', 'other', true);
  return new;
end;
$$;

drop trigger if exists on_home_created_seed_categories on public.homes;
create trigger on_home_created_seed_categories
  after insert on public.homes
  for each row execute function public.seed_default_expense_categories();

insert into public.expense_categories (home_id, name, icon_key, color_key, is_default)
select h.id, v.name, v.icon_key, v.color_key, true
from public.homes h
cross join (values
  ('Ăn uống/Chợ', 'restaurant', 'food'),
  ('Vay/Trả góp', 'payments', 'loan'),
  ('Bảo hiểm/Y tế', 'health_and_safety', 'health'),
  ('Học phí con', 'school', 'tuition'),
  ('Khác', 'more_horiz', 'other')
) as v(name, icon_key, color_key)
where not exists (
  select 1 from public.expense_categories c where c.home_id = h.id
);
