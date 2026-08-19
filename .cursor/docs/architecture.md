# Architecture — home_manager

## Problem

Track household costs (electricity, water, spending, shopping list, bill photos) on a personal iPhone **without** App Store or Developer Mode. Data stays on-device first.

## Layers

1. **UI (Flutter Web)** — Material 3 screens; mobile-first; PWA standalone display.
2. **Domain** — bills, expenses, shopping items; no UI imports in models/services.
3. **Storage** — Hive on web (IndexedDB). Optional later: cloud sync.

## Data shapes (v1)

```text
UtilityBill  { id, type: dien|nuoc, oldReading, newReading, amount, date, photoId?, note }
Expense      { id, category, amount, date, note }
ShoppingItem { id, name, quantity?, isDone, createdAt }
```

Bill photos: compress JPEG locally, store as Hive binary / blob. Do not upload unless Phase 2 is approved.

## Persistence

- Single `StorageService` owns Hive boxes.
- Widgets never open boxes directly.
- Export dumps JSON (+ photos zip later). Import replaces or merges with an explicit UX choice.

## PWA

- `web/manifest.json` `display: standalone`.
- After hosting deploy, iPhone: Safari → Share → Add to Home Screen.
- Warn in-app that clearing Safari website data can wipe local storage.

## Error cases

- Quota exceeded (too many photos) — prompt compress / export / delete old bills.
- Corrupt Hive box — recover via last export if present; otherwise empty-state + message.
