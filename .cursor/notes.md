# Architectural decision notes — home_manager

Locked decisions. Do not change without discussion.

---

## Platform scope

- **v1:** Flutter **Web only** (`--platforms=web`). Install on iPhone via Safari **Add to Home Screen** (PWA).
- Do **not** add iOS/Android native targets without approval.
- Reason: iPhone banking apps block **Developer Mode**; native sideload is incompatible with daily banking on the same device.

## Distribution

- No App Store.
- No Xcode install / Developer Mode.
- Deploy static `flutter build web --base-href /home-manager/` to **GitHub Pages**.
- Private repo + Pages may need GitHub Pro; fallback: Cloudflare Pages or Firebase Hosting (source stays on GitHub).

## Auth and data

- **Source of truth:** Supabase (Postgres + RLS + Storage). Online-first for family sync.
- **Auth:** Google via Supabase OAuth.
- **Owner invites** members **per home** by Google email.
- Anon key + project URL are public (RLS protects rows). Never commit the **service role** key.
- Do not log PII or bill photos to analytics.

## Homes (v1)

- Two homes: **Nhà tôi** (`meter`) and **Nhà ba mẹ** (`invoice`).
- `meter`: new kWh − previous period kWh, then × `kwh_rate` (default 3500 đ/kWh, editable per home).
- `invoice`: amount + month + photo (MoMo / bank screenshot). No meter math.
- Each home: `photo_due_day`, `payday_day`, `remind_day` (day of month 1–31).

## v1 product scope

- Electricity only. Water, expenses, shopping are later; keep `homes` reusable.
- Reminders: in-app banner first, then `.ics` export, then Web Push (separate, after PWA install).

## Flutter SDK

- Develop and build with Flutter **3.29.2** (Dart 3.7.2).
- Workspace sibling: `../flutter_sdk_switcher` is a **separate** repo — do not mix files.

## Repository

- GitHub: `https://github.com/PhamChiNang151020/home-manager.git` (private)
- Default branch: `main`
- Parent folder `../` (`client/`) holds multiple personal projects; this repo root is `home-manager/` only.
