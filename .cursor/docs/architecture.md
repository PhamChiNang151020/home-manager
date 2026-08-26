# Architecture — home_manager

## Problem

Track electricity for two family homes on iPhone (PWA or iOS Simulator) with Google login and sync.

## Layers

1. **UI** — Material 3, Vietnamese. Flutter Web PWA + native iOS Simulator.
2. **Domain / services** — homes, invites, electricity/water periods, expenses, income, photos, ICS. No Supabase in widgets.
3. **Supabase** — Auth (Google), Postgres + RLS, Storage for bill JPEGs.

## Homes

| Mode | House | Input | Amount |
|------|--------|--------|--------|
| `meter` | Nhà tôi | New kWh (first period also previous kWh) | `(new − previous) × kwh_rate` |
| `invoice` | Nhà ba mẹ | Month + VND + photo | Entered from MoMo / bank bill |

## Data (see `supabase/migrations/`)

- `profiles` — `id` = `auth.users.id`
- `homes` — name, `tracking_mode`, `kwh_rate`, `m3_rate`, calendar days, `created_by`
- `home_members` — `owner` \| `member`
- `home_invites` — pending email until Google email matches
- `home_join_links` — reusable QR token (14 days); scan then Google login, no email match
- `wallets` / `wallet_transactions` — liquid cash/bank/ewallet balances + ledger (adjust / transfer / expense)
- `electricity_periods` / `water_periods` — unique `(home_id, period_month)`
- `expense_categories` — 5 defaults seeded per home
- `expenses` — amount, category, paid_by, date, optional receipt
- `incomes` — unique `(home_id, user_id, income_month)`

Storage: bucket `bill-photos`. Electricity `homes/{id}/{yyyy-mm}.jpg`; water `homes/{id}/water/{yyyy-mm}.jpg`; expense receipts `homes/{id}/expenses/{id}.jpg`.

## Auth / invite

1. Sign in with Google.
2. Trigger upserts `profiles`.
3. RPC `accept_pending_invites` attaches memberships for matching email.
4. Owner shows a **join QR** (`create_or_get_join_link`); invitee opens `?join=<token>` and after login RPC `accept_invite_token` attaches membership (email ignored).
5. Owner may also call `invite_to_home(home_id, email)`; app then invokes Edge Function `send-home-invite` (Resend) with the join URL.
6. RLS: only members read/write that home’s rows and photos.

OAuth redirect: web page origin; iOS `com.pcn.home-manager://login-callback`.

## Reminders

1. Banner on Tổng quan (and utility pages) when today matches photo / payday / remind day (clamp 31 → last day of month). Copy covers điện + nước. Same calendar days — no separate water remind day.
2. Settings: download monthly `.ics` (RRULE) for those days.
3. Web Push: later — iOS needs Home Screen PWA + VAPID + scheduled Edge Function. See `.cursor/docs/web-push.md`.

## Deploy

```bash
flutter build web --base-href /home-manager/ \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

OAuth redirect URLs: `http://localhost:*`, the Pages origin, and `com.pcn.home-manager://login-callback` (iOS).

## Error cases

- Not a member → empty home list; owner creates a home.
- First `meter` period missing previous kWh → require both readings.
- New kWh < previous → validation error.
- Storage denied → show RLS/login error, keep period without photo if upload fails after insert (prefer upload then upsert).
