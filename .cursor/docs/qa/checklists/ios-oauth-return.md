# Feature checklist — iOS Google OAuth returns to app

Link inventory IDs: AUTH-01, AUTH-02.

## Goal

After Google login on iOS Simulator, dismiss the in-app Safari sheet and show the app (session already succeeds).

## Scope

- In scope: native OAuth launch mode, close in-app browser, disable Flutter implicit deep-link routing
- Out of scope: Google Cloud / Supabase console changes

## Files (from CODEBASE_MAP)

- `lib/core/services/auth_service.dart`
- `ios/Runner/Info.plist`
- `lib/core/state/session_controller.dart`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [ ] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Native Google OAuth uses external Safari, not SFSafariViewController
- [x] Flutter does not treat `com.pcn.home-manager://login-callback` as a Navigator route

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/oauth_launch_mode_test.dart` | web vs native launch mode |

## Manual E2E

- [ ] TC-AUTH-02 on iOS Simulator: Google login → back in Tổ Ấm, no blank `accounts.google.com` sheet

## Regression

- [x] Root cause documented (in-app Safari never closes; Flutter deep-link route error)
- [x] Unit test for launch-mode helper
- [ ] Manual repro no longer fails

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
