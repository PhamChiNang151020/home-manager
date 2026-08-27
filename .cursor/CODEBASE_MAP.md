# CODEBASE_MAP — home_manager (Flutter Web + iOS) v2

Consult this file before grepping the repo. Update when adding modules under `lib/`.

## Entry & shell

| Item | Path |
|------|------|
| Process entry | `lib/main.dart` (Supabase init + soft Firebase/FCM web init + `AppServices` + session + lock) |
| Root widget | `lib/app.dart` → `HomeManagerApp` / `MissingConfigApp` |
| Auth gate | `lib/app.dart` + `lib/features/auth/sign_in_page.dart` |
| PIN gate | `lib/app.dart` + `lib/features/lock/lock_screen.dart` (after Google auth) |
| Main shell | `lib/features/shell/app_shell.dart` — bottom nav 5 slots: Tổng quan / Sổ giao dịch / (+) / Thông báo / Cá nhân; AppBar shows tab title (home picker moved to Personal) |
| Custom bottom nav | `lib/features/shell/app_bottom_nav.dart` |
| Quick-add picker | `lib/features/shell/quick_add_picker_sheet.dart` → Chi tiêu / Điện / Nước / Thẻ·hạn mức / Nợ / Tiết kiệm (Global FAB); no sticky add bars on transaction sub-pages |
| Home picker sheet | `lib/features/shell/home_picker_sheet.dart` (opened from Personal hub “Nhà đang quản lý”) |
| Session | `lib/core/state/session_controller.dart` (persists `selected_home_id`) |
| Lock | `lib/core/state/lock_controller.dart` + `lib/core/services/lock_service.dart` (local SHA-256 PIN) |
| Reminders badge | `lib/core/state/reminder_controller.dart` + `lib/core/domain/reminder_aggregator.dart` |
| Services locator | `lib/core/services/app_services.dart` |
| FCM (web) | `lib/core/config/firebase_web_config.dart` + `lib/core/services/notification_service.dart` + `lib/core/services/fcm_token_service.dart` + `web/firebase-messaging-sw.js` |
| Reminder push (server) | `supabase/functions/send-reminder-push/` + `.github/workflows/daily-reminder-push.yml` |

**Firebase pin (do not upgrade casually):** `firebase_core` **4.13.0**, `firebase_core_web` **3.10.0**, `firebase_messaging` **16.5.0** — `firebase_core_web` 3.11.0+ requires `dart:js_interop` `Object.isA` not supported on Dart **3.7.2** / Flutter **3.29.2** (project-pinned). Do not `flutter pub upgrade` these without testing web compile first.

## Feature screens

| Area | Path |
|------|------|
| Sign in | `lib/features/auth/sign_in_page.dart` |
| Create home | `lib/features/homes/create_home_dialog.dart` |
| Overview dashboard | `lib/features/overview/overview_page.dart` — hero net worth + `overview_income_spend_chart.dart` + category donut + compact quick-access grid; legacy `overview_summary_card.dart`, `overview_shortcut_grid.dart`, `overview_spend_trend_chart.dart` |
| Transactions hub | `lib/features/transactions/transactions_hub_page.dart` (sub-tabs: Điện·Nước / Hàng ngày / Tín dụng·Nợ / Tiết kiệm) |
| Notifications | `lib/features/notifications/notifications_page.dart` |
| Personal hub | `lib/features/personal/personal_hub_page.dart` (Thông tin / Chia sẻ / Cài đặt / Rời nhà / Đăng xuất); `leave_home_sheet.dart` |
| Electricity | `lib/features/electricity/` (page, form, summary, chart, cards, reminder) |
| Water | `lib/features/water/` (mirror of electricity) |
| Expenses / quick-add | `lib/features/expenses/` (list, form, `quick_add_sheet.dart`, presets, OCR) |
| Income | `lib/features/income/income_page.dart` |
| Finance hub | `lib/features/finance/finance_hub_page.dart` (optional push target; primary path is Transactions hub) |
| Bank credit | `lib/features/bank_credit/` |
| Personal debts | `lib/features/personal_debts/` |
| Savings | `lib/features/savings/` |
| App lock | `lib/features/lock/` (lock screen, setup PIN) |
| Settings (nested) | `settings_home_page.dart`, `settings_schedule_page.dart`, `settings_members_page.dart`, `settings_account_page.dart`, `settings_appearance_page.dart`, `settings_security_page.dart`; legacy `settings_hub_page.dart` |
| PWA install | `lib/features/pwa/install_home_screen_banner.dart`, `install_home_screen_page.dart` |
| iOS Web Clip | `web/install-ios.html`, `web/to-am.mobileconfig`, `web/join.html`, `tool/generate_ios_webclip_profile.dart` |

## Shared UI

