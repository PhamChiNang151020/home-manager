# Feature checklist — Invite email Resend + overlay loading

Link inventory IDs: INV-01, TC-INV-01.

## Goal

Owner sees a full-page loading overlay while sending an invite email, and a Vietnamese error that names the Resend failure (not `Exception: resend failed`).

## Scope

- In scope:
  - `LoadingOverlay` on Chia sẻ / members while send or QR mutate
  - Parse Resend `detail` from Edge Function; map testing-mode to copy
  - Edge Function returns Resend `message` as `error`
- Out of scope:
  - Verifying a Resend domain / rotating API keys (dashboard, owner)

## Files (from CODEBASE_MAP)

- `lib/features/settings/settings_members_page.dart`
- `lib/core/domain/invite_email.dart`
- `lib/core/services/invite_service.dart`
- `lib/core/l10n/strings.dart`
- `supabase/functions/send-home-invite/index.ts`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Opaque `resend failed` unwraps Resend JSON `message`
- [x] Testing-mode restriction (only send to Resend account email) has recovery copy
- [x] Send / Gửi lại uses `AppLoadingScrim`, not compact spinner on the button

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/invite_email_test.dart` | payload parse + classify testing |
| Widget | `test/widget/settings_members_page_test.dart` | overlay while send hangs |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

- [ ] TC-INV-01

**Browser:** Chrome

## Regression (bug fix only)

- [x] Root cause documented (Resend testing recipient + opaque error; button-local loader)
- [x] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail (needs Resend domain or invite to Resend account email)

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
