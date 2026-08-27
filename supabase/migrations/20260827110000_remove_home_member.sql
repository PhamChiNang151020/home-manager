-- Owner can remove a member. History stays (same left_at as leave_home).
-- Cannot remove self (use leave_home) or another owner.

create or replace function public.remove_home_member(
  p_home_id uuid,
  p_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  target_role text;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  if not public.is_home_owner(p_home_id) then
    raise exception 'only owner can remove members';
  end if;

  if p_user_id = auth.uid() then
    raise exception 'cannot remove yourself';
  end if;

  select role into target_role
  from public.home_members
  where home_id = p_home_id
    and user_id = p_user_id
    and left_at is null
  for update;

  if not found then
    raise exception 'not a member';
  end if;

  if target_role = 'owner' then
    raise exception 'cannot remove owner';
  end if;

  update public.home_members
  set left_at = now()
  where home_id = p_home_id
    and user_id = p_user_id
    and left_at is null;
end;
$$;

grant execute on function public.remove_home_member(uuid, uuid) to authenticated;
