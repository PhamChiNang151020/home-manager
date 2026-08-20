# Feature checklist — PWA add to Home Screen + QR

## Goal

Help family install Tổ Ấm on the phone Home Screen without sending a GitHub URL: in-browser guide + screenshot-friendly QR.

## Scope

- In scope: banner when Safari/Chrome (not already PWA); QR page in Cài đặt; UA detection (iOS Safari vs in-app vs Android)
- Out of scope: auto-install, App Store, native iOS/Android, Web Push, hiding the public Pages URL from the network

## Files (from CODEBASE_MAP)

- `lib/core/domain/pwa_install.dart`
- `lib/core/services/pwa_runtime.dart`
- `lib/features/pwa/install_home_screen_banner.dart`
- `lib/features/pwa/install_home_screen_page.dart`
- `lib/features/settings/settings_hub_page.dart`
- `lib/features/shell/app_shell.dart`
- `lib/features/auth/sign_in_page.dart`
- `lib/core/l10n/strings.dart`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Already installed (`display-mode: standalone` / iOS `navigator.standalone`) — no banner
- [x] Desktop browser — no banner
- [x] In-app Zalo/Messenger/Chrome-iOS — tell user to open Safari/Chrome
- [x] Localhost QR uses production Pages URL
- [x] Share URL strips query/fragment (OAuth)

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/pwa_install_test.dart` | UA surfaces, share URL |
| Widget | `test/widget/install_home_screen_test.dart` | hide / iOS steps / dismiss / QR no URL text |
| Integration | — | |

Map IDs to [test-map.md](../test-map.md) when tests exist.

## Manual E2E

- [ ] TC-PWA-01: Safari iPhone chưa cài — banner + Chia sẻ → Thêm vào Màn hình chính
- [ ] TC-PWA-02: Mở từ Zalo — hướng dẫn Mở bằng Safari
- [ ] TC-SET-04: Cài đặt → mã QR, chụp ảnh, không hiện URL lớn

**Browser:** Chrome · Safari/iPhone if [PWA]

## Notes / follow-ups

Browsers cannot auto Add to Home Screen. QR still encodes the public Pages URL; the UI just avoids displaying it.
