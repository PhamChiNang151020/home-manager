-- Short invite code (6 chars) + rate-limited accept RPC.
-- Approved: home-empty spec 23/10/2026 · Đợt 0.

alter table public.home_join_links
  add column if not exists code text;

create unique index if not exists home_join_links_code_active
  on public.home_join_links (code)
  where revoked_at is null;

create or replace function public.generate_invite_code()
returns text
language plpgsql
as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  candidate text;
  i int;
  b bytea;
begin
  loop
    candidate := '';
    b := gen_random_bytes(6);
    for i in 0..5 loop
      candidate := candidate || substr(alphabet, (get_byte(b, i) % 32) + 1, 1);
    end loop;
    if not exists (
      select 1
      from public.home_join_links
      where code = candidate
        and revoked_at is null
    ) then
      return candidate;
    end if;
  end loop;
end;
$$;

create or replace function public.create_or_get_join_link(
  p_home_id uuid,
  p_rotate boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  link public.home_join_links;
  new_code text;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_home_owner(p_home_id) then
    raise exception 'only owner can invite';
  end if;

  if p_rotate then
    update public.home_join_links
    set revoked_at = now()
    where home_id = p_home_id
      and revoked_at is null;
  else
    select * into link
    from public.home_join_links
    where home_id = p_home_id
      and revoked_at is null
      and expires_at > now()
    order by created_at desc
    limit 1;
    if found then
      if link.code is null then
        new_code := public.generate_invite_code();
        update public.home_join_links
        set code = new_code
        where id = link.id
        returning * into link;
      end if;
      return jsonb_build_object(
        'token', link.token,
        'home_id', link.home_id,
        'expires_at', link.expires_at,
        'code', link.code
      );
    end if;

    update public.home_join_links
    set revoked_at = now()
    where home_id = p_home_id
      and revoked_at is null;
  end if;

  new_code := public.generate_invite_code();
  insert into public.home_join_links (home_id, created_by, code)
  values (p_home_id, auth.uid(), new_code)
  returning * into link;

  return jsonb_build_object(
    'token', link.token,
    'home_id', link.home_id,
    'expires_at', link.expires_at,
    'code', link.code
  );
end;
$$;

create table if not exists public.invite_code_attempts (
  user_id uuid not null,
  attempted_at timestamptz not null default now(),
  success boolean not null
);

alter table public.invite_code_attempts enable row level security;

create or replace function public.accept_invite_code(p_code text)
returns uuid
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
    raise exception 'too many attempts';
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
    raise exception 'invalid or expired invite code';
  end if;

  select * into link
  from public.home_join_links
  where code = normalized
    and revoked_at is null
    and expires_at > now();

  if not found then
    insert into public.invite_code_attempts (user_id, success)
    values (auth.uid(), false);
    raise exception 'invalid or expired invite code';
  end if;

  hid := link.home_id;

  insert into public.home_members (home_id, user_id, role)
  values (hid, auth.uid(), 'member')
  on conflict (home_id, user_id) do nothing;

  insert into public.invite_code_attempts (user_id, success)
  values (auth.uid(), true);

  return hid;
end;
$$;

grant execute on function public.create_or_get_join_link(uuid, boolean) to authenticated;
grant execute on function public.accept_invite_code(text) to authenticated;
