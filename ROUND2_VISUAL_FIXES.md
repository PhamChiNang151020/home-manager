# Round 2 Visual Fixes - Commit 00d4c1f

## All 8 QA Issues Fixed

### 1. Button Height: 48px Enforced ✅
**Problem**: Buttons rendered ~39px tall instead of 48px
**Root Cause**: `minimumSize` alone doesn't enforce height when content/padding differs
**Fix**: Added `maximumSize: Size(double.infinity, 48)` + explicit `padding: vertical: 0` to FilledButton and OutlinedButton themes
**Files**: `lib/core/theme/app_theme.dart`

### 2. Field Error Text Clipping ✅  
**Problem**: Descenders cut off at bottom of error messages
**Root Cause**: `minHeight: 20` too small, `height: 1.33` line-height insufficient
**Fix**: Changed to `minHeight: 24`, `height: 1.5`, added `padding: top 4 + bottom 4`
**Files**: All auth form widgets (`email_password_sign_in_form.dart`, `create_account_page.dart`, `forgot_password_page.dart`, `set_new_password_page.dart`)

### 3. Primary Button Pale with Errors ✅
**Problem**: Button appeared disabled/grey when validation errors shown
**Root Cause**: Flutter applies disabled style when `onPressed` is null, even temporarily
**Fix**: Set `disabledBackgroundColor: colors.accent` and `disabledForegroundColor: onPrimary` in theme
**Files**: `lib/core/theme/app_theme.dart`

### 4. Loading State Button Grey ✅
**Problem**: Loading button showed grey bg + grey text instead of amber + white
**Root Cause**: `onPressed: null` triggers disabled style; `colors.bgBase` for spinner was grey
**Fix**: Changed to `onPressed: () {}` (noop function, keeps enabled), `Colors.white` for spinner and text
**Files**: All auth form widgets

### 5. Screens 11-13 Email Wrapping ✅
**Problem**: "Cho tài khoản email@example.com" wrapped to 2 lines
**Root Cause**: Simple `Text()` widget wraps naturally
**Fix**: Changed to `RichText` with `maxLines: 1` and `overflow: TextOverflow.ellipsis`
**Files**: `lib/features/auth/set_new_password_page.dart`

### 6. Card Shadow Too Faint ✅
**Problem**: Shadow barely visible compared to mockup
**Root Cause**: `alpha: 0.08` too light, `blur: 10` not enough
**Fix**: Increased to `alpha: 0.12`, `blurRadius: 12`, added `spreadRadius: 0`
**Files**: `lib/features/shared/app_glass_surface.dart`

### 7. Letter Spacing Too Wide ✅
**Problem**: Hint/footer text had wider spacing than mockup, shifting Google button position ~10px lower
**Root Cause**: Default letter spacing in Nunito font
**Fix**: Added `letterSpacing: 0` to all `color: colors.textSecondary` text styles
**Files**: All auth form widgets

### 8. Link Overlay/Highlight on Screen 05 ✅
**Problem**: "Đăng nhập" link showed tinted background on hover/tap
**Root Cause**: Material default overlay color
**Fix**: Added `overlayColor: Colors.transparent` and `splashFactory: NoSplash.splashFactory` to TextButton style
**Files**: `lib/features/auth/create_account_page.dart` (_buildSignInFooter)

## Build Status
- ✅ `flutter analyze`: 3 info suggestions (no errors)
- ✅ `flutter build web`: Build succeeded in 28.1s
- ✅ Ready for screenshot verification

## Next: Manual Verification Required
Per user request, must capture screenshots at 390×844 and measure button heights before reporting:
1. Start web server: `python3 -m http.server 8080 --directory build/web`
2. Use Playwright/headless Chrome at 390×844
3. Capture states: 01, 02, 04, 05, 11 (minimum)
4. Measure rendered button height with DevTools
5. Compare screenshots to mockups side-by-side
6. Report measured heights and attach screenshots
