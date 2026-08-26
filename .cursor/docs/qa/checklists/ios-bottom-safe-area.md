# Feature checklist — iOS bottom safe area

Link inventory IDs: UI (shell bottom nav).

## Goal

Bottom navigation sits above the iOS home indicator on native iPhone.

## Scope

- In scope: `AppBottomNav` / sticky bars use a safe bottom inset (fallback when engine reports 0)
- Out of scope: PWA home-screen shell (still zero bottom inset)

## Files (from CODEBASE_MAP)

- `lib/core/domain/safe_bottom_inset.dart`
- `lib/core/theme/safe_bottom_padding.dart`
- `lib/features/shell/app_bottom_nav.dart`
- `lib/features/shell/app_shell.dart`
- `lib/features/shared/sticky_primary_bar.dart`

## Functional checklist

- [x] Happy path works on Chrome
- [x] Empty / error states handled
- [x] Vietnamese copy correct (`lib/core/l10n/strings.dart`)
- [x] No Supabase calls from widgets (services only)

## Edge cases

- [x] Native iOS with top inset but bottom 0 still pads ~34
- [x] iOS PWA home-screen shell keeps 0 extra bottom inset

## Automated tests

| Type | File | Cases |
|------|------|-------|
| Unit | `test/unit/safe_bottom_inset_test.dart` | reported vs fallback |
| Widget | `test/widget/app_bottom_nav_test.dart` | iOS bar taller when bottom inset missing |

## Manual E2E

- [ ] iPhone 17 Pro: labels above home indicator, FAB glow not clipped

## Done criteria

- [x] `flutter analyze` clean
- [x] `flutter test` pass
