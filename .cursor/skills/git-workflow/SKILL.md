---
name: git-workflow
description: >-
  Git commit and pull request workflow for home_manager on GitHub
  (PhamChiNang151020/home-manager). Use when the user asks to commit,
  push, open a PR, or follow repo git conventions.
---

# Git workflow — home_manager

## Repository

- URL: `https://github.com/PhamChiNang151020/home-manager.git`
- Default branch: `main`

## When to use

- User explicitly asks to **commit**, **push**, or **create a PR**
- User asks how this repo handles git

## Commit protocol

1. Run in parallel: `git status`, `git diff`, `git log -1 --oneline` (style reference).
2. Stage **only** relevant paths (never `git add .` unless user explicitly requests).
3. Draft subject using **`.cursor/skills/format-commit-message/SKILL.md`**; user confirms before commit.
4. Commit with HEREDOC message.
5. `git status` after commit to verify.

**Do not commit** unless the user asked in this conversation.

## Pull request protocol

1. Parallel: status, diff, tracking branch, `git log main..HEAD`, full diff vs `main`.
2. Push with `-u` if needed (`gh` / network permissions as required).
3. `gh pr create` with Summary + Test plan.

## Project-specific

- Keep `.cursor/` tracked — rules, docs, and skills belong in git.
- Do not commit `build/`, `.dart_tool/`, or IDE junk (see root `.gitignore`).
- Do not commit user data: Hive dumps, bill photos, export JSON.

## Related Cursor guidance

User-level rules for git may also apply (commit safety, no amend unless conditions met). Prefer **stricter** rule when in doubt.
