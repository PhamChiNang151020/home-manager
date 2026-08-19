-- Add is_paid flag to electricity_periods
alter table public.electricity_periods
  add column if not exists is_paid boolean not null default false;
