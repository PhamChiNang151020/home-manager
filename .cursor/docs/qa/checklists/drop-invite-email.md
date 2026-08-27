# Feature checklist — Drop Resend invite email

Link inventory IDs: INV-01, TC-INV-01, TC-INV-02.

## Goal

Stop sending invite mail. Owner shares QR/link, or records a Google email so login matching still joins.

## Scope

- In scope: remove Edge Function invoke, Gửi lại, sent/failed copy; keep `invite_to_home` + QR
- Out of scope: dropping `email_sent_at` columns; buying a sending domain

## Files (from CODEBASE_MAP)

- `lib/features/settings/settings_members_page.dart`
- `lib/core/services/invite_service.dart`
- `lib/core/domain/invite_email.dart`
- `lib/core/l10n/strings.dart`
- `supabase/functions/send-home-invite/` (delete)

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Invite RPC still creates pending row
- [x] Pending tile has cancel only (no Gửi lại)

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/invite_email_test.dart` | reject rules only (no Resend parse) |
| Widget | `test/widget/settings_members_page_test.dart` | overlay on invite RPC |

## Manual E2E

- [ ] TC-INV-01
- [ ] TC-INV-02
- [ ] TC-INV-03

**Browser:** Chrome

## Regression (bug fix only)

- [x] Root cause documented (no owned domain; Resend testing-only recipients)
- [x] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
