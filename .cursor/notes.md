# Architectural decision notes — home_manager

Locked decisions. Do not change without discussion.

---

## Platform scope

- **v1:** Flutter **Web** PWA. Install on iPhone via Safari **Add to Home Screen**.
- **v2+:** Native **iOS Simulator** target (`ios/`, bundle `com.pcn.home_manager`). App Store / TestFlight when an Apple Developer account exists.
- Native sideload still requires Developer Mode; do not sideload onto a daily-driver iPhone that needs banking apps.
- Do **not** add Android without approval.

## Distribution

- Primary: static `flutter build web --base-href /home-manager/` to **GitHub Pages**.
- iOS: `flutter run -d "iPhone 17 Pro"` (Simulator). App Store later.
- Private repo + Pages may need GitHub Pro; fallback: Cloudflare Pages or Firebase Hosting (source stays on GitHub).

## Auth and data

- **Source of truth:** Supabase (Postgres + RLS + Storage). Online-first for family sync.
- **Auth:** Google via Supabase OAuth. Web uses page origin (no `?join=` on `redirectTo`); iOS uses `com.pcn.home-manager://login-callback`. Dashboard Site URL must be the Pages origin.
- **Owner invites** per home by **join QR token** (scan → Google login). No email invite in the app. Owner may remove a member (`left_at`).
- Anon key + project URL are public (RLS protects rows). Never commit the **service role** key.
- Do not log PII or bill photos to analytics.

## Homes

- Two homes: **Nhà tôi** (`meter`) and **Nhà ba mẹ** (`invoice`).
- `meter`: electricity uses kWh × `kwh_rate` (default 3500); water uses m³ × `m3_rate` (default 10000).
- `invoice`: amount + month + photo. No meter math.
- Each home: `photo_due_day`, `payday_day`, `remind_day` (day of month 1–31) — shared for electricity and water.

## v2 product scope

- Electricity, water, expenses (5 default categories), monthly income per member, overview dashboard.
- Shell tabs: **Tổng quan** · **Chi tiêu** · **Cài đặt**. Điện / Nước / Thu nhập open from Tổng quan.
- Reminders: in-app banner (điện + nước, same calendar days), then `.ics` export, then Web Push (later).

## Flutter SDK

- Develop and build with Flutter **3.29.2** (Dart 3.7.2).
- Workspace sibling: `../flutter_sdk_switcher` is a **separate** repo — do not mix files.

## Repository

- GitHub: `https://github.com/PhamChiNang151020/home-manager.git` (private)
- Default branch: `main`
- Parent folder `../` (`client/`) holds multiple personal projects; this repo root is `home-manager/` only.

## QA & testing

- Workflow index: `.cursor/docs/qa/README.md`
- Agent skill: `.cursor/skills/qa-testing/SKILL.md`
- Every feature/bug: plan + checklist + automated test + `flutter test`
