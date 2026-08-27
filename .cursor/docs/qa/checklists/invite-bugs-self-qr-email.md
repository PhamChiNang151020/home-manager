# Feature checklist — Invite bugs (self / QR / email)

Link inventory IDs: INV-01, INV-03, INV-04, HOME-04.

## Goal

Owner cannot invite an existing member (including themselves). Scanning the join QR adds the invitee and switches to that home. Email invite actually sends (or shows a clear Resend error).

## Scope

- In scope:
  - Reject self-invite and existing member emails (UI + RPC)
  - Persist `?join=` before Flutter/PWA can drop it (`join.html` + localStorage)
  - Select the joined home after `accept_invite_token`
  - Edge Function join-link parse + `join.html` URL
- Out of scope:
  - Resend domain verification / production from-address (manual secrets)

## Files (from CODEBASE_MAP)

- `lib/core/domain/invite_email.dart`
- `lib/core/domain/join_link.dart`
- `lib/core/domain/selected_home.dart`
- `lib/core/services/join_link_store.dart`
- `lib/core/services/auth_service.dart`
- `lib/core/state/session_controller.dart`
- `lib/features/settings/settings_members_page.dart`
- `web/join.html`, `web/index.html`
- `supabase/migrations/20260827090000_invite_reject_existing.sql`
- `supabase/functions/send-home-invite/index.ts`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Owner email / existing member email blocked
- [x] Pending duplicate email blocked
- [x] Hash `#/?join=` captured
- [x] After join, `preferId` selects the new home even if another home was selected
- [ ] Resend Edge Function delivers mail (manual: deploy function + secrets + migration)

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/invite_email_test.dart` | self / member / pending / valid |
| Unit | `test/unit/join_link_test.dart` | join.html URL, hash, OAuth app URL |
| Unit | `test/unit/selected_home_test.dart` | preferId |
| Unit | `test/unit/join_link_store_test.dart` | hash capture |
| Widget | `test/widget/settings_members_page_test.dart` | QR still renders |

## Manual E2E

- [ ] TC-INV-01 — mời email không phải thành viên hiện có
- [ ] TC-INV-02 — login đúng email thấy nhà
- [ ] TC-INV-03 — B quét QR, login Google khác A, thấy nhà của A

**Browser:** Chrome · Safari/iPhone if [PWA]

## Regression (bug fix only)

- [x] Root cause documented (query dropped before Dart; no self-invite check; join link jsonb / Resend)
- [x] Unit/widget test prevents recurrence
- [ ] Manual repro steps no longer fail

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
