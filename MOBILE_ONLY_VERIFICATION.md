# Mobile-Only Verification Guide

## Critical: Tổ Ấm is Mobile-Only

**Tổ Ấm has NO desktop version. All design, code, and QA target 390px mobile webview.**

## Browser Verification Setup

When testing in a browser, use mobile device emulation:

### Chrome DevTools
1. Open DevTools (F12)
2. Toggle Device Toolbar (Ctrl+Shift+M / Cmd+Shift+M)
3. Select "iPhone 12 Pro" or custom:
   - Width: **390px**
   - Height: **844px**
   - Device scale factor: **2** or **3**
   - User agent: **Mobile** (iPhone/Android)
   - Touch: **Enabled**

### Firefox Responsive Design Mode
1. Open Responsive Design Mode (Ctrl+Shift+M / Cmd+Option+M)
2. Set to:
   - Width: **390px**
   - Height: **844px**
   - Touch simulation: **Enabled**
   - User agent: **iPhone** or **Android**

## Current Implementation Status

### ✅ Auth Buttons: Mobile-Optimized
- **File**: `lib/features/auth/auth_button_theme.dart`
- **Density**: `VisualDensity.standard` explicitly set (48px height)
- **Scope**: Auth-only (does not affect rest of app)
- **Result**: Correct touch target size for mobile (48px min)

### ✅ No Desktop Breakpoints
- No responsive layouts
- No `MediaQuery.of(context).size.width` breakpoints
- No `LayoutBuilder` for desktop vs mobile
- Fixed 390px design throughout

### ✅ Theme: Mobile-First
- **File**: `lib/core/theme/app_theme.dart`
- No `adaptivePlatformDensity`
- No desktop-specific styling
- All spacing/sizing designed for 390px viewport

## Measurement Commands (Mobile Emulated)

### Browser Console (390×844 mobile emulation)

```javascript
// 1. Verify viewport
console.log(`Viewport: ${window.innerWidth}×${window.innerHeight}`);
console.log(`User agent: ${navigator.userAgent}`);
console.log(`Touch support: ${'ontouchstart' in window}`);

// 2. Button measurements
const primaryBtn = document.querySelector('button[type="submit"]');
const primaryRect = primaryBtn.getBoundingClientRect();
console.log(`Primary button height: ${primaryRect.height}px`); // Target: 48

const googleBtn = Array.from(document.querySelectorAll('button'))
  .find(b => b.textContent.includes('Google') || b.querySelector('svg'));
const googleRect = googleBtn.getBoundingClientRect();
console.log(`Google button height: ${googleRect.height}px`); // Target: 48
console.log(`Google button y: ${googleRect.y}`); // Target: 634

// 3. Card shadow (mobile)
let node = primaryBtn;
while (node = node.parentElement) {
  const style = window.getComputedStyle(node);
  if (style.boxShadow && style.boxShadow !== 'none') {
    console.log(`Card shadow: ${style.boxShadow}`);
    console.log(`Card top y: ${node.getBoundingClientRect().y}`);
    break;
  }
}
```

## iOS Simulator (Preferred for Final QA)

```bash
# Build for web
flutter build web --release \
  --dart-define=SUPABASE_URL=<your-url> \
  --dart-define=SUPABASE_ANON_KEY=<your-key>

# Serve
python3 -m http.server -d build/web 8080

# Open in iOS Simulator
open -a Simulator
# In Safari: http://<your-machine-ip>:8080
```

iOS Simulator provides:
- Real mobile Safari WebKit rendering
- Touch gestures
- Mobile viewport (390×844 on iPhone 12/13/14)
- Camera access for bill photo testing

## No Desktop Considerations

**Do NOT**:
- Add `@media (min-width: ...)` breakpoints
- Check `defaultTargetPlatform` for desktop
- Use `adaptivePlatformDensity`
- Create desktop-specific layouts
- Test in full desktop browser width

**DO**:
- Design for 390px width always
- Use explicit density (`VisualDensity.standard`)
- Test with mobile emulation or iOS Simulator
- Optimize for touch (48px minimum touch targets)

## Current Status: ✅ Mobile-Optimized

All Round 6 fixes are correct for mobile:
- Auth buttons: 48px (VisualDensity.standard)
- No hover states interfering (transparent overlay on hover/focus)
- Proper spacing for 390px viewport
- No desktop-specific code
