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
| HOME-03 | selectHome updates selected | `test/integration/session_controller_test.dart` | planned |
| INV-03 | Home.fromJson parses fields | `test/unit/models_test.dart` | planned |

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
