# Critique (impeccable)

This is **not** the checklist-design critique. If the user shared a screenshot
or asked whether a Login/Settings/Dashboard checklist is covered, stop and use
**checklist-design** instead.

Use this file only when they want a craft review that is meant to **lead to
edits** (or they named impeccable).

## Evidence

Need to see the UI: Simulator screenshot, Chrome phone-width, or a capture they
attached. Source alone can support token/inset notes; say when you cannot judge
layout or contrast without a picture.

Do not run `detect.mjs` or a browser HTML overlay.

## Pass

1. Read DESIGN.md, [flutter.md](flutter.md), and the target widget.
2. Note strengths (at least two you believe).
3. Name a short backlog: hierarchy, spacing, type, color, touch, empty/error,
   platform slop (web-port, Cupertino costume, one-off hex).
4. Point each item at a follow-up command (`layout`, `typeset`, `polish`, …)
   or a concrete widget change.
5. Ask which items to implement. Do not start editing unless they asked to fix
   it in the same turn.
