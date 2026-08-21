-- Owner-only home deletion (cascades related rows via FK).

create or replace function public.delete_home(p_home_id uuid)
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
    raise exception 'only owner can delete home';
  end if;

  delete from storage.objects
  where bucket_id = 'bill-photos'
    and name like ('homes/' || p_home_id::text || '/%');

  delete from public.homes
  where id = p_home_id;
end;
$$;

grant execute on function public.delete_home(uuid) to authenticated;
