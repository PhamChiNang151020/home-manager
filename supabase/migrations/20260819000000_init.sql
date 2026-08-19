-- v1 schema: profiles, homes, members, invites, electricity_periods, storage RLS.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  created_at timestamptz not null default now()
);

create table public.homes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tracking_mode text not null check (tracking_mode in ('meter', 'invoice')),
  kwh_rate numeric not null default 3500,
  photo_due_day int check (photo_due_day is null or photo_due_day between 1 and 31),
  payday_day int check (payday_day is null or payday_day between 1 and 31),
  remind_day int check (remind_day is null or remind_day between 1 and 31),
  created_by uuid not null references public.profiles (id),
  created_at timestamptz not null default now()
);

create table public.home_members (
  home_id uuid not null references public.homes (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null check (role in ('owner', 'member')),
  created_at timestamptz not null default now(),
  primary key (home_id, user_id)
);

create table public.home_invites (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  email text not null,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'revoked')),
  invited_by uuid not null references public.profiles (id),
  token text not null unique default encode(gen_random_bytes(16), 'hex'),
  expires_at timestamptz not null default (now() + interval '14 days'),
  created_at timestamptz not null default now()
);

create unique index home_invites_pending_email
  on public.home_invites (home_id, lower(email))
  where status = 'pending';

create table public.electricity_periods (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  period_month date not null,
  previous_kwh numeric,
  new_kwh numeric,
  consumption_kwh numeric,
  amount_vnd numeric not null,
  photo_path text,
  note text,
  recorded_at timestamptz not null default now(),
  unique (home_id, period_month)
);

create index electricity_periods_home_month
  on public.electricity_periods (home_id, period_month desc);

-- ---------------------------------------------------------------------------
-- Profile on signup
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', new.email)
  )
  on conflict (id) do update
    set email = excluded.email,
        display_name = coalesce(public.profiles.display_name, excluded.display_name);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Membership helpers (security definer avoids RLS recursion)
-- ---------------------------------------------------------------------------

create or replace function public.is_home_member(hid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.home_members
    where home_id = hid and user_id = auth.uid()
  );
$$;

create or replace function public.is_home_owner(hid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.home_members
    where home_id = hid and user_id = auth.uid() and role = 'owner'
  );
$$;

create or replace function public.shares_home_with(other uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.home_members a
    join public.home_members b on a.home_id = b.home_id
    where a.user_id = auth.uid() and b.user_id = other
  );
$$;

-- ---------------------------------------------------------------------------
-- RPCs
-- ---------------------------------------------------------------------------

create or replace function public.create_home(
  p_name text,
  p_tracking_mode text,
  p_kwh_rate numeric default 3500,
  p_photo_due_day int default null,
  p_payday_day int default null,
  p_remind_day int default null
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
    name, tracking_mode, kwh_rate, photo_due_day, payday_day, remind_day, created_by
  ) values (
    p_name, p_tracking_mode, coalesce(p_kwh_rate, 3500),
    p_photo_due_day, p_payday_day, p_remind_day, auth.uid()
  )
  returning id into hid;

  insert into public.home_members (home_id, user_id, role)
  values (hid, auth.uid(), 'owner');

  return hid;
end;
$$;

create or replace function public.invite_to_home(p_home_id uuid, p_email text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized text;
  invite_id uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_home_owner(p_home_id) then
    raise exception 'only owner can invite';
  end if;

  normalized := lower(trim(p_email));
  if normalized is null or normalized = '' or position('@' in normalized) = 0 then
    raise exception 'invalid email';
  end if;

  insert into public.home_invites (home_id, email, invited_by)
  values (p_home_id, normalized, auth.uid())
  returning id into invite_id;

  return invite_id;
end;
$$;

create or replace function public.accept_pending_invites()
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  user_email text;
  attached int := 0;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select lower(email) into user_email from public.profiles where id = auth.uid();
  if user_email is null then
    select lower(email) into user_email from auth.users where id = auth.uid();
    insert into public.profiles (id, email, display_name)
    values (auth.uid(), user_email, user_email)
    on conflict (id) do update set email = coalesce(public.profiles.email, excluded.email);
  end if;

  insert into public.home_members (home_id, user_id, role)
  select i.home_id, auth.uid(), 'member'
  from public.home_invites i
  where i.status = 'pending'
    and i.expires_at > now()
    and lower(i.email) = user_email
  on conflict (home_id, user_id) do nothing;

  get diagnostics attached = row_count;

  update public.home_invites i
  set status = 'accepted'
  where i.status = 'pending'
    and i.expires_at > now()
    and lower(i.email) = user_email;

  return attached;
end;
$$;

create or replace function public.update_home_settings(
  p_home_id uuid,
  p_name text default null,
  p_kwh_rate numeric default null,
  p_photo_due_day int default null,
  p_payday_day int default null,
  p_remind_day int default null
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
    photo_due_day = p_photo_due_day,
    payday_day = p_payday_day,
    remind_day = p_remind_day
  where id = p_home_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.homes enable row level security;
alter table public.home_members enable row level security;
alter table public.home_invites enable row level security;
alter table public.electricity_periods enable row level security;

create policy "profiles_select_housemate"
  on public.profiles for select
  using (id = auth.uid() or public.shares_home_with(id));

create policy "profiles_update_self"
  on public.profiles for update
  using (id = auth.uid());

create policy "homes_member_select"
  on public.homes for select
  using (public.is_home_member(id));

create policy "homes_owner_update"
  on public.homes for update
  using (public.is_home_owner(id));

create policy "members_select"
  on public.home_members for select
  using (public.is_home_member(home_id));

create policy "invites_owner_select"
  on public.home_invites for select
  using (public.is_home_owner(home_id) or lower(email) = lower((select email from public.profiles where id = auth.uid())));

create policy "periods_member_all"
  on public.electricity_periods for all
  using (public.is_home_member(home_id))
  with check (public.is_home_member(home_id));

grant execute on function public.create_home(text, text, numeric, int, int, int) to authenticated;
grant execute on function public.invite_to_home(uuid, text) to authenticated;
grant execute on function public.accept_pending_invites() to authenticated;
grant execute on function public.update_home_settings(uuid, text, numeric, int, int, int) to authenticated;
grant execute on function public.is_home_member(uuid) to authenticated;
grant execute on function public.shares_home_with(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Storage
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('bill-photos', 'bill-photos', false)
on conflict (id) do nothing;

create policy "bill_photos_member_select"
  on storage.objects for select
  using (
    bucket_id = 'bill-photos'
    and public.is_home_member(((storage.foldername(name))[2])::uuid)
  );

create policy "bill_photos_member_insert"
  on storage.objects for insert
  with check (
    bucket_id = 'bill-photos'
    and public.is_home_member(((storage.foldername(name))[2])::uuid)
  );

create policy "bill_photos_member_update"
  on storage.objects for update
  using (
    bucket_id = 'bill-photos'
    and public.is_home_member(((storage.foldername(name))[2])::uuid)
  );
