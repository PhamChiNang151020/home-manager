# Web Push (after V1 core)

Do this only when electricity + photos + PWA install already work on iPhone.

## Why later

iOS Safari delivers Web Push **only** for apps added to the Home Screen (iOS 16.4+). Needs HTTPS, a service worker, VAPID keys, user permission, and a **server cron** to send.

## Outline

1. Flutter Web service worker (beyond default Flutter cache SW) to handle `push`.
2. Store subscription endpoint in Supabase (`push_subscriptions`: `user_id`, keys).
3. VAPID public key in the app; **private** key only in Edge Function secrets.
4. Daily schedule (pg_cron or GitHub Action) → Edge Function:
   - For each home, if today is `photo_due_day` / `payday_day` / `remind_day`
   - Notify members
5. Copy: “Hôm nay chụp hoá đơn điện — Nhà ba mẹ”, etc.

## Not in this repo yet

No VAPID, no Edge Function, no custom SW. In-app banner + `.ics` cover V1 reminders.
