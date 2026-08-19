---
name: home-manager-domain
description: >-
  Domain rules for the home_manager Flutter Web app: household utilities,
  expenses, shopping list, bill photos, and local-first Hive storage. Use when
  implementing screens, models, storage, backup, or PWA install flow.
---

# home_manager — domain

Read `.cursor/notes.md` and `.cursor/docs/architecture.md` first.

## Product

Personal household tracker (Vietnamese UI):

- Điện / nước (readings + amount + date)
- Chi tiêu
- Danh sách cần mua
- Ảnh hoá đơn

## Storage

- Phase 1: **Hive only** (browser IndexedDB). Offline after first visit.
- Always offer **export/import** so Safari cache wipe is recoverable.
- Phase 2 cloud sync is opt-in — do not add Firebase/Supabase unless asked.
- Never commit user dumps or photos.

## Photos

- Capture via `image_picker` (camera or gallery on Safari).
- Compress before save. Store locally; no cloud in v1.

## Platform

- Flutter Web / PWA only.
- Do not enable iOS/Android, Developer Mode, or App Store workflows.

## UI expectations

- Mobile-first, usable as a Home Screen web app.
- One primary action per screen (Add bill, Add expense, Add item).
- Empty states when no data yet.

## Out of scope for v1

- Native iOS install
- Push notifications
- Multi-user accounts
- Paid hosting or paid APIs
