# Design

Incumbent visual world for Tổ Ấm. Source of truth is code; this file is the
durable summary. Do not invent a second system.

## World

Operate / family finance on a phone. Quiet surfaces, one accent, Nunito,
rounded Material icons. Optional frosted glass. Not a marketing landing page,
not Cupertino, not Android Material You.

## Type

- Family: `Nunito` (`AppFonts`, `ThemeData.fontFamily`).
- Scale: Material 3 `textTheme` from `AppTheme` (app bar uses `titleLarge`).
- No second display face. No CSS clamp / fluid type. Feature widgets do not
  pick random `fontSize`s.

## Color

`AppColorScheme` ThemeExtension. Accents via `AppAccent`:

| Accent | Dark (`color`) | Light (`colorOnLight`) |
|---|---|---|
| amber (default) | `#F5A623` | `#9A4507` |
| blue | `#60A5FA` | `#1D4ED8` |
| purple | `#C084FC` | `#6D28D9` |
| green | `#22C55E` | `#166534` |

Surfaces (dark / light): `bgBase` `#0B0D10` / `#F5F6F8`, `bgSurface`
`#151A21` / `#FFFFFF`. Text: `textPrimary`, `textSecondary`, `textMuted`.
Semantic: `success`, `warning`, `error`. Expense categories: `catFood`,
`catLoan`, `catHealth`, `catTuition`, `catOther`.

Never use the bright `AppAccent.color` as text or fill on light surfaces.

## Spacing & shape

`AppSpacing`: 4 / 8 / 16 / 24. Screen gutter 16. Card radius 16, input 12.
Touch min 48. Content max width 480 (`MobileViewport`).

## Elevation & glass

Opaque: Material card elevation (dark 1, light 2), `surfaceTint` transparent.
Glass on: `AppGlassSurface` blur (web 12, native 20), ambient scaffold
gradient `ambientTop` → `ambientBottom`. No extra ghost borders under wide
shadows.

## Components

| Pattern | Implementation |
|---|---|
| Phone column | `MobileViewport` |
| Feature push | `FeaturePageScaffold` |
| Card | `AppCard` |
| Frosted panel | `AppGlassSurface` |
| Bottom shell | `AppBottomNav` (5 slots, center + is not a tab) |
| Sticky CTA | `StickyPrimaryBar` |
| Icons | `AppIcons` |
| Copy | `S` in `lib/core/l10n/strings.dart` |

## Icons

Material rounded (`Icons.*_rounded`) through `AppIcons`. Brand mark:
`assets/brand/logo.png`. No SF Symbols, no emoji icons.

## Motion

Short state feedback (selection haptic on tabs). Route push/sheet = platform
default. Honor Reduce Motion.

## What this is not

Desktop dashboard IA, marketing heroes, gradient text, mixed icon sets,
Android-only navigation, Cupertino chrome on Material widgets.
