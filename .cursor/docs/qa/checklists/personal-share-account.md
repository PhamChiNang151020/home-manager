# Feature checklist — Personal hub, share, account

Link inventory IDs: HOME-05, HOME-06, INV-04, SET-04, TC-HOME-07, TC-INV-01, TC-INV-05.

## Goal

Owner can remove a member; invite is QR/link only; Chia sẻ shows a QR placeholder while the code loads; leave-home lives under Nhà đang quản lý; Cá nhân tiles are title-only; Tài khoản lists real account facts.

## Scope

- In scope:
  - RPC `remove_home_member` + confirm on Thành viên
  - Drop email-invite form / pending list from Chia sẻ
  - `JoinQrPlaceholder` while `createOrGetJoinLink` runs
  - `ManagedHomePage` (switch / add / leave)
  - Account cards (Google, home, role)
- Out of scope:
  - Delete leftover `invite_to_home` RPC / `home_invites` rows
  - Transfer ownership without leaving

## Files (from CODEBASE_MAP)

- `supabase/migrations/20260827110000_remove_home_member.sql`
- `lib/core/services/home_service.dart`
- `lib/features/settings/settings_members_page.dart`
- `lib/features/settings/settings_account_page.dart`
- `lib/features/personal/personal_hub_page.dart`
- `lib/features/personal/managed_home_page.dart`
- `lib/features/personal/leave_home_sheet.dart`
- `lib/features/shell/home_picker_sheet.dart`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Owner cannot remove self or another owner
- [x] QR placeholder then QR; no email invite fields
- [x] Leave is not a red button on Cá nhân hub
- [x] Cá nhân hub tiles have no subtitle
- [x] Tài khoản shows name / Google / home / role without a spacer void

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Widget | `test/widget/settings_members_page_test.dart` | QR placeholder; remove member; no email form |
| Widget | `test/widget/managed_home_page_test.dart` | current home + leave |
| Widget | `test/widget/settings_account_page_test.dart` | Google facts + home |
| Integration | `test/integration/home_service_test.dart` | `remove_home_member` params |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

Link TC IDs from [v1-manual-e2e.md](../v1-manual-e2e.md):

- [ ] TC-HOME-05
- [ ] TC-HOME-06
- [ ] TC-HOME-07
- [ ] TC-INV-01
- [ ] TC-INV-03
- [ ] TC-INV-05

**Browser:** Chrome · Safari/iPhone if [PWA]

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
