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
| UI-02 | Shared | Period detail view (điện/nước) | `period_detail_view.dart` | | x | | [x] |
| REM-02 | Reminders | Same-day order photo → payday → remind | `reminder_banner.dart` | | x | | [x] |
| HOME-03 | Homes | Persist selected home | `selected_home.dart` | x | | | [x] |
| ELEC-M05 | Electricity | upsert omits is_paid | `electricity_service.dart` | | | x | [x] |
| PWA-01 | PWA | Install surface + share URL | `pwa_install.dart` | x | | | [x] |
| PWA-02 | PWA | Install banner + QR page | `install_home_screen_banner.dart` | | x | | [x] |

## Update rule

When adding a test file, update this table and [test-map.md](test-map.md).
