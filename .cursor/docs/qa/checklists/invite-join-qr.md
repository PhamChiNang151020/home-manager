# Feature checklist — Invite join QR + iOS simulator

Link inventory IDs: INV-01, INV-02, HOME-04, AUTH-01, PWA-02.

## Goal

Owner shows a join QR on Chia sẻ; family scans, signs in with Google, and sees the owner's home. Native iOS target runs on iPhone 17 Pro Simulator.

## Scope

- In scope:
  - `ios/` platform (Simulator, no App Store submit)
  - Launch config for iPhone 17 Pro
  - `home_join_links` token (join without matching email)
  - Members page QR; persist `?join=` until after Google login
  - Clarify PWA install QR is not a home invite
- Out of scope:
  - Apple Developer signing, TestFlight, App Store listing
  - Native OCR (web Tesseract only)

## Files (from CODEBASE_MAP)

- `lib/core/config/app_config.dart`
- `lib/core/domain/join_link.dart`
- `lib/core/services/invite_service.dart`
- `lib/core/services/join_link_store.dart`
- `lib/core/state/session_controller.dart`
- `lib/features/settings/settings_members_page.dart`
- `lib/features/pwa/install_home_screen_page.dart`
- `supabase/migrations/20260825090000_home_join_links.sql`
- `.vscode/launch.json`, `.vscode/tasks.json`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Scan QR while signed out → token persisted → login → join
- [x] Expired / revoked token shows error, does not create a new home
- [x] Email invite path still works (`accept_pending_invites`)
- [x] PWA install QR copy no longer implies joining a home
- [x] OCR button does not crash on iOS (hidden or web-only)

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/join_link_test.dart` | parse `?join=` and custom scheme |
| Unit | `test/unit/join_link_store_test.dart` | persist / clear token |
| Widget | `test/widget/settings_members_page_test.dart` | owner sees join QR |
| Widget | `test/widget/install_home_screen_test.dart` | install copy is not invite copy |
| Integration | `test/integration/invite_service_test.dart` | create / accept / revoke RPCs |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

Link TC IDs from [v1-manual-e2e.md](../v1-manual-e2e.md):

- [ ] TC-INV-01
- [ ] TC-INV-02
- [ ] TC-INV-03

**Browser:** Chrome · Safari/iPhone if [PWA] · iOS Simulator

## Regression (bug fix only)

- [x] Root cause documented (install QR ≠ home membership)
- [x] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
