# New feature

## Goal

<!-- One sentence -->

## Scope

- In scope:
- Out of scope:

## Files (expected)

<!-- Use CODEBASE_MAP.md -->

## Plan

<!-- Goal + affected modules from .cursor/docs/qa/v1-feature-inventory.md -->

## Checklist

Copy [checklist-template.md](../docs/qa/checklist-template.md) → `docs/qa/checklists/<feature>.md`

- [ ] Checklist file created
- [ ] Manual E2E TC IDs listed (from v1-manual-e2e.md)

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/...` | |
| Widget | `test/widget/...` | |
| Integration | `test/integration/...` | |

- [ ] Pure logic in `lib/core/domain/` (not only in widget `_save()`)
- [ ] [test-map.md](../docs/qa/test-map.md) updated
- [ ] [v1-feature-inventory.md](../docs/qa/v1-feature-inventory.md) status updated

## Acceptance

- [ ] `flutter analyze` clean
- [ ] `flutter test` pass
- [ ] Works on Flutter Web (Chrome)
- [ ] Manual test steps documented
- [ ] Local data survives reload (if persistence involved)

## Notes

<!-- Link .cursor/notes.md if touching architecture or storage -->

Read [qa-testing SKILL](../skills/qa-testing/SKILL.md) before implementing.
