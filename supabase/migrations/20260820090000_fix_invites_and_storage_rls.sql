-- Fix silent failures: cancel invite (DELETE/UPDATE) and delete bill photos.

-- ---------------------------------------------------------------------------
-- home_invites: owner can update / delete (InviteService.cancel)
-- ---------------------------------------------------------------------------

create policy "invites_owner_update"
  on public.home_invites for update
  using (public.is_home_owner(home_id))
  with check (public.is_home_owner(home_id));

create policy "invites_owner_delete"
  on public.home_invites for delete
  using (public.is_home_owner(home_id));

-- ---------------------------------------------------------------------------
-- Storage: members can delete bill photos (delete period with photo)
-- Path: homes/{home_id}/...  — foldername[2] is home_id
-- ---------------------------------------------------------------------------

create policy "bill_photos_member_delete"
  on storage.objects for delete
  using (
    bucket_id = 'bill-photos'
    and public.is_home_member(((storage.foldername(name))[2])::uuid)
  );
