# [Bản cuối] Tổ Ấm – Spec màn Đăng nhập / Tạo tài khoản / Quên mật khẩu (mobile webview 390×844)
Nhãn: **[code]** = lấy từ repo (main) · **[đề xuất]** = giá trị mới mình đề xuất · **[đo]** = đo từ bản live.

## Changelog (bản cuối, 23/10/2026)
1. "Đăng nhập" = FilledButton amber; Google = OutlinedButton + logo G (đã duyệt).
2. Bỏ trạng thái "tài khoản chưa tồn tại"; sai mật khẩu và chưa có tài khoản đều hiện "Email hoặc mật khẩu chưa đúng."
3. Mật khẩu tối thiểu **8 ký tự** (chốt) – SWE chỉnh Supabase project (Auth → Password min length = 8) cho khớp.
4. Tắt "Confirm email": bỏ màn "Kiểm tra email"; đăng ký xong vào thẳng app như Google.
5. Thêm màn "Đặt mật khẩu mới" (mở từ link đặt lại).
Thêm trạng thái lỗi mật khẩu < 8 ký tự ở Tạo tài khoản. Đánh số lại file 01–13.

## 1. Token dùng chung
| Token | Giá trị | Nguồn |
|---|---|---|
| Nền trang | gradient dọc `#F5F6F8` (bgBase) → `#FFFFFF` (bgSurface) | [code] app_color_scheme.dart, sign_in_page.dart |
| Card | AppCard → AppGlassSurface.light: gradient 135° `#FFFFFF`→~`#FAFAFB`, viền trắng 35%, bóng `#0F172A` 8% blur 10 y4, bo **16** | [code] app_glass_surface.dart, AppSpacing.cardRadius |
| Padding card | 24 (AppSpacing.lg) | [code] |
| Lề ngang | 24 (ScrollView) + 16 (MobileViewport) = **40** mỗi bên → card 310 | [code] |
| Chữ chính / phụ / mờ | `#0F172A` / `#475569` / `#5B6B7F` | [code] |
| Accent (amber on light) | `#9A4507`, chữ trên nền accent `#FFFFFF` | [code] app_accent.dart |
| Lỗi | `#C81E1E` | [code] |
| Viền | `#D1D9E6` | [code] |
| Font | Nunito (bundle assets/fonts/Nunito/static, 400/500/600/700) | [code] pubspec.yaml |
| Spacing | 4 / 8 / 16 / 24; formFieldGap 16; touchMin 48 | [code] app_spacing.dart |
| Input | filled `#FFFFFF`, bo 12, padding 16×12, viền `#D1D9E6`, focus `#9A4507` 1.5 | [code] inputDecorationTheme |
| FilledButton | nền `#9A4507`, chữ trắng 14/600, cao tối thiểu 48, bo 12 | [code] |
| OutlinedButton | chữ `#0F172A` 14/600, viền `#D1D9E6`, cao 48, bo 12 | [code] |
| TextButton | chữ `#9A4507` 14/600, cao 48 | [code] |
| Logo | assets/brand/logo.png (ô tối, nhà neon), 64×64 | [code] AppBrandLogo(size:64) |

## 2. Quyết định nút (đã duyệt)
- "Đăng nhập" = FilledButton amber (hành động chính). "Đăng nhập bằng Google" = OutlinedButton trắng, viền `#D1D9E6`, logo G 18px nhiều màu, gap 8 [đề xuất]. Hai nút không tranh nhau; khác hiện tại (Google đang là FilledButton).

## 3. Màn Đăng nhập (PNG 01–04)
| Phần tử | Chữ | Style | Khoảng cách | Nguồn |
|---|---|---|---|---|
| Logo | – | 64×64 | đầu card | [code] |
| Tên app | Tổ Ấm | headlineMedium M3: 28/36, w400, `#0F172A` | trên 16 | [code] |
| Tagline | Giữ ấm tổ ấm, giữ vững chi tiêu | titleSmall 14/20 w600 `#475569` | trên 4 | [code] |
| Gợi ý | Đăng nhập để đồng bộ dữ liệu với gia đình. | 14/20 w400 `#475569` | trên 8 | [code] style; chữ mới |
| Nhãn ô | Email / Mật khẩu | 12/16 w600 `#475569`, cách ô 4 | trên 16 | [đề xuất] |
| Ô Email | placeholder "ví dụ: ban@email.com" | cao 48, 14 `#0F172A`, placeholder `#5B6B7F`; keyboardType email, autofill email | – | [code] input / [đề xuất] chữ |
| Ô Mật khẩu | "••••" | như trên + icon mắt 20px trong vùng bấm 48×48; label a11y "Hiện mật khẩu"/"Ẩn mật khẩu" | – | [đề xuất] |
| Dòng lỗi | (xem bảng lỗi) | 12/16 `#C81E1E`, **luôn giữ chỗ 16px** dưới mỗi ô (min-height) để không nhảy layout | trên 4 | [đề xuất] |
| Quên mật khẩu? | Quên mật khẩu? | TextButton, căn phải, cao 48 | chồng -12 lên dòng lỗi mật khẩu | [đề xuất] |
| Nút chính | Đăng nhập | FilledButton full width, 48 | trên 8 | [code] style |
| Divider | hoặc | 12 `#5B6B7F`, line 1px `#D1D9E6`, hàng cao 40 | – | [đề xuất] |
| Nút Google | Đăng nhập bằng Google | OutlinedButton full width 48 + G mark | – | [đề xuất] |
| Chân | Chưa có tài khoản? **Tạo tài khoản** | 14 `#475569` + TextButton `#9A4507` 48 | trên 8 | [đề xuất] |

