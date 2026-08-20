# Feature checklist — Phase 1 Water

## Goal

Add water periods mirroring electricity, with overview hub navigation.

## Scope

- In scope: `water_periods`, `m3_rate`, Water UI, overview hub
- Out of scope: expenses / income dashboard totals

## Files (from CODEBASE_MAP)

- `lib/features/water/`
- `lib/features/overview/overview_page.dart`
- `lib/core/services/water_service.dart`

## Functional checklist

- [x] Vietnamese copy in `S`
- [x] No Supabase calls from widgets
- [x] Empty / error states

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/water_validation_test.dart` | meter/invoice validation |
| Unit | `test/unit/home_water_model_test.dart` | m3_rate / WaterPeriod |
| Widget | `test/widget/water_form_test.dart` | invalid readings / duplicate |
| Integration | `test/integration/water_service_test.dart` | upsert is_paid + month change |

## Done criteria

- [ ] `flutter analyze` clean
- [ ] `flutter test` pass
