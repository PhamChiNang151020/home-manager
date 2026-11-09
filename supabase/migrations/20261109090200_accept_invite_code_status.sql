-- Persist failed invite-code attempts: return status instead of RAISE after INSERT.
-- RAISE rolls back the attempt row, so lockout never counted. No table changes.

drop function if exists public.accept_invite_code(text);

create function public.accept_invite_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  normalized text;
  fail_count int;
  link public.home_join_links;
  hid uuid;
  i int;
  ch text;
  valid_format boolean;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select count(*) into fail_count
  from public.invite_code_attempts
  where user_id = auth.uid()
    and success = false
    and attempted_at > now() - interval '15 minutes';

  if fail_count >= 5 then
    return jsonb_build_object('status', 'locked');
  end if;

  normalized := upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'));

  valid_format := char_length(normalized) = 6;
  if valid_format then
    for i in 1..6 loop
      ch := substr(normalized, i, 1);
      if position(ch in alphabet) = 0 then
        valid_format := false;
        exit;
      end if;
    end loop;
  end if;

  if not valid_format then
    insert into public.invite_code_attempts (user_id, success)
    values (auth.uid(), false);
    return jsonb_build_object('status', 'invalid');
  end if;

  select * into link
  from public.home_join_links
  where code = normalized
    and revoked_at is null
    and expires_at > now();

  if not found then
    insert into public.invite_code_attempts (user_id, success)
    values (auth.uid(), false);
    return jsonb_build_object('status', 'invalid');
  end if;

  hid := link.home_id;

  insert into public.home_members (home_id, user_id, role)
  values (hid, auth.uid(), 'member')
  on conflict (home_id, user_id) do nothing;

  insert into public.invite_code_attempts (user_id, success)
  values (auth.uid(), true);

  return jsonb_build_object('status', 'ok', 'home_id', hid);
end;
$$;

revoke execute on function public.accept_invite_code(text) from public, anon;
grant execute on function public.accept_invite_code(text) to authenticated;
