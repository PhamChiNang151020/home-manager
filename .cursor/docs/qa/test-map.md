# Test map — checklist ID → automated test

Cập nhật khi thêm test file. Agent dùng bảng này để phát hiện gap.

| Checklist ID | Test name | File | Status |
|--------------|-----------|------|--------|
| CFG-01 | missing config screen | `test/widget/missing_config_test.dart` | done |
| ELEC-M01 | meter math uses delta times rate | `test/unit/meter_math_test.dart` | done |
| ELEC-M01 | consumption zero edge | `test/unit/meter_math_test.dart` | done |
| ELEC-M02 | missing readings returns error | `test/unit/electricity_validation_test.dart` | done |
| ELEC-M03 | new less than prev returns error | `test/unit/electricity_validation_test.dart` | done |
| ELEC-M04 | auto-fill previous from period | `test/widget/electricity_form_test.dart` | planned |
| ELEC-M05 | findPeriodForMonth finds duplicate | `test/unit/period_month_conflict_test.dart` | done |
| ELEC-M05 | excludeId skips editing period | `test/unit/period_month_conflict_test.dart` | done |
| ELEC-M06 | edit change month deletes old | `test/integration/electricity_service_test.dart` | done |
| ELEC-M07 | delete period called | `test/integration/electricity_service_test.dart` | done |
| ELEC-M02 | meter form missing readings UI | `test/widget/electricity_form_test.dart` | done |
| ELEC-M03 | meter form invalid readings UI | `test/widget/electricity_form_test.dart` | done |
| ELEC-M05 | duplicate hint on form | `test/widget/electricity_form_test.dart` | done |
| ELEC-I02 | invalid amount returns error | `test/unit/electricity_validation_test.dart` | done |
| ELEC-M06 / M07 | shouldDeleteOriginalPeriod when month changed | `test/unit/electricity_period_edit_test.dart` | done |
| ELEC-M06 / M07 | shouldDeleteOriginalPeriod false same month | `test/unit/electricity_period_edit_test.dart` | done |
| ELEC-M05 | monthKey formats yyyy-MM-01 | `test/unit/electricity_period_edit_test.dart` | done |
| PHOTO-01 | pathFor homes/id/yyyy-mm.jpg | `test/unit/bill_photo_service_test.dart` | done |
| REM-01 | clamp 31 in February | `test/unit/day_of_month_test.dart` | done |
| REM-01 | isToday with injected now | `test/unit/day_of_month_test.dart` | done |
| REM-01 | banner shows on photo due day | `test/widget/reminder_banner_test.dart` | done |
| SET-02 | ics includes all three events | `test/unit/ics_export_service_test.dart` | done |
| SET-02 | ics omits events when days null | `test/unit/ics_export_service_test.dart` | done |
| FMT-01 | format and parse vi_VN | `test/unit/vnd_format_test.dart` | done |
| FMT-01 | compact k and tr labels | `test/unit/vnd_format_test.dart` | done |
| AUTH-03 | auth gate loading state | `test/widget/auth_gate_test.dart` | planned |
| AUTH-02 | native OAuth uses system browser | `test/unit/oauth_launch_mode_test.dart` | done |
| AUTH-01 / INV-04 | web OAuth redirectTo has no `?join=` | `test/unit/oauth_redirect_test.dart` | done |
| UI-03 | iOS bottom nav home-indicator inset | `test/unit/safe_bottom_inset_test.dart`, `test/widget/app_bottom_nav_test.dart` | done |
| HOME-03 | selectHome updates selected | `test/integration/session_controller_test.dart` | planned |
| HOME-03 | resolveSelectedHome prefers persisted id | `test/unit/selected_home_test.dart` | done |
| HOME-05 | member / owner / sole-owner leave sheet | `test/widget/leave_home_sheet_test.dart` | done |
| HOME-05 | leaveHome RPC params | `test/integration/home_service_test.dart` | done |
| HOME-05 | leave lives on managed home page | `test/widget/managed_home_page_test.dart` | done |
| HOME-06 | owner remove member confirm | `test/widget/settings_members_page_test.dart` | done |
| HOME-06 | removeMember RPC params | `test/integration/home_service_test.dart` | done |
| WAT-01 | water meter validation | `test/unit/water_validation_test.dart` | done |
| WAT-02 | water upsert is_paid / month change | `test/integration/water_service_test.dart` | done |
| WAT-03 | pathFor water subfolder | `test/unit/bill_photo_service_test.dart` | done |
| WAT-04 | Home.fromJson m3_rate | `test/unit/home_water_model_test.dart` | done |
| EXP-01 | spendByCategory / fromJson | `test/unit/expense_totals_test.dart` | done |
| EXP-02 | expense form invalid amount | `test/widget/expense_form_test.dart` | done |
| INC-01 | MonthBalance net | `test/unit/month_balance_test.dart` | done |
| ICO-01 | expense icon_key maps to PNG | `test/unit/app_icons_test.dart` | done |
| OVW-01 | overview summary card | `test/widget/overview_summary_card_test.dart` | done |
| OVW-02 | month clamp and stepper next disabled | `test/unit/month_clamp_test.dart`, `test/widget/month_stepper_field_test.dart` | done |
| OVW-03 | balancesForMonths and MoM percent | `test/unit/month_balance_test.dart` | done |
| PWA-01 | PWA install UA and share URL | `test/unit/pwa_install_test.dart` | done |
| PWA-02 | install banner and QR page | `test/widget/install_home_screen_test.dart` | done |
| UI-01 | select sheet reports tap, ignore dismiss | `test/widget/select_sheet_test.dart` | done |
| UI-02 | period detail stacked rows + unpaid badge | `test/widget/period_detail_view_test.dart` | done |
| REM-02 | same-day reminder order photo → payday → remind | `test/widget/reminder_banner_test.dart` | done |
| ELEC-M05 | upsert omits is_paid when null | `test/integration/electricity_service_test.dart` | done |
| INV-01 | reject self / existing member email | `test/unit/invite_email_test.dart` | done |
| INV-01 | HomeInvite email_sent_at parse | `test/unit/home_invite_test.dart` | done |
| INV-01 | invite RPC returns invite id | `test/integration/invite_service_test.dart` | done |
| INV-01 | send invite uses full-page overlay | `test/widget/settings_members_page_test.dart` | removed |
| INV-01 | pending invite has no resend mail | `test/widget/settings_members_page_test.dart` | removed |
| WAL-01 | Wallet model parse | `test/unit/wallet_model_test.dart` | done |
| WAL-02 | transfer / applyExpense RPC | `test/integration/wallet_service_test.dart` | done |
| WAL-01 | wallet hub copy | `test/widget/wallet_hub_page_test.dart` | done |
| INV-03 | Home.fromJson parses fields | `test/unit/models_test.dart` | planned |
| INV-04 | prefer just-joined home after QR accept | `test/unit/selected_home_test.dart` | done |
| INV-04 | parse ?join= and native scheme | `test/unit/join_link_test.dart` | done |
| INV-04 | persist pending join token | `test/unit/join_link_store_test.dart` | done |
| INV-04 | owner join QR actions | `test/widget/settings_members_page_test.dart` | done |
| INV-04 | QR placeholder while join link loads | `test/widget/settings_members_page_test.dart` | done |
| INV-04 | members page has no email invite form | `test/widget/settings_members_page_test.dart` | done |
| INV-04 | create / accept / revoke join RPCs | `test/integration/invite_service_test.dart` | done |
| UI-04 | empty state description + primary action | `test/widget/empty_state_view_test.dart` | done |
| UI-05 | tab change fires haptic, same tab does not | `test/widget/app_bottom_nav_test.dart` | done |
| UI-06 | bill photo preview, constraint hint, remove | `test/widget/bill_photo_pick_field_test.dart` | done |
| SET-03 | isFormDirty gates the save button | `test/unit/form_dirty_test.dart` | done |
| SET-04 | account page lists Google facts and home | `test/widget/settings_account_page_test.dart` | done |
| LOG-01 | AppLog formats time, level, name, error | `test/unit/app_log_test.dart` | done |
| A11Y-01 | text ramp clears 4.5:1 on every surface, both themes, all 4 accents | `test/unit/color_contrast_test.dart` | done |
| A11Y-02 | status colours and accent fills clear 4.5:1 | `test/unit/color_contrast_test.dart` | done |
| A11Y-03 | selected tab is never fainter than an unselected one | `test/unit/color_contrast_test.dart` | done |
| FMT-02 | compact shortens negative amounts | `test/unit/vnd_format_test.dart` | done |
| UI-07 | cards and plain surfaces share one horizontal inset | `test/widget/horizontal_alignment_test.dart` | done |
| UI-08 | a full-height sheet header stays clear of the status bar | `test/widget/app_sheet_test.dart` | done |
| UI-09 | no sheet bypasses `showAppSheet` (double handle / safe area) | `test/widget/app_sheet_test.dart` | done |
| UI-10 | pull-to-refresh shows the branded overlay, not Material's disc | `test/widget/app_refresh_indicator_test.dart` | done |
| UI-11 | glass toggle persists; frosted surface when on | `test/widget/app_glass_surface_test.dart` | done |
| UI-12 | AppIcon renders tinted Material IconData | `test/widget/app_icon_test.dart` | done |

## Test layout

```
test/
├── unit/           # 9 files (Phase 1)
├── widget/         # 1 file (Phase 1); expand Phase 2–3
├── integration/    # Phase 2+
└── support/
    ├── fixtures/
    └── mock_supabase.dart
```