### Trạng thái
| Trạng thái | Hiển thị |
|---|---|
| Default | 01 |
| Focus | viền `#9A4507` 1.5 (theme) |
| Lỗi email sai định dạng (client, khi submit / blur) | 02 – viền `#C81E1E` 1.5 + "Email chưa đúng định dạng." |
| Sai mật khẩu / chưa có tài khoản | 03 – dưới ô Mật khẩu, viền đỏ ô Mật khẩu: "Email hoặc mật khẩu chưa đúng." |
| Loading | 04 – nút giữ 48, spinner 18 trắng + "Đang đăng nhập…", nút disabled, ô bị khoá, nút Google disabled; opacity 85% [đề xuất] |
| Disabled | nút chính không disable theo nội dung ô (bấm thì validate và hiện lỗi) [đề xuất]; Material disabled mặc định khi loading |
| Lỗi chung (mạng) | dùng lại khối `error` hiện có (text `#C81E1E` căn giữa trên nút) |

## 4. Tạo tài khoản (05–08)
| Phần tử | Chữ | Style |
|---|---|---|
| Quay lại | ‹ Đăng nhập | TextButton `#9A4507` 48, góc trên trái card [đề xuất] |
| Logo + Tổ Ấm + tagline | như Đăng nhập | [code] |
| Tiêu đề | Tạo tài khoản | 20/28 w700 `#0F172A`, trên 16 [đề xuất] |
| Email | placeholder ban@email.com | ô 48 |
| Mật khẩu | placeholder "Ít nhất 8 ký tự" + mắt | ô 48 |
| Nhập lại mật khẩu | + mắt | ô 48 |
| Nút | Tạo tài khoản | FilledButton 48, trên 8 |
| Chân | Đã có tài khoản? **Đăng nhập** | 14 `#475569` + TextButton |

| Trạng thái | Hiển thị |
|---|---|
| Default | 05 |
| Email đã có tài khoản (`user_already_exists`) | 06 – dưới ô Email: "Email này đã có tài khoản. Hãy đăng nhập." |
| Mật khẩu < 8 ký tự (client + `weak_password`) | 07 – dưới ô Mật khẩu: "Mật khẩu cần ít nhất 8 ký tự." |
| Không khớp | 08 – dưới ô Nhập lại: "Hai mật khẩu chưa khớp." |
| Email sai định dạng | như 02 |
| Loading | spinner + "Đang tạo tài khoản…", như 04 |
| Thành công | có session → vào thẳng app (giống Google), không có màn trung gian |

## 5. Quên mật khẩu (09–10)
09: ‹ Đăng nhập · logo/tên/tagline · "Quên mật khẩu" 20/28 w700 · thân 14/20 `#475569` "Nhập email đã dùng để tạo tài khoản. Mình sẽ gửi link đặt lại mật khẩu." · ô Email (prefill từ màn Đăng nhập nếu có; hình minh hoạ trạng thái focus) · FilledButton "Gửi link đặt lại" 48 · loading "Đang gửi…" · lỗi định dạng như 02.
10 (đã gửi): icon ✓ trong tròn 56 nền `#9A4507` 12% [đề xuất], "Đã gửi link" 22/28 w700, "Nếu **{email}** có tài khoản Tổ Ấm, link đặt lại mật khẩu sẽ tới trong vài phút." (trung tính, không lộ email có tồn tại), FilledButton "Về Đăng nhập" 48, trên 24.

## 6. Đặt mật khẩu mới (11–13)
Mở khi app nhận `AuthChangeEvent.passwordRecovery` (user bấm link trong email; Supabase đã tạo session tạm). Không có nút quay lại.
| Phần tử | Chữ | Style |
|---|---|---|
| Logo + Tổ Ấm + tagline | như Đăng nhập | [code] |
| Tiêu đề | Đặt mật khẩu mới | 20/28 w700 |
| Phụ | Cho tài khoản **{email}** | 14/20 `#475569`, email 700 `#0F172A` [đề xuất] |
| Mật khẩu mới | placeholder "Ít nhất 8 ký tự" + mắt | ô 48 |
| Nhập lại | placeholder "Nhập lại mật khẩu mới" + mắt | ô 48 |
| Nút | Đặt mật khẩu | FilledButton 48, trên 8 |

