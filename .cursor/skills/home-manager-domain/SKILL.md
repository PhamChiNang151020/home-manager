---
name: home-manager-domain
description: >-
  Domain rules for home_manager: two homes (meter vs invoice), Google auth,
  Supabase RLS, bill photos, reminder days, and Flutter Web PWA. Use when
  implementing screens, schema, storage, or invites.
---

# home_manager — domain

Read `.cursor/notes.md` and `.cursor/docs/architecture.md` first.

## Product (v2)

Vietnamese UI. Electricity, water, expenses, income.

- **Nhà tôi (`meter`):** enter new kWh / m³; previous from last period; amount = delta × rate (`kwh_rate` default 3500, `m3_rate` default 10000).
- **Nhà ba mẹ (`invoice`):** enter bill amount + photo. No meter math.
- Shell: Tổng quan · Chi tiêu · Cài đặt. Điện / Nước / Thu nhập from Tổng quan.
- Owner invites per home by Google email.
- Calendar days: photo due, payday, remind (shared for điện + nước).

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

## Out of scope for v2

- Native iOS install
- Shopping list
- Web Push (documented in `.cursor/docs/web-push.md`)
- Paid hosting

## Testing / validation

- Feature list + E2E cases: `.cursor/docs/qa/v1-feature-inventory.md`
- Meter validation (missing kWh, new < prev): `lib/core/domain/electricity_validation.dart`
- Duplicate period month: `lib/features/electricity/period_month_conflict.dart`
- Agent workflow: `.cursor/skills/qa-testing/SKILL.md`
