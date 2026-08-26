# Flutter platform (home_manager / Tổ Ấm)

For this repo only. Flutter Material 3 shipping to **iPhone** (Simulator +
Safari Home Screen PWA) and **Chrome** as a phone-width PWA. Not Android.
Not a Cupertino port. Not a desktop website.

Visitor mode is **Operate** on every product surface. Brand lives in accent,
type, glass, and precise details — not in reinvented navigation.

## The slop test

Would a family member on an iPhone trust this in one glance, or pause at
off-spec chrome? Failure modes here:

- A **ported website**: hover-only affordances, desktop side nav, tiny targets
- A **Cupertino costume** on a Material 3 app: SF Symbols mixed with `AppIcons`,
  grouped-inset lists fighting `AppCard`, system materials instead of
  `AppGlassSurface`
- An **Android/Material You** detour: dynamic color from wallpaper, FAB-as-nav,
  48dp *and* a second icon set

Default to **this app's** components. Depart only for a reason the user would thank you for.

## What to keep from iOS HIG (OS guarantees)

Honor these on Simulator and as far as the PWA allows:

- **Safe area.** No controls under the notch, Dynamic Island, home indicator, or
  rounded corners. Use `SafeArea` and `safeBottomPaddingOf` (see
  `lib/core/theme/safe_bottom_padding.dart`) — Scaffold's bottom bar zeros
  MediaQuery padding.
- **Edge-swipe back.** Do not disable or overlay the leading-edge back gesture
  on pushed routes (`FeaturePageScaffold` and friends).
- **Reduce Motion.** Prefer opacity/crossfade when `MediaQuery.disableAnimations`
  is true; no parallax as decoration.
- **Dark and light** are first-class (`AppColorScheme.dark` / `.light`).
- **Text scale.** Do not hard-clip labels at the default size; honor
  `MediaQuery.textScaler`. Body type comes from Theme (`Nunito`), not random
  `fontSize:` in features.
- **Touch.** Minimum 48×48 (`AppSpacing.touchMin`), spacing between adjacent
  targets.

Do not rebuild as Cupertino unless the user asks: no San Francisco as the UI
face, no SF Symbols, no UIKit semantic colors as the palette, no grouped-inset
settings lists fighting `AppCard`, no system materials instead of
`AppGlassSurface`.

## Layout & structure

- **Phone column.** Content sits in `MobileViewport` (max 480, horizontal 16).
  Do not stretch into a desktop dashboard. Chrome desktop is a large phone, not
  a new IA.
- **Shell tabs** (not a 2–5 HIG tab bar of sections-only): Overview, Transactions,
  center Quick Add, Notifications, Personal — `AppBottomNav`. Do not replace
  with a NavigationBar copy or a sidebar.
- **Pushed features** (Điện, Nước, Thu nhập, settings children) use
  `FeaturePageScaffold`.
- **Sheets** for self-contained picks (quick add, home switch, date/select).
  Do not invent a second modal system.

## Typography

- **Nunito** via `AppFonts` / `ThemeData.fontFamily`. One family for UI.
- Map to Material textTheme roles already applied in `AppTheme` (`titleLarge`
  on app bars, etc.). Do not introduce a display face or clamp/fluid CSS-style
  type.
- User-facing strings live in `S` (`lib/core/l10n/strings.dart`). Vietnamese.

## Color & materials

- Tokens: `AppColorScheme` (ThemeExtension). Accents: `AppAccent` with
  `color` (dark theme) and `colorOnLight` (light theme — contrast-safe).
- Semantic: `textPrimary` / `textSecondary` / `textMuted`, `success` / `warning` /
  `error`, category colors. No raw `Color(0xFF…)` in feature files.
- **Glass** is a user setting (`AppColorScheme.glass`), implemented by
  `AppGlassSurface` + ambient scaffold gradient. Do not sprinkle extra
  `BackdropFilter` in random cards; do not ban glass — it is a committed
  appearance, not decoration-by-default.
- One accent drives primary actions and selection. Category colors are for
  expense/income taxonomy, not chrome.

## Components & icons

- **Icons:** `AppIcons` (Material rounded) + brand raster `AppIcons.brand`.
  Do not mix SF Symbols, Lucide, or emoji-as-icons.
- **Cards:** `AppCard`. **Surfaces:** `AppGlassSurface` when glass is on.
- **Primary sticky actions:** `StickyPrimaryBar`.
- Platform-shaped controls (Switch, date picker, text fields) stay Material 3
  themed in `AppTheme`. Reinventing toggles/buttons for flavor is slop.
- Feedback: SnackBar / banners already in the product; don't add toast packages
  for the same job.

## Motion

- Short, state-carrying (150–250 ms). Honor Reduce Motion.
- System route transitions are enough for push/sheet. Custom transitions must
  not fight the back gesture.

## Craft-floor translation (Flutter)

Upstream craft-floor speaks CSS. Map it:

| Floor | Flutter |
|---|---|
| Contrast 4.5:1 / 3:1 | `AppAccent.colorOnLight` on light; theme text tokens; test both brightness |
| Spacing | `AppSpacing` (4 / 8 / 16 / 24); more space above a heading than below |
| Type measure | Phone column 480; don't target 65ch blog measure |
| Motion | `Animation*` / implicit animations; no CSS `filter`/`clip-path` as a goal |
| States | default, disabled, loading, error, empty — `WidgetState` / explicit widgets |
| Browser chrome (selection, caret, scrollbar) | Skip on native; PWA uses Flutter's widgets, not document CSS |
| Hover | Optional desktop Chrome; every control must work with **touch only** |

Refuse (still apply): nested cards as page structure, gradient text, eyebrow
kickers, emoji-as-icon, hard-coded hex, hover-only hit targets.

Glass and blur: allowed when `glass` is on and routed through `AppGlassSurface`,
not as a new one-off.

## Adaptivity (this product)

- **Phone is the design.** `maxContentWidth` 480 centered. Do not build tablet
  split views or Android foldables.
- **PWA vs Simulator:** same layout; PWA home-indicator inset is special-cased
  in `safeBottomPaddingOf` (`pwaIosHomeScreenShell`). Don't "fix" that to
  match vanilla web padding.
- **Orientation:** portrait-first. Don't lock orientation to hide a bug; don't
  spend the task on landscape unless asked.
- Do not invent desktop↔mobile marketing breakpoints. Phone column only.

## Verifying the build

Screenshots from **iPhone Simulator**, not a restyled browser mock:

```bash
xcrun simctl io booted screenshot /tmp/home-manager-ui.png
# several booted: use the UDID from `xcrun simctl list devices booted`
xcrun simctl ui booted appearance dark
```

Also check **Chrome at ~390px** (or the running Flutter Web session) — that is
the PWA surface, not a second product.

Say which surface produced the evidence. Widget tests cover states the
screenshot cannot (errors, empty, validation).

Do not use `adb`, Android emulators, or HTML/CSS detectors.
