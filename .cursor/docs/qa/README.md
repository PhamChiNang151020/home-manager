# QA — home_manager v1

Index for agents and developers. Read this before writing tests or shipping features.

## Files

| File | Purpose |
|------|---------|
| [v1-feature-inventory.md](v1-feature-inventory.md) | All v1 features + test type + coverage status |
| [v1-manual-e2e.md](v1-manual-e2e.md) | Manual checklist (Chrome; Safari/iPhone when UI/storage) |
| [test-map.md](test-map.md) | Checklist ID → automated test file |
| [checklist-template.md](checklist-template.md) | Copy for each new feature or bug fix |
| [checklists/](checklists/) | Per-feature checklists (create as needed) |

## Workflow

1. Open [v1-feature-inventory.md](v1-feature-inventory.md) — find your module.
2. Copy [checklist-template.md](checklist-template.md) → `checklists/<name>.md`.
3. Implement + add tests under `test/unit/`, `test/widget/`, `test/integration/`.
4. Update inventory status and [test-map.md](test-map.md) when adding tests.
5. Run `flutter analyze && flutter test`.

## Agent entry point

[`.cursor/skills/qa-testing/SKILL.md`](../../skills/qa-testing/SKILL.md)

## Rule

[`.cursor/rules/04-testing.mdc`](../../rules/04-testing.mdc)
