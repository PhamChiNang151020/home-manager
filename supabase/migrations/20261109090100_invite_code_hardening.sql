-- Harden invite-code RPCs: revoke public/anon execute; pin generate_invite_code search_path.
-- Companion to 20261109090000_invite_code.sql (Supabase advisor).

revoke execute on function public.accept_invite_code(text) from public, anon;
revoke execute on function public.create_or_get_join_link(uuid, boolean) from public, anon;

grant execute on function public.accept_invite_code(text) to authenticated;
grant execute on function public.create_or_get_join_link(uuid, boolean) to authenticated;

-- Body uses unqualified gen_random_bytes (extensions.pgcrypto on production) +
-- public.home_join_links.
alter function public.generate_invite_code()
  set search_path = public, extensions, pg_temp;
