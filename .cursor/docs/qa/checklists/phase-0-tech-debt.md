# Feature checklist — Phase 0 tech debt

Link inventory IDs from [v1-feature-inventory.md](../v1-feature-inventory.md).

## Goal

Fix silent invite/photo deletes, preserve `is_paid` on edit, persist selected home, merge deploy workflows, stop creating services in `AppShell.build()`.

## Scope

- In scope: RLS policies, `ElectricityService.upsert`, `SessionController` home persistence, GitHub Actions, `AppServices` injection
- Out of scope: Water / expenses / income UI

## Files (from CODEBASE_MAP)

- `supabase/migrations/20260820090000_fix_invites_and_storage_rls.sql`
- `lib/core/services/electricity_service.dart`
- `lib/core/services/app_services.dart`
- `lib/core/state/session_controller.dart`
- `lib/core/domain/selected_home.dart`
- `lib/features/shell/app_shell.dart`
- `lib/app.dart`, `lib/main.dart`
- `.github/workflows/deploy-pages.yml`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Edit paid period without sending `isPaid` does not reset to false
- [x] Selected home id survives refresh when still in the list
- [x] Invite cancel / photo delete have RLS policies

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/selected_home_test.dart` | resolveSelectedHome preference |
| Integration | `test/integration/electricity_service_test.dart` | upsert omits `is_paid` when null |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

- [ ] Cancel pending invite as owner
- [ ] Delete electricity period that has a photo
- [ ] Edit a paid period (amount only) — stays paid
- [ ] Select second home, refresh — stays on second home

**Browser:** Chrome · Safari/iPhone if [PWA]

## Regression (bug fix only)

- [x] Root cause documented
- [x] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail

## Done criteria

- [ ] `flutter analyze` clean
- [ ] `flutter test` pass
- [ ] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
