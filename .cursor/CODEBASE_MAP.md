# CODEBASE_MAP — home_manager (Flutter Web)

Consult this file before grepping the repo. Update when adding modules under `lib/`.

## Entry & shell

| Item | Path |
|------|------|
| Process entry | `lib/main.dart` |
| Root widget | `lib/main.dart` → `MaterialApp` (split to `lib/app.dart` when shell grows) |
| Planned UI shell | `lib/features/shell/` — Home, Utilities, Expenses, Shopping, Bills |

## Feature screens (planned)

| Area | Path |
|------|------|
| Home / overview | `lib/features/home/` |
| Điện / nước | `lib/features/utilities/` |
| Chi tiêu | `lib/features/expenses/` |
| Danh sách mua | `lib/features/shopping/` |
| Ảnh hoá đơn | `lib/features/bills/` |

## Core (planned)

| Item | Path |
|------|------|
| Models | `lib/core/models/` — `utility_bill.dart`, `expense.dart`, `shopping_item.dart` |
| Local storage | `lib/core/services/storage_service.dart` (Hive / IndexedDB) |
| Export / import backup | `lib/core/services/backup_service.dart` |

## Web / PWA

| Item | Path |
|------|------|
| HTML shell | `web/index.html` |
| PWA manifest | `web/manifest.json` (name: Home Manager, short_name: Nhà cửa) |
| Icons | `web/icons/`, `web/favicon.png` |

## Tests

| Item | Path |
|------|------|
| Widget smoke | `test/widget_test.dart` |

## File inventory

Keep this map in sync when adding folders under `lib/` or `test/`. No auto-sync script yet — edit curated tables above.

### Current tree

- `lib/main.dart` — default Flutter counter scaffold (to be replaced)
- `test/widget_test.dart`
- `web/` — Flutter Web + PWA assets
