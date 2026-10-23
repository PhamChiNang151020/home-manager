# Testing & Screenshots Guide

## Real Screenshot Captured

✅ **01-sign-in-default.png** - Sign-in page default state captured at 390×844

Location: `/workspace/screenshots/01-sign-in-default.png`

## States Requiring Manual Testing

The following states require interaction with live Supabase backend and cannot be captured without:
1. Valid Supabase credentials
2. User interaction (typing, clicking, submitting forms)
3. Backend responses (auth errors, success states)

### Sign-in Screen (01-04)
- ✅ **01**: Default state - CAPTURED
- ⚠️ **02**: Invalid email error - Requires: typing invalid email + clicking sign in
- ⚠️ **03**: Wrong credentials - Requires: Supabase auth response
- ⚠️ **04**: Loading state - Requires: intercepting auth call

### Create Account (05-08)
- ⚠️ **05**: Default state - Requires: navigating from sign-in
- ⚠️ **06**: Email already exists - Requires: Supabase `user_already_exists` error
- ⚠️ **07**: Password too short - Requires: typing password < 8 chars + submitting
- ⚠️ **08**: Passwords don't match - Requires: typing mismatched passwords + submitting

### Forgot Password (09-10)
- ⚠️ **09**: Default state - Requires: navigating from sign-in
- ⚠️ **10**: Email sent confirmation - Requires: submitting valid email

### Set New Password (11-13)
- ⚠️ **11**: Default state - Requires: password recovery session
- ⚠️ **12**: Password too short - Requires: typing short password + submitting
- ⚠️ **13**: Passwords don't match - Requires: typing mismatched passwords + submitting

## How to Capture All States

### Prerequisites
```bash
# 1. Set valid Supabase credentials
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your-anon-key"

# 2. Build and serve
cd /workspace
flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
cd build/web && python3 -m http.server 8080 &
```

### Manual Screenshot Process

1. **Open browser at 390×844**:
   ```bash
   google-chrome --window-size=390,844 http://localhost:8080
   ```

2. **For each state**:
   - Navigate to the screen
   - Trigger the state (type input, click button, wait for response)
   - Use browser dev tools → Screenshot → Capture node/full viewport
   - Save as `XX-description.png` in `/workspace/screenshots/`

3. **Specific triggers**:
   - **02**: Type "invalidemail" in email field → click "Đăng nhập"
   - **03**: Type valid email + wrong password → click "Đăng nhập" → wait for Supabase error
   - **04**: Click "Đăng nhập" with valid creds → screenshot during loading spinner
   - **06**: Try to create account with email that already has Google account → wait for error
   - **07**: Type "short" in password field → click "Tạo tài khoản"
   - **08**: Type "password123" + "password456" → click "Tạo tài khoản"
   - **10**: Type valid email → click "Gửi link đặt lại" → wait for success screen
   - **12**: In password recovery, type "short" → click "Đặt mật khẩu"
   - **13**: Type "newpass123" + "newpass456" → click "Đặt mật khẩu"

## Visual Verification Checklist

Compare each screenshot against mockups in `/workspace/auth/01-13.png`:

- [ ] Logo size: 64×64
- [ ] Card width: 310px (390px viewport - 40px each side)
- [ ] Card padding: 24px
- [ ] Font: Nunito (400/600/700 weights)
- [ ] Colors match:
  - Accent: `#9A4507`
  - Error: `#C81E1E`
  - Border: `#D1D9E6`
  - Text primary: `#0F172A`
  - Text secondary: `#475569`
- [ ] Input fields: 48px height, 12px border radius
- [ ] Buttons: 48px height, 12px border radius
- [ ] Error messages: min-height 16px (no layout jump)
- [ ] Hint text "Đăng nhập để đồng bộ dữ liệu với gia đình." - no orphan "đình." word

## Known Visual Differences

### Google Button Icon
- **Mockup**: Multicolor Google "G" logo (SVG inline)
- **Implementation**: Material Icons G icon
- **Reason**: No Google logo asset in repo, using platform icon
- **Fix**: Add `assets/brand/google_logo.png` or inline SVG

### Other
- Flutter Web fonts may load slightly differently than browser fonts
- Canvas rendering may differ from HTML/CSS mockup rendering
- Both are acceptable as long as measurements/colors match spec
