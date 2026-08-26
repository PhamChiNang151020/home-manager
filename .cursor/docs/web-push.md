# Web Push / FCM

## Phase 1 — permission + token (done)

Flutter Web FCM: request permission, show token, background SW `showNotification`.

### Local setup

1. Copy `.vscode/firebase.local.example.json` → `.vscode/firebase.local.json`.
2. Copy `web/firebase-config.example.json` → `web/firebase-config.json` (no VAPID).
3. Chrome launch uses `--dart-define-from-file=.vscode/firebase.local.json`.

### Deploy (Pages)

`deploy-pages.yml` injects `FIREBASE_*` dart-defines and writes `build/web/firebase-config.json`.

**GitHub Secrets (Pages):** `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`,
`FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`,
`FIREBASE_APP_ID`, `FIREBASE_VAPID_KEY`.

**Pinned packages** (Flutter 3.29.2 / Dart 3.7.2): `firebase_core` 4.13.0,
`firebase_core_web` 3.10.0, `firebase_messaging` 16.5.0 — see `pubspec.yaml`.

## Phase 2 — store tokens (done)

- Migration: `supabase/migrations/20260826170000_fcm_tokens.sql`
- App: `FcmTokenService` + `NotificationService.enableAndRegister()` upserts after grant
- UI: Cá nhân → Cài đặt → **Bật thông báo (thử nghiệm)**

Apply migration on the Supabase project before testing save.

## Phase 3 — daily reminder push (done)

- Edge Function: `supabase/functions/send-reminder-push/`
- Cron: `.github/workflows/daily-reminder-push.yml` at **08:00 ICT** (`0 1 * * *` UTC)
- Matches `photo_due_day` / `payday_day` / `remind_day` (clamped to month length, VN timezone)
- Notifies all home members who have rows in `fcm_tokens`

### Supabase Edge Secrets

| Secret | Purpose |
|--------|---------|
| `CRON_SECRET` | Shared bearer for GitHub Actions → function |
| `FIREBASE_PROJECT_ID` | `homemanager-85843` |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Full Firebase **service account** JSON (Admin / FCM) |

### GitHub Secrets (cron workflow)

| Secret | Purpose |
|--------|---------|
| `SUPABASE_URL` | Already used by Pages deploy |
| `CRON_SECRET` | Same value as Supabase Edge `CRON_SECRET` |

### Deploy function

Dashboard → Edge Functions → create **`send-reminder-push`** → paste `index.ts` → Deploy.
Or: `supabase functions deploy send-reminder-push`

### Manual test

GitHub Actions → **Daily reminder push** → Run workflow. Or:

```bash
curl -X POST "$SUPABASE_URL/functions/v1/send-reminder-push" \
  -H "Authorization: Bearer $CRON_SECRET" \
  -H "Content-Type: application/json" \
  -d '{}'
```

Set a home’s schedule day to **today (VN)** and ensure the user saved an FCM token first.
