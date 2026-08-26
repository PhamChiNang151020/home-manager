# Edge Functions

## `send-home-invite`

Sends a real invite email through [Resend](https://resend.com) after the owner creates a `home_invites` row.

### One-time setup (Dashboard — không cần CLI)

1. **Resend:** tạo API key (`re_...`). Khi test dùng `Tổ Ấm <onboarding@resend.dev>` — chỉ gửi được tới email tài khoản Resend của bạn.
2. **Migration:** đã chạy `20260826140000_home_invite_email_status.sql` thì bỏ qua.
3. Mở [Supabase Dashboard](https://supabase.com/dashboard) → chọn project Tổ Ấm.
4. **Edge Functions → Secrets** (hoặc *Edge Functions → Manage secrets*):
   - `RESEND_API_KEY` = `re_...`
   - `INVITE_FROM_EMAIL` = `Tổ Ấm <onboarding@resend.dev>`
   - `APP_PUBLIC_URL` = `https://phamchinang151020.github.io/home-manager/`
   - Save. Không cần set `SUPABASE_URL` / anon / service role (tự inject).
5. **Edge Functions → Deploy a new function → Via Editor**:
   - Tên function: **`send-home-invite`** (đúng từng ký tự).
   - Xóa mẫu hello-world; dán toàn bộ nội dung file [`send-home-invite/index.ts`](send-home-invite/index.ts) trong repo.
   - **Deploy function**.
6. Trong app: mời bằng đúng email Resend của bạn → kiểm tra inbox.

### CLI (tuỳ chọn)

```bash
supabase secrets set \
  RESEND_API_KEY=re_xxx \
  INVITE_FROM_EMAIL="Tổ Ấm <onboarding@resend.dev>" \
  APP_PUBLIC_URL="https://phamchinang151020.github.io/home-manager/"

supabase functions deploy send-home-invite
```

### App flow

Flutter `InviteService` → RPC `invite_to_home` → `functions.invoke('send-home-invite', { invite_id })`.

Pending tiles show send status and allow **Gửi lại**.
