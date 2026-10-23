# Visual Fixes Required - PR #4

## Issues Fixed
✅ 1. Hint text non-breaking space added
✅ 2. Placeholder text simplified
✅ 3. "Nhập lại" label shortened
✅ 4. Error containers in email_password_sign_in_form.dart fixed

## Issues To Fix

### Critical (All Screens)
- [ ] Back button: Remove `.icon()` to avoid duplicate chevron (create_account, forgot_password)
- [ ] Button height: Ensure 48px (check theme vs actual)
- [ ] Error containers: Fix in create_account, forgot_password, set_new_password
- [ ] Password eye icon: Change to outline style
- [ ] Primary button: Never disable (even with errors)

### Screen 04 (Loading)
- [ ] Don't disable/grey inputs, links, Google button
- [ ] Keep amber button with white spinner + text

### Screen 05 (Create Account)
- [ ] Password confirm placeholder
- [ ] Remove highlight from "Đăng nhập" link

### Screen 10 (Forgot Password Success)
- [ ] Remove logo, app name, tagline
- [ ] Fix email text wrapping (Nunito 700)

### Screens 11-13 (Set Password)
- [ ] "Cho tài khoản email" on one line
- [ ] Use passwordNewPlaceholder
- [ ] Fix "Nhập lại" label

### Theme/Global
- [ ] Card shadow: #0F172A 8%, blur 10, offset y4
- [ ] Font sizes and spacing per spec
