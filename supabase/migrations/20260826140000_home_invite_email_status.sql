-- Track outbound invite email delivery (Resend via Edge Function).

alter table public.home_invites
  add column if not exists email_sent_at timestamptz,
  add column if not exists email_last_error text;
