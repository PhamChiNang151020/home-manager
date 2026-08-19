# Electricity period — duplicate month & edit change month

Inventory: ELEC-M05, ELEC-M06, ELEC-M07

## Goal

Validate duplicate period handling and month-change delete when editing periods.

## Files

- `lib/features/electricity/electricity_form.dart`
- `lib/features/electricity/period_month_conflict.dart`
- `lib/core/services/electricity_service.dart`
- `lib/core/domain/electricity_validation.dart` (extract)

## Functional checklist

- [ ] Add period: duplicate month shows yellow hint
- [ ] Add period: duplicate month shows confirm dialog before overwrite
- [ ] Edit period: change month moves data to new month
- [ ] Edit period: old month row removed after save
- [ ] Meter: new kWh < previous blocked
- [ ] Invoice: amount ≤ 0 blocked

## Automated tests

| Type | File | Status |
|------|------|--------|
| Unit | `test/unit/period_month_conflict_test.dart` | done |
| Unit | `test/unit/electricity_validation_test.dart` | done |
| Unit | `test/unit/electricity_period_edit_test.dart` | done |
| Integration | `test/integration/electricity_service_test.dart` | done |

## Manual E2E

- [ ] TC-ELEC-M05
- [ ] TC-ELEC-M06
- [ ] TC-ELEC-M03
- [ ] TC-ELEC-M04
