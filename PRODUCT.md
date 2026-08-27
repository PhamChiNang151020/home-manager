# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

Family members who share two homes in Vietnam: the household they live in and
their parents' home. They open the app on an iPhone (Home Screen PWA or iOS
Simulator / later App Store) to record utility periods, expenses, and income
so everyone sees the same numbers.

## Product Purpose

Tổ Ấm (home_manager) keeps family electricity, water, daily spend, and monthly
income in one place with Google login and Supabase sync. Success is: the right
home is selected, the period or expense is saved correctly, and reminders fire
on the calendar days the owner set.

## Positioning

Two tracking modes in one app — **meter** (kWh / m³ × rate) vs **invoice**
(bill amount + photo) — so "nhà tôi" and "nhà ba mẹ" do not fake the same
workflow.

## Operating Context

Used on a phone, often quickly (payday, photo-due day, after a purchase).
Vietnamese UI. Online-first. Web PWA is the **same Flutter UI** at phone
width (Safari Add to Home Screen or Chrome), not a separate desktop product.
Native binary is iOS Simulator (`com.pcn.home_manager`); App Store when an
Apple Developer account exists.

## Capabilities and Constraints

- v2: electricity, water, expenses (five default categories), monthly income
  per member, overview, in-app reminder banners, `.ics` export.
- Shell: Tổng quan · sổ giao dịch · quick-add · thông báo · cá nhân.
  Điện / Nước / Thu nhập open from Tổng quan.
- Owner invites by join QR token. RLS: members only.
- Do **not** add Android, shopping list, or App Store submit without approval.
- Widgets do not call Supabase; services do. No service-role key in the client.
- Flutter 3.29 / Dart 3.7; Material 3; package `home_manager`.

Impeccable `## Platform` is `ios` so native (not HTML) tooling is used. The
design language is **Flutter Material 3**, not UIKit/Cupertino. Follow
`.cursor/skills/impeccable/references/flutter.md`.

## Brand Commitments

- Name: Tổ Ấm. Tagline: "Giữ ấm tổ ấm, giữ vững chi tiêu."
- Voice: Vietnamese, direct, household — not marketing English.
- Type: Nunito. Icons: `AppIcons` (Material rounded) + brand logo asset.
- User-picked accent (amber / blue / purple / green) and optional glass appearance.

## Evidence on Hand

- Domain: `.cursor/skills/home-manager-domain/SKILL.md`, `.cursor/notes.md`,
  `.cursor/docs/architecture.md`
- UI strings: `lib/core/l10n/strings.dart`
- Theme: `lib/core/theme/`
- Do not fabricate testimonials, prices, or App Store rankings.

## Product Principles

1. One glance on a phone: which home, what is due, what to record.
2. Meter math and invoice photos stay honest to `tracking_mode`.
3. Shared tokens beat one-off styling; Vietnamese copy stays in `S`.
4. Mobile-first 480px column; desktop Chrome is not a new information architecture.
5. Familiar Material controls; personality in accent, type, and glass — not in invented chrome.

## Accessibility & Inclusion

Touch targets 48dp. Light and dark (and glass) must keep text contrast.
Honor Dynamic Type / text scaler and Reduce Motion. Vietnamese is the UI
language; do not require English to complete a task.
