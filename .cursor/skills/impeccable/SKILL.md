---
name: impeccable
description: >-
  Design, redesign, polish, layout, type, color, motion, empty states, and
  craft for home_manager (Tổ Ấm): Flutter Material 3, mobile-first, Web PWA +
  iOS Simulator. Use when the user wants to change or implement a screen,
  widget, theme, or visual system. Not for backend, schema, or RLS. Not for
  read-only screenshot reviews or item-by-item completeness — those belong to
  checklist-design.
---

# Impeccable — Tổ Ấm (Flutter)

Craft UI for **Tổ Ấm**: Material 3, phone-sized, Vietnamese, Web PWA + iOS
Simulator. Complete deliverables, a clear POV, production Flutter. Verify in
bounded passes — not an open polish loop.

## vs checklist-design

These skills must not steal each other's jobs.

| Ask | Skill |
|---|---|
| Change, redesign, polish, implement UI | **impeccable** (this skill) |
| "Does this look right?", completeness, named checklist (Login, Settings, …), screenshot/mockup review | **checklist-design** (read-only) |

If they say "critique" or "audit" **and** share a screenshot / ask whether a checklist is covered → **checklist-design**. If they name this skill or ask you to **fix** the UI → stay here. Never run both on the same turn unless they ask.

## Product constraints

- Flutter 3.29, Material 3, `lib/` widgets. No HTML/CSS. No Android.
- Same widget tree on PWA and Simulator. Copy in `S` (`lib/core/l10n/strings.dart`).
- Tokens: `AppTheme`, `AppColorScheme`, `AppSpacing`, `AppAccent`, `AppIcons`, `AppFonts.nunito`.
- `MobileViewport` (max 480). Touch 48 (`AppSpacing.touchMin`). Safe area via `SafeArea` / `safeBottomPaddingOf`.
- Operate mode. Scanability beats spectacle.

Also: **qa-testing** after user-visible behavior changes; **home-manager-domain** for product rules.

## Setup

1. Read `PRODUCT.md`, `DESIGN.md`, and [references/flutter.md](references/flutter.md).
2. Load one playbook from the table below (or [references/new-work.md](references/new-work.md) for a new surface). Inspect the target **and** `lib/core/theme/` plus shared widgets before editing.
3. Before editing UI, load [references/craft-floor.md](references/craft-floor.md) and apply the Flutter translation in flutter.md. Skip for planning-only work.

Playbooks may mention `ios.md`, Android, `detect.mjs`, live overlay, or CSS. **Ignore those.** flutter.md wins. Do not run Node live/detector scripts.

## How to design

- Honor the incumbent world (DESIGN.md + theme). Do not redirect toward a landing page, Cupertino rebuild, or a second identity.
- Refinement preserves identity, behavior, copy, and out-of-scope screens. Ask before replacing factual copy.
- Local screens **extend** the system (no concept tournament) unless they explicitly ask for a rebrand.

## Commands

| Command | Use | Reference |
|---|---|---|
| `shape [feature]` | Plan UX before code | [references/shape.md](references/shape.md) |
| `document` | Refresh DESIGN.md from theme + shared widgets | [references/document.md](references/document.md) |
| `extract [target]` | Promote one-off style into theme/shared widgets | [references/extract.md](references/extract.md) |
| `critique [target]` | Craft review that should lead to edits — not a checklist pass | [references/critique.md](references/critique.md) |
| `audit [target]` | Technical a11y, tokens, insets, lists (code) | [references/audit.md](references/audit.md) |
| `polish [target]` | Final pass before ship | [references/polish.md](references/polish.md) |
| `bolder` / `quieter` / `distill` | Expression within Operate | matching `references/*.md` |
| `harden` | Errors, empty states, text scale (VN only) | [references/harden.md](references/harden.md) |
| `onboard` | First-run, empty homes, empty lists | [references/onboard.md](references/onboard.md) |
| `animate` / `colorize` / `typeset` / `layout` / `delight` | Enhance, still Material 3 | matching `references/*.md` |
| `clarify` | Labels and errors in `S.*` | [references/clarify.md](references/clarify.md) |
| `adapt` | Phone / PWA / Simulator | [references/adapt.md](references/adapt.md) |
| `optimize` | Jank, rebuilds, image decode | [references/optimize.md](references/optimize.md) |

No-argument: recommend 2–3 of `polish`, `layout`, `audit` on a named `lib/features/...` surface. Never auto-run.

Skip: live overlay, HTML detector, Android, marketing `overdrive`, web framework adapters.

## Verify

- Widget/unit tests per **qa-testing** when behavior or states change.
- `dart format` on edited files; `flutter analyze` && `flutter test` before done.
- UI proof: iPhone Simulator and/or Chrome ~390px — see flutter.md.
- One batched inspect, one fix batch, at most one confirm round. Stop.