| Item | Path |
|------|------|
| Card, money, badges | `lib/features/shared/app_card.dart`, `money_text.dart`, `animated_money_text.dart`, `status_badge.dart` (`success\|warning\|accent\|neutral\|error`), `trend_chip.dart`, `app_toast.dart` (`showAppToast` / `popWithAppToast`) |
| Period detail | `lib/features/shared/period_detail_view.dart` (điện / nước view-only) |
| Fields | `labeled_text_field.dart` (`LabeledDropdownField` → select sheet), `labeled_money_field.dart`, `month_picker.dart`, `cupertino_date_sheet.dart`, `month_stepper_field.dart`, `day_stepper_field.dart`, `select_sheet.dart` |
| Loading / error / empty | `app_loading.dart` (logo + spinning ring), `loading_view.dart`, `error_view.dart`, `empty_state_view.dart` (icon + mô tả + CTA) |
| Bill photo picker | `lib/features/shared/bill_photo_pick_field.dart` (preview + bỏ ảnh + giới hạn file) |
| Bottom sheet | `lib/features/shared/app_sheet.dart` — `showAppSheet` là lối vào duy nhất (safe area + drag handle) |
| Pull-to-refresh | `lib/features/shared/app_refresh_indicator.dart` — kéo xuống hiện cùng overlay `AppLoadingScrim` với lần tải đầu |
| Sticky CTA / feature scaffold | `sticky_primary_bar.dart`, `feature_page_scaffold.dart` |
| Brand logo | `lib/features/shared/app_brand_logo.dart` (`assets/brand/logo.png`) |
| Feature / category icons | `lib/core/theme/app_icons.dart` (`IconData`) + `app_asset_icon.dart` (`AppIcon`) |
| Glass surfaces | `app_glass_surface.dart` (`.blurred` chrome / `.light` lists), `app_ambient_background.dart` (radial blobs); default off via `ThemeController.glass` / Cài đặt giao diện |
| PWA icons | `web/icons/` + `web/favicon.png`, `web/manifest.json` |
| Web renderer | `web/flutter_bootstrap.js` — CanvasKit (`renderer: "canvaskit"`) for stable blur |

## Core

| Item | Path |
|------|------|
| Logging | `lib/core/logging/app_log.dart` — debug-only; `debugPrint` + `dart:developer`; FlutterError hook |
| Copy (VI) | `lib/core/l10n/strings.dart` |
| Theme | `lib/core/theme/app_theme.dart` (Nunito, `glass:`), `app_color_scheme.dart` (glass tokens + ambient), `app_spacing.dart`, `safe_bottom_padding.dart` |
| Theme state | `lib/core/state/theme_controller.dart` — mode, accent, glass |
| Fonts | `assets/fonts/Nunito/static/` (Regular 400 · Medium 500 · SemiBold 600 · Bold 700) |
| Domain | `electricity_validation.dart`, `water_validation.dart`, `meter_math.dart`, `month_balance.dart`, `month_clamp.dart`, `expense_totals.dart`, `net_worth.dart`, `reminder_aggregator.dart`, `receipt_amount_parser.dart`, `selected_home.dart`, `period_history_filter.dart`, `pwa_install.dart`, `bank_brand.dart`, `join_link.dart`, `invite_email.dart`, `oauth_launch.dart`, `oauth_redirect.dart`, `safe_bottom_inset.dart`, `form_dirty.dart` |
| Models | `home.dart`, `electricity_period.dart`, `water_period.dart`, `expense.dart`, `expense_preset.dart`, `income.dart`, `tracking_mode.dart`, `lock_settings.dart`, `bank_account.dart`, `personal_debt.dart`, `savings.dart`, `reminder_item.dart` |
| Services | `home_service.dart`, `invite_service.dart`, `join_link_store.dart`, `electricity_service.dart` (`BillPhotoService`), `water_service.dart`, `expense_service.dart`, `income_service.dart`, `overview_service.dart`, `ocr_service.dart`, `lock_service.dart`, `bank_account_service.dart`, `personal_debt_service.dart`, `savings_service.dart`, `wallet_service.dart` |

## Supabase

| Item | Path |
|------|------|
| Init + RLS | `supabase/migrations/20260819000000_init.sql` |
| `is_paid` | `20260819000001_add_is_paid.sql` |
| Invite/storage DELETE | `20260820090000_fix_invites_and_storage_rls.sql` |
| Water | `20260820100000_water_periods.sql` |
| Expenses | `20260820110000_expenses.sql` |
| Income | `20260820120000_incomes.sql` |
| Bank credit | `20260821090000_bank_credit.sql` |
| Personal debts + RPC | `20260821090100_personal_debts.sql` (`add_personal_debt_payment`) |
| Savings + RPC | `20260821090200_savings.sql` (`add_savings_contribution`) |
| Expense presets RPC | `20260821100000_add_expense_presets_rpc.sql` |
| Drop loan category seed | `20260821110000_drop_loan_expense_category_seed.sql` |
| Delete home RPC | `20260821120000_delete_home_rpc.sql` |
| Join QR token | `20260825090000_home_join_links.sql` |
| Invite reject existing member | `20260827090000_invite_reject_existing.sql` |
| Leave home RPC | `20260827100000_leave_home.sql` (`left_at`, `leave_home`) |
| Invite email status (unused; mail send removed) | `20260826140000_home_invite_email_status.sql` |
| Wallets + ledger | `20260826160000_wallets.sql` (`wallet_adjust` / `transfer` / expense RPCs) |
| Seed (elec/water/expense/income) | `supabase/seeds/seed_home_testing.sql` |
| Seed (finance) | `supabase/seeds/seed_finance_testing.sql` |

## QA & Tests

| Item | Path |
|------|------|
| QA index | `.cursor/docs/qa/README.md` |
| Feature inventory | `.cursor/docs/qa/v1-feature-inventory.md`, `v2-feature-inventory.md` |
| Manual E2E | `.cursor/docs/qa/v1-manual-e2e.md` |
| Test map | `.cursor/docs/qa/test-map.md` |

### Feature modules (`lib/features/`)

- `lib/features/auth/`
- `lib/features/overview/`
- `lib/features/transactions/`
- `lib/features/notifications/`
- `lib/features/personal/`
- `lib/features/electricity/`
- `lib/features/water/`
- `lib/features/expenses/`
- `lib/features/income/`
- `lib/features/finance/`
- `lib/features/bank_credit/`
- `lib/features/personal_debts/`
- `lib/features/savings/`
- `lib/features/wallet/`
- `lib/features/lock/`
- `lib/features/homes/`
- `lib/features/settings/`
- `lib/features/pwa/`
- `lib/features/shared/`
- `lib/features/shell/`
