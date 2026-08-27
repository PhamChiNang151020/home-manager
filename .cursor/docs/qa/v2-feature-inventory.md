# v2 Feature inventory — home_manager

Status: `[ ]` chưa có automated test · `[x]` đã có · `[~]` một phần

See also [v1-feature-inventory.md](v1-feature-inventory.md) for electricity/auth/homes.

| ID | Module | Feature | Primary path | Unit | Widget | Integration | Status |
|----|--------|---------|--------------|------|--------|-------------|--------|
| WAT-01 | Water | Meter validation | `water_validation.dart` | x | x | | [x] |
| WAT-02 | Water | CRUD period + is_paid omit | `water_service.dart` | | | x | [x] |
| WAT-03 | Water | Photo path subfolder | `BillPhotoService.pathFor` | x | | | [x] |
| WAT-04 | Water | Home.m3_rate fromJson | `home.dart` | x | | | [x] |
| EXP-01 | Expenses | Totals / by category | `expense_totals.dart` | x | | | [x] |
| EXP-02 | Expenses | Form invalid amount | `expense_form.dart` | | x | | [x] |
| INC-01 | Income | MonthBalance net | `month_balance.dart` | x | | | [x] |
| OVW-01 | Overview | Summary card | `overview_summary_card.dart` | | x | | [x] |
| OVW-02 | Overview | Month clamp / stepper | `month_clamp.dart` | x | x | | [x] |
| OVW-03 | Overview | 6-month spend fold + MoM | `month_balance.dart` | x | | | [x] |
| UI-01 | Shared | Select sheet for dropdowns | `select_sheet.dart` | | x | | [x] |
| UI-03 | Shell | iOS home-indicator bottom inset | `safe_bottom_inset.dart` | x | x | | [x] |
| UI-02 | Shared | Period detail view (điện/nước) | `period_detail_view.dart` | | x | | [x] |
| REM-02 | Reminders | Same-day order photo → payday → remind | `reminder_banner.dart` | | x | | [x] |
| HOME-03 | Homes | Persist selected home | `selected_home.dart` | x | | | [x] |
| HOME-05 | Homes | Leave home keep history | `leave_home_sheet.dart`, `managed_home_page.dart` | | x | x | [x] |
| HOME-06 | Homes | Owner remove member | `settings_members_page.dart` | | x | x | [x] |
| ELEC-M05 | Electricity | upsert omits is_paid | `electricity_service.dart` | | | x | [x] |
| PWA-01 | PWA | Install surface + share URL | `pwa_install.dart` | x | | | [x] |
| PWA-02 | PWA | Install banner + QR page | `install_home_screen_banner.dart` | | x | | [x] |
| INV-04 | Invites | Join QR token | `join_link.dart` | x | x | x | [x] |
| UI-04 | Shared | Empty state: mô tả + CTA + icon theo ngữ cảnh | `empty_state_view.dart` | | x | | [x] |
| UI-05 | Shell | Haptic khi đổi tab | `app_bottom_nav.dart` | | x | | [x] |
| UI-06 | Shared | Ảnh hoá đơn: preview, giới hạn file, bỏ ảnh | `bill_photo_pick_field.dart` | | x | | [x] |
| SET-03 | Settings | Nút Lưu chỉ bật khi có thay đổi | `form_dirty.dart` | x | | | [x] |
| SET-04 | Settings | Trang tài khoản có thông tin Google / nhà | `settings_account_page.dart` | | x | | [x] |
| A11Y-01 | Theme | Màu nhấn có biến thể riêng cho chế độ sáng | `app_accent.dart` | x | | | [x] |
| A11Y-02 | Theme | Bậc chữ và màu trạng thái đạt 4.5:1 | `app_color_scheme.dart` | x | | | [x] |
| FMT-02 | Format | Rút gọn số âm | `vnd_format.dart` | x | | | [x] |

## Update rule

When adding a test file, update this table and [test-map.md](test-map.md).
