# Feature checklist — Leave home

Link inventory IDs from [v1-feature-inventory.md](../v1-feature-inventory.md): HOME-05.

## Goal

Thành viên tự rời nhà; giữ chi tiêu / thu nhập / hoá đơn. Chủ nhà rời được sau khi chuyển quyền.

## Scope

- In scope: RPC `leave_home`, soft-delete `left_at`, sheet trên Cá nhân, rejoin = member, reminder push bỏ người đã rời.
- Out of scope: chủ nhà đuổi thành viên; chuyển quyền mà không rời; xóa/gán lại chi tiêu.

## Files (from CODEBASE_MAP)

- `supabase/migrations/20260827100000_leave_home.sql`
- `lib/core/services/home_service.dart`
- `lib/features/personal/leave_home_sheet.dart`
- `lib/features/personal/personal_hub_page.dart`
- `supabase/functions/send-reminder-push/index.ts`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Chủ nhà một mình không rời — gợi ý Xóa nhà
- [x] Chủ nhà phải chọn người nhận quyền
- [x] Chi tiêu `paid_by` người đã rời vẫn hiện tên (profile via `shares_home_with`)
- [x] Vào lại nhà (QR / email) = member, `left_at` xóa

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Widget | `test/widget/leave_home_sheet_test.dart` | copy giữ lịch sử; owner picker; chủ một mình |
| Integration | `test/integration/home_service_test.dart` | RPC params member / transfer |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

Link TC IDs from [v1-manual-e2e.md](../v1-manual-e2e.md):

- [ ] TC-HOME-05
- [ ] TC-HOME-06

**Browser:** Chrome · Safari/iPhone if [PWA]

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
- [ ] PR Test plan lists checklist + test files
