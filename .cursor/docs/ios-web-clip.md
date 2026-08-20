# iOS Web Clip profile

Unsigned configuration profile that adds a **Tổ Ấm** home-screen icon without Safari → Share → Add to Home Screen.

## Files

| File | Purpose |
|------|---------|
| `web/to-am.mobileconfig` | Deployed profile (GitHub Pages) |
| `tool/generate_ios_webclip_profile.dart` | Regenerate after icon/URL change |

Regenerate:

```bash
dart run tool/generate_ios_webclip_profile.dart
```

## Production URL

Install landing (preferred — correct MIME for Safari):

`https://phamchinang151020.github.io/home-manager/install-ios.html`

Raw profile (may fail on Safari because GitHub Pages serves `application/octet-stream`):

`https://phamchinang151020.github.io/home-manager/to-am.mobileconfig`

## Install flow (do for family once)

1. Open **Safari** on iPhone (not Zalo in-app browser).
2. Open the landing page above, or in-app: **Cài đặt → Thêm ra Màn hình chính → Cài nhanh trên iPhone**.
3. Tap **Cài nhanh** on the landing page (creates a Blob with `application/x-apple-aspen-config`).
4. Allow download → **Settings → Profile Downloaded → Install**.
5. iOS may show **Not Verified** — expected for unsigned profiles; tap **Install** again.
6. Icon **Tổ Ấm** appears on the home screen.

## Remove

Settings → General → VPN & Device Management → **Cài Tổ Ấm lên iPhone** → Remove Profile.

## Limits

- Not a full signed PWA install; Web Clip opens the URL fullscreen.
- Service worker / offline may differ from Add to Home Screen.
- iCloud alone cannot sign the profile; unsigned is fine for family setup.
