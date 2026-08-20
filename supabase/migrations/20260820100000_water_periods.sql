-- Water periods + m3_rate on homes. Mirror electricity_periods RLS.

alter table public.homes
  add column if not exists m3_rate numeric not null default 10000;

create table public.water_periods (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  period_month date not null,
  previous_m3 numeric,
  new_m3 numeric,
  consumption_m3 numeric,
  amount_vnd numeric not null,
  photo_path text,
  note text,
  recorded_at timestamptz not null default now(),
  is_paid boolean not null default false,
  unique (home_id, period_month)
);

create index water_periods_home_month
  on public.water_periods (home_id, period_month desc);

alter table public.water_periods enable row level security;

create policy "water_periods_member_all"
  on public.water_periods for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

-- Recreate RPCs with m3_rate (CREATE OR REPLACE cannot change signatures).

drop function if exists public.create_home(text, text, numeric, int, int, int);

create or replace function public.create_home(
  p_name text,
  p_tracking_mode text,
  p_kwh_rate numeric default 3500,
  p_photo_due_day int default null,
  p_payday_day int default null,
  p_remind_day int default null,
  p_m3_rate numeric default 10000
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  hid uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if p_tracking_mode not in ('meter', 'invoice') then
    raise exception 'invalid tracking_mode';
  end if;

  insert into public.homes (
    name, tracking_mode, kwh_rate, m3_rate,
    photo_due_day, payday_day, remind_day, created_by
  ) values (
    p_name, p_tracking_mode, coalesce(p_kwh_rate, 3500), coalesce(p_m3_rate, 10000),
    p_photo_due_day, p_payday_day, p_remind_day, auth.uid()
  )
  returning id into hid;

  insert into public.home_members (home_id, user_id, role)
  values (hid, auth.uid(), 'owner');

  return hid;
end;
$$;

drop function if exists public.update_home_settings(uuid, text, numeric, int, int, int);

create or replace function public.update_home_settings(
  p_home_id uuid,
  p_name text default null,
  p_kwh_rate numeric default null,
  p_photo_due_day int default null,
  p_payday_day int default null,
  p_remind_day int default null,
  p_m3_rate numeric default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_home_owner(p_home_id) then
    raise exception 'only owner can update settings';
  end if;
  update public.homes
  set
    name = coalesce(p_name, name),
    kwh_rate = coalesce(p_kwh_rate, kwh_rate),
    m3_rate = coalesce(p_m3_rate, m3_rate),
    photo_due_day = p_photo_due_day,
    payday_day = p_payday_day,
    remind_day = p_remind_day
  where id = p_home_id;
end;
$$;

grant execute on function public.create_home(text, text, numeric, int, int, int, numeric) to authenticated;
grant execute on function public.update_home_settings(uuid, text, numeric, int, int, int, numeric) to authenticated;
