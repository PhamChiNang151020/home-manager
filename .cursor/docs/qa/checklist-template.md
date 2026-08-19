# Feature checklist — <!-- feature name -->

Copy from template. Link inventory IDs from [v1-feature-inventory.md](v1-feature-inventory.md).

## Goal

<!-- One sentence -->

## Scope

- In scope:
- Out of scope:

## Files (from CODEBASE_MAP)

<!-- list paths -->

## Functional checklist

- [ ] Happy path works on Chrome
- [ ] Empty / error states handled
- [ ] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [ ] No Supabase calls from widgets (services only)

## Edge cases

- [ ] <!-- e.g. duplicate month, new < prev, amount ≤ 0 -->

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/...` | |
| Widget | `test/widget/...` | |
| Integration | `test/integration/...` | |

Map IDs to [test-map.md](test-map.md) when tests exist.

## Manual E2E

Link TC IDs from [v1-manual-e2e.md](v1-manual-e2e.md):

- [ ] TC-...

**Browser:** Chrome · Safari/iPhone if [PWA]

## Regression (bug fix only)

- [ ] Root cause documented
- [ ] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail

## Done criteria

- [ ] `flutter analyze` clean
- [ ] `flutter test` pass
- [ ] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
