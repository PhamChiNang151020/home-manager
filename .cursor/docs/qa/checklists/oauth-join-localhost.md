# Feature checklist — OAuth join link must not redirect to localhost

Link inventory IDs: AUTH-01, INV-04, TC-AUTH-02, TC-INV-03.

## Goal

Signing in from a GitHub Pages join URL returns to Pages, not `localhost:8080`.

## Scope

- In scope:
  - Web OAuth `redirectTo` must match the Supabase allow-list (no `?join=`)
  - Join token stays in localStorage / prefs across OAuth
- Out of scope:
  - Changing Supabase dashboard Site URL (documented; user must save)

## Files (from CODEBASE_MAP)

- `lib/core/domain/oauth_redirect.dart`
- `lib/core/domain/join_link.dart`
- `lib/core/config/app_config.dart`
- `lib/core/services/auth_service.dart`
- `supabase/README.md`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] `?join=` on the current page is not copied into OAuth `redirectTo`
- [x] Web uses `window.location` (not a CanvasKit `blob:` URI)
- [x] `join.html` / `index.html` stripped so redirect lands on the Flutter app
- [x] Token still accepted after login via `JoinLinkStore` (localStorage)

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/oauth_redirect_test.dart` | Pages URL, drop query, blob, localhost fallback |
| Unit | `test/unit/join_link_test.dart` | `appBaseUrl` strips landing + index.html |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

Link TC IDs from [v1-manual-e2e.md](../v1-manual-e2e.md):

- [ ] TC-AUTH-02
- [ ] TC-INV-03
- [ ] TC-AUTH-05

**Browser:** Chrome · Safari/iPhone if [PWA]

## Regression (bug fix only)

- [x] Root cause documented (GoTrue rejects `?join=` and falls back to Site URL `localhost:8080`)
- [x] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail (needs Pages deploy + Site URL)

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
