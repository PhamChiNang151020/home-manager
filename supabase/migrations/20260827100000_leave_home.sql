-- Members can leave a home. History (expenses, incomes, bills) stays.
-- Soft-delete via left_at so remaining members can still read the leaver's profile name.

alter table public.home_members
  add column if not exists left_at timestamptz;

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
    where home_id = hid
      and user_id = auth.uid()
      and left_at is null
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
    where home_id = hid
      and user_id = auth.uid()
      and role = 'owner'
      and left_at is null
  );
$$;

-- Viewer must be an active member. The other person may have already left
-- so expense paid_by names still resolve.
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
    where a.user_id = auth.uid()
      and a.left_at is null
      and b.user_id = other
  );
$$;

create or replace function public.leave_home(
  p_home_id uuid,
  p_new_owner_id uuid default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  my_role text;
  successor uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select role into my_role
  from public.home_members
  where home_id = p_home_id
    and user_id = auth.uid()
    and left_at is null
  for update;

  if not found then
    raise exception 'not a member';
  end if;

  if my_role = 'member' then
    update public.home_members
    set left_at = now()
    where home_id = p_home_id
      and user_id = auth.uid()
      and left_at is null;
    return;
  end if;

  if not exists (
    select 1
    from public.home_members
    where home_id = p_home_id
      and user_id <> auth.uid()
      and left_at is null
  ) then
    raise exception 'sole owner cannot leave';
  end if;

  if p_new_owner_id is null or p_new_owner_id = auth.uid() then
    raise exception 'must transfer ownership';
  end if;

  select user_id into successor
  from public.home_members
  where home_id = p_home_id
    and user_id = p_new_owner_id
    and left_at is null
  for update;

  if not found then
    raise exception 'new owner must be an active member';
  end if;

  update public.home_members
  set role = 'owner'
  where home_id = p_home_id
    and user_id = p_new_owner_id
    and left_at is null;

  update public.home_members
  set role = 'member',
      left_at = now()
  where home_id = p_home_id
    and user_id = auth.uid()
    and left_at is null;
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
  on conflict (home_id, user_id) do update
    set left_at = null,
        role = 'member'
    where public.home_members.left_at is not null;

  get diagnostics attached = row_count;

  update public.home_invites i
  set status = 'accepted'
  where i.status = 'pending'
    and i.expires_at > now()
    and lower(i.email) = user_email;

  return attached;
end;
$$;

create or replace function public.accept_invite_token(p_token text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  link public.home_join_links;
  hid uuid;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if p_token is null or btrim(p_token) = '' then
    raise exception 'invalid or expired join link';
  end if;

  select * into link
  from public.home_join_links
  where token = btrim(p_token)
    and revoked_at is null
    and expires_at > now();

  if not found then
    raise exception 'invalid or expired join link';
  end if;

  hid := link.home_id;

  insert into public.home_members (home_id, user_id, role)
  values (hid, auth.uid(), 'member')
  on conflict (home_id, user_id) do update
    set left_at = null,
        role = 'member'
    where public.home_members.left_at is not null;

  return hid;
end;
$$;

-- Former members (left_at set) can be invited again.
create or replace function public.invite_to_home(p_home_id uuid, p_email text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized text;
  invite_id uuid;
  owner_email text;
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

  select lower(email) into owner_email
  from public.profiles
  where id = auth.uid();

  if owner_email is not null and owner_email = normalized then
    raise exception 'cannot invite yourself';
  end if;

  if exists (
    select 1
    from public.home_members m
    join public.profiles p on p.id = m.user_id
    where m.home_id = p_home_id
      and m.left_at is null
      and lower(p.email) = normalized
  ) then
    raise exception 'already a member';
  end if;

  insert into public.home_invites (home_id, email, invited_by)
  values (p_home_id, normalized, auth.uid())
  returning id into invite_id;

  return invite_id;
end;
$$;

grant execute on function public.leave_home(uuid, uuid) to authenticated;
grant execute on function public.accept_pending_invites() to authenticated;
grant execute on function public.accept_invite_token(text) to authenticated;
grant execute on function public.invite_to_home(uuid, text) to authenticated;
