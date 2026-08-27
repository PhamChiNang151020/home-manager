-- Reject inviting the owner or anyone already in the home.

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
