-- FCM device tokens per user (web Phase 2+).

create table public.fcm_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null,
  platform text not null default 'web'
    check (platform in ('web', 'ios', 'android')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (token)
);

create index fcm_tokens_user on public.fcm_tokens (user_id);

alter table public.fcm_tokens enable row level security;

create policy "fcm_tokens_own_select"
  on public.fcm_tokens for select
  using (user_id = auth.uid());

create policy "fcm_tokens_own_insert"
  on public.fcm_tokens for insert
  with check (user_id = auth.uid());

create policy "fcm_tokens_own_update"
  on public.fcm_tokens for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "fcm_tokens_own_delete"
  on public.fcm_tokens for delete
  using (user_id = auth.uid());
