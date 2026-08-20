# Feature checklist — Overview UX polish

Copy from template. Link inventory IDs from [v2-feature-inventory.md](../v2-feature-inventory.md).

## Goal

Làm rõ Tổng quan (stepper tháng, lưới mini, biểu đồ MoM), thống nhất loading quanh logo, đồng bộ dropdown.

## Scope

- In scope: home picker subtitle, month clamp app-wide, overview grid/chart, branded loader (size 88), MonthStepper Chi tiêu/Thu nhập, dropdown → bottom sheet
- Out of scope: Lottie, prev/next trên form điện/nước, đổi layout list điện/nước / fullscreen bill photo

## Files (from CODEBASE_MAP)

- `lib/features/overview/`
- `lib/features/expenses/expenses_page.dart`, `lib/features/income/income_page.dart`
- `lib/features/shared/month_picker.dart`, `month_stepper_field.dart`, `app_loading.dart`, `labeled_text_field.dart`, `select_sheet.dart`
- `lib/core/domain/month_clamp.dart`, `month_balance.dart`

## Functional checklist

- [ ] Happy path works on Chrome
- [ ] Empty / error states handled
- [ ] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [ ] No Supabase calls from widgets (services only)

## Edge cases

- [ ] Next month disabled on current month
- [ ] Date/month pickers cannot select the future

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/month_clamp_test.dart` | clamp / shift / next disabled |
| Unit | `test/unit/month_balance_test.dart` | 6-month fold + MoM % |
| Widget | `test/widget/month_stepper_field_test.dart` | next button |
| Widget | `test/widget/overview_summary_card_test.dart` | spend delta chip |
| Widget | `test/widget/app_loading_test.dart` | branded AppLoader size 88 |
| Widget | `test/widget/select_sheet_test.dart` | dropdown field opens sheet |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

Link TC IDs from [v1-manual-e2e.md](../v1-manual-e2e.md):

- [ ] TC-OVW-01
- [ ] TC-OVW-02
- [ ] TC-EXP-02
- [ ] TC-INC-01

**Browser:** Chrome

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] Inventory + test-map updated
