---
name: home-manager-domain
description: >-
  Domain rules for home_manager: two homes (meter vs invoice), Google auth,
  Supabase RLS, bill photos, reminder days, and Flutter Web PWA. Use when
  implementing screens, schema, storage, or invites.
---

# home_manager — domain

Read `.cursor/notes.md` and `.cursor/docs/architecture.md` first.

## Product (v1)

Vietnamese UI. Electricity only.

- **Nhà tôi (`meter`):** enter new kWh; previous from last period; amount = delta × rate (default 3500).
- **Nhà ba mẹ (`invoice`):** enter bill amount + photo (MoMo/bank). No kWh required.
- Owner invites per home by Google email.
- Calendar days: photo due, payday, remind.

## Storage

- Supabase Postgres + Storage. Online-first.
- Photos: `image_picker`, JPEG under `bill-photos/homes/{home_id}/{yyyy-mm}.jpg`.
- Never commit dumps, photos, or the service role key.

## Platform

- Flutter Web / PWA only.
- Do not enable iOS/Android, Developer Mode, or App Store workflows.

## UI

- Mobile-first Home Screen web app.
- Switch home in the shell. Electricity form follows `tracking_mode`.
- Empty states when no homes or no periods.

## Out of scope for v1

- Native iOS install
- Water, expenses, shopping
- Web Push (documented in `.cursor/docs/web-push.md`)
- Paid hosting
