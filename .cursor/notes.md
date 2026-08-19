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
- Deploy static `flutter build web` to free hosting (Firebase Hosting or GitHub Pages).

## Data

- **Phase 1:** local-only (Hive → IndexedDB in the browser). Offline after first load.
- **Backup:** export/import JSON (and photos) — required because Safari may clear site data.
- **Phase 2 (optional):** Firebase/Supabase free tier for sync. Do not add until asked.
- App is personal; do not log PII or bill photos to third-party analytics.

## Flutter SDK

- Develop and build with Flutter **3.29.2** (Dart 3.7.2).
- Workspace sibling: `../flutter_sdk_switcher` is a **separate** repo — do not mix files.

## Repository

- GitHub: `https://github.com/PhamChiNang151020/home-manager.git` (private)
- Default branch: `main`
- Parent folder `../` (`client/`) holds multiple personal projects; this repo root is `home-manager/` only.
