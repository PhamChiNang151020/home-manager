# Edge Functions

Invite mail via Resend was removed. Join a home with the QR / copy-link, or record a Google email so `accept_pending_invites` attaches membership on login.

---

## `send-reminder-push`

Daily FCM reminders for homes whose `photo_due_day` / `payday_day` / `remind_day` match **today in Asia/Ho_Chi_Minh**. Also supports **broadcast** (all tokens) for new app version after Pages deploy.

Called by GitHub Actions with `CRON_SECRET` — not by the Flutter app.

**Bodies**

- `{}` — daily reminders
- `{ "mode": "broadcast", "title": "...", "body": "..." }` — notify every `fcm_tokens` row

### Secrets (Supabase Edge)

1. Firebase Console → Project settings → **Service accounts** → Generate new private key → JSON.
2. Edge Functions → Secrets:
   - `CRON_SECRET` = random long string (same as GitHub Actions secret)
   - `FIREBASE_PROJECT_ID` = Firebase project id
   - `FIREBASE_SERVICE_ACCOUNT_JSON` = entire service-account JSON (one line OK)

### Deploy

Dashboard → Deploy function named **`send-reminder-push`** from
[`send-reminder-push/index.ts`](send-reminder-push/index.ts), or:

```bash
supabase functions deploy send-reminder-push --no-verify-jwt
```

`supabase/config.toml` sets `verify_jwt = false` for this function. GitHub
Actions still send the **anon JWT** in `Authorization` plus `x-cron-secret`,
so a leftover Verify JWT toggle does not 401 the cron.

### GitHub Actions secrets

- `SUPABASE_URL` (already present)
- `SUPABASE_ANON_KEY` (already used by Pages deploy)
- `CRON_SECRET` (must match Edge secret)

### Manual run

Actions → **Daily reminder push** → Run workflow, or:

```bash
curl -X POST "$SUPABASE_URL/functions/v1/send-reminder-push" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "x-cron-secret: $CRON_SECRET" \
  -H "Content-Type: application/json" \
  -d '{}'
```
