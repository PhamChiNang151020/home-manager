# CODEBASE_MAP — home_manager (Flutter Web)

Consult this file before grepping the repo. Update when adding modules under `lib/`.

## Entry & shell

| Item | Path |
|------|------|
| Process entry | `lib/main.dart` (Supabase init + session) |
| Root widget | `lib/app.dart` → `HomeManagerApp` / `MissingConfigApp` |
| Auth gate | `lib/app.dart` + `lib/features/auth/sign_in_page.dart` |
| Main shell | `lib/features/shell/app_shell.dart` (Điện / Cài đặt) |
| Session | `lib/core/state/session_controller.dart` |

## Feature screens

| Area | Path |
|------|------|
| Sign in | `lib/features/auth/sign_in_page.dart` |
| Create home | `lib/features/homes/create_home_dialog.dart` |
| Electricity list + form | `lib/features/electricity/electricity_page.dart`, `electricity_form.dart` |
| Reminder banner | `lib/features/electricity/reminder_banner.dart` |
| Settings, invite, ICS | `lib/features/settings/settings_page.dart` |

## Core

| Item | Path |
|------|------|
| Config | `lib/core/config/app_config.dart` |
| Copy (VI) | `lib/core/l10n/strings.dart` |
| Meter math / day clamp | `lib/core/domain/meter_math.dart` |
| Models | `lib/core/models/home.dart`, `electricity_period.dart`, `tracking_mode.dart` |
| Auth / homes / invites | `lib/core/services/auth_service.dart`, `home_service.dart`, `invite_service.dart` |
| Periods + photos | `lib/core/services/electricity_service.dart` |
| ICS + download | `lib/core/services/ics_export_service.dart`, `web_file_saver.dart` |

## Supabase

| Item | Path |
|------|------|
| Migration | `supabase/migrations/20260819000000_init.sql` |
| Setup | `supabase/README.md` |

## Web / PWA / CI

| Item | Path |
|------|------|
| HTML | `web/index.html` |
| Manifest | `web/manifest.json` |
| Pages notes | `.cursor/docs/github-pages.md` |
| Web Push (later) | `.cursor/docs/web-push.md` |

## Tests

| Item | Path |
|------|------|
| Meter math + missing config | `test/widget_test.dart` |
| ICS export | `test/ics_export_service_test.dart` |

### Feature modules (`lib/features/`)

- `lib/features/auth/` — sign_in_page.dart
- `lib/features/electricity/` — electricity_form.dart, electricity_page.dart, reminder_banner.dart
- `lib/features/homes/` — create_home_dialog.dart
- `lib/features/settings/` — settings_page.dart
- `lib/features/shell/` — app_shell.dart

### Core services (`lib/core/services/`)

- `lib/core/services/auth_service.dart`
- `lib/core/services/bill photo` — in electricity_service.dart (`BillPhotoService`)
- `lib/core/services/electricity_service.dart`
- `lib/core/services/home_service.dart`
- `lib/core/services/ics_export_service.dart`
- `lib/core/services/invite_service.dart`
- `lib/core/services/web_file_saver.dart` (+ `_web.dart` / `_stub.dart`)
