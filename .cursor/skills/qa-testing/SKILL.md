---
name: qa-testing
description: >-
  QA and testing workflow for home_manager v1. Use when adding features, fixing
  bugs, writing tests, reviewing code, or when the user asks for checklist,
  regression, unit test, widget test, or manual E2E verification.
---

# QA & Testing — home_manager

Read [`.cursor/docs/qa/README.md`](../../docs/qa/README.md) first, then follow this skill.

## When to use

- New feature or screen
- Bug fix (especially validation, meter math, duplicate period, auth)
- User asks to test like a QA / add checklist / add unit tests
- Before opening a PR

## Mandatory 6-step workflow

1. **Identify module** — read [v1-feature-inventory.md](../../docs/qa/v1-feature-inventory.md); note affected rows.
2. **Checklist** — copy [checklist-template.md](../../docs/qa/checklist-template.md) to `checklists/<feature>.md` for new work; tick items as you go.
3. **Plan** — goal, scope, files from [CODEBASE_MAP.md](../../CODEBASE_MAP.md).
4. **Implement** — extract pure logic to `lib/core/domain/` when unit tests are needed (validation, date/month helpers).
5. **Automated tests** — follow [test-map.md](../../docs/qa/test-map.md):
   - `test/unit/` — domain, models, formatters, pure service helpers
   - `test/widget/` — UI states, validation messages, banners
   - `test/integration/` — service behavior with mocks in `test/support/`
6. **Verify** — `flutter analyze && flutter test`; update manual E2E IDs in [v1-manual-e2e.md](../../docs/qa/v1-manual-e2e.md) if user-facing.

## Test pyramid

| Layer | Directory | When |
|-------|-----------|------|
| Unit | `test/unit/` | Pure functions, `fromJson`, `monthKey`, validation |
| Widget | `test/widget/` | Pump widgets with fake session/services |
| Integration | `test/integration/` | Service orchestration with `mocktail` fakes |
| Manual | `docs/qa/v1-manual-e2e.md` | Chrome required; Safari/iPhone for PWA/storage |

## Conventions

- **Fakes:** `test/support/fakes/` — record calls, no real Supabase.
- **Fixtures:** `test/support/fixtures/` — sample JSON for models.
- **Mock Supabase:** `test/support/mock_supabase.dart` — minimal chain mocks via `mocktail`.
- **Do not** commit bill photos, service role keys, or `.env` in tests.
- Match existing test style: double quotes, descriptive test names.

## PR test plan (required)

When creating a PR, include:

- Link to checklist file (or E2E IDs touched)
- List of new/updated test files
- `flutter test` result summary
- Manual steps for Chrome (copy from checklist)

## Related

- Rule: [`.cursor/rules/04-testing.mdc`](../../rules/04-testing.mdc)
- Domain rules: [home-manager-domain/SKILL.md](../home-manager-domain/SKILL.md)
- Git/PR: [git-workflow/SKILL.md](../git-workflow/SKILL.md)
