# Feature checklist — Phase 4 Overview dashboard

## Goal

Fill Tổng quan with month totals, category breakdown, unified reminders; ship as 2.0.0.

## Scope

- In scope: dashboard totals, expense chart reuse, reminder copy điện+nước (photo → payday → remind), version bump, CODEBASE_MAP + QA inventory/e2e
- Out of scope: expense `due_date`, extra tabs, electricity photo path change

## Files (from CODEBASE_MAP)

- `lib/features/overview/overview_page.dart`
- `lib/features/overview/overview_summary_card.dart`
- `lib/core/app_version.dart`, `pubspec.yaml`
- `.cursor/CODEBASE_MAP.md`, `.cursor/docs/qa/`

## Functional checklist

- [x] Month picker + tổng thu / tổng chi / chênh lệch
- [x] Category breakdown reuses expense chart
- [x] Reminder banner copy covers điện + nước; order photo → payday → remind
- [x] Version 2.0.0
- [x] Vietnamese copy in `S`
- [x] No Supabase calls from widgets

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Widget | `test/widget/overview_summary_card_test.dart` | income / spend / net labels |
| Widget | `test/widget/reminder_banner_test.dart` | photo due + same-day order |

## Manual E2E

- TC-OVW-01 in `v1-manual-e2e.md`

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
