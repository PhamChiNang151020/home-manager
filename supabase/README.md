# Supabase

Run this SQL in the Supabase SQL editor (or `supabase db push` if the CLI is linked).

1. Create a project at [supabase.com](https://supabase.com).
2. **Authentication → Providers → Google**: enable, add Client ID/secret from Google Cloud.
3. **Authentication → URL configuration**: add
   - `http://localhost:8080` and `http://localhost:8080/` (Flutter web debug)
   - `https://phamchinang151020.github.io/home-manager/` (Pages)
   - `com.pcn.home-manager://login-callback` (iOS Simulator / native)

## iOS Google login (Simulator)

Web login already uses a **Web** OAuth client in Supabase. Keep that. Native iOS needs two extra console steps.

### 1. Redirect URL trên Supabase

1. Mở [Supabase Dashboard](https://supabase.com/dashboard) → chọn project Tổ Ấm.
2. **Authentication** → **URL Configuration**.
3. **Redirect URLs** → **Add URL**.
4. Dán đúng:

   `com.pcn.home-manager://login-callback`

5. **Save**. Không xóa URL web (`localhost`, GitHub Pages).

Sai một ký tự thì login xong kẹt Safari / không về app.

### 2. Google OAuth iOS client

Supabase Google provider vẫn dùng **Client ID + Secret loại Web**. Client iOS **không có secret** — không dán đè lên ô Web.

1. Mở [Google Cloud Console](https://console.cloud.google.com/) → cùng project đang dùng cho login web.
2. **APIs & Services** → **Credentials**.
3. **+ Create credentials** → **OAuth client ID**.
4. Application type: **iOS**.
5. Name: `Tổ Ấm iOS` (tùy ý).
6. Bundle ID (đúng từng ký tự):

   `com.pcn.home_manager`

7. **Create** → copy **Client ID** (`….apps.googleusercontent.com`) để lưu. Không cần điền vào Supabase.
8. **OAuth consent screen**: nếu app đang Testing, thêm Gmail người test vào **Test users**.

Không đổi **Authentication → Providers → Google** trên Supabase. Luồng iOS hiện tại là OAuth trình duyệt + custom scheme.
4. Execute [`migrations/20260819000000_init.sql`](migrations/20260819000000_init.sql) (and later migrations in order, including invite email status).
5. Copy **Project URL** (Overview → **Copy**, do not type) and **anon** key. Never use the service role in the Flutter app.

### Invite email (Resend)

See [`functions/README.md`](functions/README.md). Deploy `send-home-invite` and set secrets `RESEND_API_KEY`, `INVITE_FROM_EMAIL`, `APP_PUBLIC_URL` before testing “Gửi lời mời”.

**API key:** use **Legacy anon** (`eyJ...`) from tab *Legacy anon, service_role API keys* if publishable key (`sb_publishable_...`) fails on login.

**Verify URL:** open `https://YOUR_PROJECT_REF.supabase.co` in the browser — JSON error page means DNS is OK; `DNS_PROBE_FINISHED_NXDOMAIN` means wrong project ref.

## Run (CLI)

```bash
flutter run -d chrome --web-port=8080 \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## Run (Cursor / VS Code)

Copy `.vscode/supabase.local.json.example` → `.vscode/supabase.local.json`, fill values, then **Run → home-manager (Chrome)**.

Storage paths: `homes/{home_id}/{yyyy-mm}.jpg` in bucket `bill-photos`.

## Seed demo data (optional)

After creating a home named **Testing** in the app, run [`seeds/seed_home_testing.sql`](seeds/seed_home_testing.sql) in the SQL editor. It fills 6 months of điện / nước / chi / lương for that home (meter or invoice from the row). Re-run replaces those rows only.