| Trạng thái | Hiển thị |
|---|---|
| Default | 11 |
| < 8 ký tự | 12 – dưới ô Mật khẩu mới: "Mật khẩu cần ít nhất 8 ký tự." |
| Không khớp | 13 – dưới ô Nhập lại: "Hai mật khẩu chưa khớp." |
| Loading | "Đang lưu…" |
| Link hết hạn / lỗi | lỗi chung `#C81E1E` trên nút: "Link đã hết hạn. Hãy gửi lại link đặt lại mật khẩu." + TextButton "Quên mật khẩu?" [đề xuất] |
| Thành công | `updateUser` OK → vào thẳng app |

## 7. Ghi chú auth cho engineer
- Hiện tại: `AuthService.signInWithGoogle()` dùng `signInWithOAuth(OAuthProvider.google, redirectTo: AppConfig.oauthRedirect)` (lib/core/services/auth_service.dart). Thêm method vào **cùng AuthService / cùng SupabaseClient** – không làm hệ đăng nhập thứ hai.
- Đăng nhập: `auth.signInWithPassword(email:, password:)`.
- Đăng ký: `auth.signUp(email:, password:)`. **Confirm email TẮT** trong Supabase → response có `session` ngay, `onAuthStateChange` bắn `signedIn`, app vào thẳng như Google. Không cần `emailRedirectTo` cho đăng ký.
- Quên: `auth.resetPasswordForEmail(email, redirectTo: AppConfig.oauthRedirect)` (URL phải nằm trong Redirect URLs). Khi mở link → `AuthChangeEvent.passwordRecovery` → hiện màn Đặt mật khẩu mới → `auth.updateUser(UserAttributes(password: …))` → vào app.
- Cấu hình Supabase SWE cần chỉnh: Email provider bật, Confirm email TẮT, Minimum password length = 8.
- **Một user cho Google + email**: thêm method vào cùng `AuthService`/`SupabaseClient`. Dữ liệu nhà/điện/nước gắn theo `auth.users.id`. Supabase tự liên kết identity khi email đã xác minh (Google luôn xác minh). Lưu ý cần kiểm thử: (a) user đã có bằng Google rồi `signUp` cùng email → Supabase trả `user_already_exists` → hiện 06; user đó dùng "Quên mật khẩu" để đặt mật khẩu cho chính tài khoản Google. (b) Khi Confirm email tắt, email do người dùng tự đăng ký **chưa được xác minh**, nên nếu sau đó họ bấm Google cùng email, Supabase có thể không tự liên kết mà tạo xung đột – cần thử trên project thật; có thể dùng `linkIdentity` khi đã đăng nhập.
- Map lỗi:
  - `invalid_credentials` → dưới ô Mật khẩu "Email hoặc mật khẩu chưa đúng." (Supabase trả cùng mã cho sai mật khẩu và email chưa tồn tại, để chống dò email – đúng với quyết định 2.)
  - `user_already_exists` / `email_exists` → dưới ô Email "Email này đã có tài khoản. Hãy đăng nhập." (Lưu ý: điều này cho phép dò email qua màn đăng ký – chấp nhận do tắt confirm email.)
  - `weak_password` → dưới ô Mật khẩu "Mật khẩu cần ít nhất 8 ký tự."
  - `same_password` (updateUser) → "Mật khẩu mới phải khác mật khẩu cũ." [đề xuất]
  - `over_email_send_rate_limit` / `over_request_rate_limit` → lỗi chung "Thử lại sau ít phút."; lỗi mạng → "Không kết nối được. Kiểm tra mạng rồi thử lại."
  - Email sai định dạng, < 8 ký tự, không khớp: validate phía client trước khi gọi.
- Font: Nunito đã bundle trong assets; để tránh nhảy layout (font fallback lúc đầu, nút 40 → 48), giữ `minimumSize 48` (đã có) và preload Nunito trong web/index.html (`<link rel=preload as=font>`) hoặc đợi font trước khi bỏ splash [đề xuất].
- Bàn phím trong webview: giữ `SingleChildScrollView` + `Center` hiện có, không có phần tử cố định đáy; `scrollPadding` mặc định để ô đang focus nổi trên bàn phím; `TextInputAction.next` → `done` (submit). `AutofillGroup` cho email/password (`AutofillHints.email`, `.password`, `.newPassword`). SafeArea đã có.
