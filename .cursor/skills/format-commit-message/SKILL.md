---
name: format-commit-message
description: >-
  Drafts and validates git commit messages for home_manager using
  bracket tags ([FIX], [FEATURE], [REFACTOR], [BUILD], [DOCS], [CHORE]) and
  optional tickets. Use when the user asks to commit, write a commit message,
  review staged changes for commit, or mentions commit format/convention.
---

# Format commit message (home_manager)

Same convention as `flutter_sdk_switcher` / SuperApp Mobile bracket tags, adapted for this repo.

Also follow `.cursor/rules/03-git-workflow.mdc` and `.cursor/skills/git-workflow/SKILL.md`. **Do not commit** until the user confirms the message (and explicitly asked to commit).

## Message shape

**Preferred (one line subject):**

```text
[TYPE]: Short description in English
[TYPE]-[POTxxxx-y]: Short description
[TYPE][POTxxxx-y]: Short description
[TYPE]: Short description (#42)
```

**Rules:**

- Always start with a **bracket tag** (uppercase).
- Subject: one line, English, imperative; explain **why/outcome**, not every file touched.
- Optional ticket: `POT4720-12` or GitHub `#issue`.
- Two unrelated changes → **two commits** or one PR title with clear scope.
- Avoid untagged subjects (`tidy up code`, bare feature names).

## Type tag — pick one

| Tag | Use when |
| --- | --- |
| `[FIX]` | Bug fix, wrong behavior, regression |
| `[FEATURE]` | New capability (UI, storage, PWA, screens) |
| `[REFACTOR]` | Structure/cleanup; same product intent |
| `[BUILD]` | Version bump, `pubspec.yaml` version, web/PWA packaging |
| `[DOCS]` | README, `.cursor/docs`, rules/skills docs only |
| `[CHORE]` | Tooling, `.gitignore`, CI, no product behavior change |
| `[TEST]` | Tests only |

Mixed types → split commits (e.g. `[BUILD]: Bump version to 0.2.0` separate from `[FEATURE]: …`).

## Drafting workflow

1. Run `git diff` (staged if committing) and list changed areas.
2. Choose **one primary `[TYPE]`** per commit.
3. Add `[POT…]` or `(#nnn)` if mapped to a ticket/issue.
4. Sanity check:
   - `web/**`, `pubspec.yaml` version → often `[BUILD]` or split BUILD from feature.
   - Only `.cursor/**` or README → `[DOCS]` or `[CHORE]` if config-only.
5. Propose 1–2 subject lines; user picks or edits before `git commit`.

## Pass commit message to git

```bash
git commit -m "$(cat <<'EOF'
[TYPE]: Subject here.

EOF
)"
```

Body is optional; subject-only is fine.

## Do not commit

- `build/`, `.dart_tool/`, machine-local secrets, `.idea/` (see `.gitignore`).
- Household data, bill photos, export files.
- Unrelated drive-by edits in one vague message.

## Examples

| Diff intent | Message |
| --- | --- |
| Initial web scaffold | `[FEATURE]: Scaffold Flutter Web app for home management` |
| Hive storage | `[FEATURE]: Add local Hive storage for bills and expenses` |
| Cursor rules + skills | `[DOCS]: Add project Cursor rules and commit message skill` |
| Version in pubspec | `[BUILD]: Bump app version to 0.2.0` |
| Lint-only cleanup | `[REFACTOR]: Align home widgets with code style rule` |
| Backup export bug | `[FIX]: Keep photo blobs when exporting household backup` |

More patterns: [examples.md](examples.md).
