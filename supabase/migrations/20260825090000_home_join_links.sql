-- Family join QR: token attaches membership without matching Google email.

create table public.home_join_links (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references public.homes (id) on delete cascade,
  token text not null unique default encode(gen_random_bytes(16), 'hex'),
  created_by uuid not null references public.profiles (id),
  expires_at timestamptz not null default (now() + interval '14 days'),
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create unique index home_join_links_one_active
  on public.home_join_links (home_id)
  where revoked_at is null;

alter table public.home_join_links enable row level security;

create policy "join_links_owner_select"
  on public.home_join_links for select
  using (public.is_home_owner(home_id));

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
      return jsonb_build_object(
        'token', link.token,
        'home_id', link.home_id,
        'expires_at', link.expires_at
      );
    end if;

    update public.home_join_links
    set revoked_at = now()
    where home_id = p_home_id
      and revoked_at is null;
  end if;

  insert into public.home_join_links (home_id, created_by)
  values (p_home_id, auth.uid())
  returning * into link;

  return jsonb_build_object(
    'token', link.token,
    'home_id', link.home_id,
    'expires_at', link.expires_at
  );
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
  on conflict (home_id, user_id) do nothing;

  return hid;
end;
$$;

create or replace function public.revoke_join_link(p_home_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_home_owner(p_home_id) then
    raise exception 'only owner can invite';
  end if;

  update public.home_join_links
  set revoked_at = now()
  where home_id = p_home_id
    and revoked_at is null;
end;
$$;

grant execute on function public.create_or_get_join_link(uuid, boolean) to authenticated;
grant execute on function public.accept_invite_token(text) to authenticated;
grant execute on function public.revoke_join_link(uuid) to authenticated;
