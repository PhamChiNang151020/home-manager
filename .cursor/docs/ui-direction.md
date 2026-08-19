# UI direction — home-manager (2026)

Dark-first PWA for iPhone. Palette: **Warm Utility Dark**.

## Colors

| Token | Hex |
|-------|-----|
| bgBase | `#0B0D10` |
| bgSurface | `#151A21` |
| bgElevated | `#1C2430` |
| border | `#273140` |
| textPrimary | `#E9EEF5` |
| textSecondary | `#94A3B8` |
| accent | `#F5A623` |
| success | `#4ADE80` |
| warning | `#FBBF24` |
| error | `#F87171` |

Sign-in gradient: `#0B0D10` → `#151A21` + subtle amber glow.

## Layout

- Max content width 480px, horizontal padding 16
- Touch targets ≥ 48dp
- Card radius 16, input radius 12
- Comfortable density (generous padding)

## Patterns

- Home switch: tap AppBar title → bottom sheet
- Electricity: summary + 6-month chart + period cards + sticky CTA
- Settings: iOS-style hub → sub-pages
- Logging: `AppLog` / `dart:developer`, debug only
