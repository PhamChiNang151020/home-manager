# v1 Feature inventory — home_manager

Status: `[ ]` chưa có automated test · `[x]` đã có · `[~]` một phần

| ID | Module | Feature | Primary path | Testable logic | Unit | Widget | Integration | Manual | Status |
|----|--------|---------|--------------|----------------|------|--------|-------------|--------|--------|
| CFG-01 | Config | Missing Supabase config screen | `lib/app.dart` | UI copy | | x | | x | [x] |
| CFG-02 | Config | Supabase init + session start | `lib/main.dart` | Auth stream | | | x | x | [ ] |
| AUTH-01 | Auth | Google OAuth sign-in | `auth_service.dart` | OAuth delegate | | | x | x | [ ] |
| AUTH-02 | Auth | Sign out | `auth_service.dart` | signOut | | | x | x | [ ] |
| AUTH-03 | Auth | Auth gate: loading → sign-in → shell | `app.dart`, `session_controller.dart` | state machine | | x | x | x | [ ] |
| HOME-01 | Homes | Create home (meter) | `create_home_dialog.dart`, `home_service.dart` | RPC params | | | x | x | [ ] |
| HOME-02 | Homes | Create home (invoice) | same | tracking_mode | | | x | x | [ ] |
| HOME-03 | Homes | List homes + select | `session_controller.dart`, `home_picker_sheet.dart` | list + select | | x | x | x | [ ] |
| HOME-04 | Homes | Accept pending invites on refresh | `home_service.dart` | RPC | | | x | x | [ ] |
| ELEC-M01 | Electricity | Meter: consumption × rate | `meter_math.dart` | pure math | x | | | | [x] |
| ELEC-M02 | Electricity | Meter: validate missing kWh | `electricity_validation.dart` | pure validation | x | x | | x | [x] |
| ELEC-M03 | Electricity | Meter: new kWh < previous | `electricity_validation.dart` | pure validation | x | x | | x | [x] |
| ELEC-M04 | Electricity | Meter: auto-fill previous period | `electricity_form.dart` | form init | | x | | x | [ ] |
| ELEC-M05 | Electricity | CRUD period | `electricity_service.dart` | upsert/delete | x | | x | x | [~] |
| ELEC-M06 | Electricity | Duplicate month hint + confirm | `period_month_conflict.dart` | findPeriodForMonth | x | x | | x | [x] |
| ELEC-M07 | Electricity | Edit change month → delete old row | `electricity_period_edit.dart` | shouldDeleteOriginalPeriod | x | | x | x | [x] |
| ELEC-I01 | Electricity | Invoice: amount + photo | `electricity_form.dart` | VndFormat + upload | x | | x | x | [ ] |
| ELEC-I02 | Electricity | Invoice: amount ≤ 0 | `electricity_validation.dart` | pure validation | x | x | | x | [x] |
| PHOTO-01 | Photos | Storage path format | `BillPhotoService.pathFor` | path string | x | | | | [x] |
| PHOTO-02 | Photos | Upload / remove JPEG | `electricity_service.dart` | storage API | | | x | x | [ ] |
| DASH-01 | Dashboard | Summary card | `electricity_summary_card.dart` | render | | x | | x | [ ] |
| DASH-02 | Dashboard | Trend chart | `electricity_trend_chart.dart` | render | | x | | x | [ ] |
| DASH-03 | Dashboard | Period list | `period_list_tile.dart` | render | | x | | x | [ ] |
| REM-01 | Reminders | Banner on matching day | `reminder_banner.dart`, `DayOfMonth` | isToday + clamp | x | x | | x | [x] |
| SET-01 | Settings | Update home name / rate / days | `settings_home_page.dart` | RPC | | | x | x | [ ] |
| SET-02 | Settings | ICS export (3 events) | `ics_export_service.dart` | buildCalendar | x | | | x | [x] |
| SET-03 | Settings | Theme / appearance | `theme_controller.dart` | prefs | | x | | x | [ ] |
| INV-01 | Invites | Invite by email | `invite_service.dart` | RPC | | | x | x | [ ] |
| INV-02 | Invites | List pending invites | `invite_service.dart` | query parse | | | x | x | [ ] |
| INV-03 | Invites | List members | `home_service.dart` | join parse | x | | x | x | [ ] |
| FMT-01 | Format | VND format / parse / compact | `vnd_format.dart` | pure | x | | | | [x] |

## Notes

- Phase 1–2: **36** automated tests in `test/unit/`, `test/widget/`, `test/integration/`
- Validation: `lib/core/domain/electricity_validation.dart`
- Period edit: `lib/core/domain/electricity_period_edit.dart`
- Supabase mocks: `test/support/mock_supabase.dart`

## Update rule

When adding a test file, update this table and [test-map.md](test-map.md).
