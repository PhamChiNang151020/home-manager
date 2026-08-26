# Web Push / FCM (Phase 1+)

Phase 1 (infra only): Firebase Cloud Messaging on Flutter Web — permission + FCM
token. No scheduled send yet.

## Local setup

1. Copy `.vscode/firebase.local.example.json` → `.vscode/firebase.local.json` and fill values.
2. Copy `web/firebase-config.example.json` → `web/firebase-config.json` (no VAPID; SW only).
3. Chrome launch configs already pass `--dart-define-from-file=.vscode/firebase.local.json`.

## Deploy

GitHub Actions (`deploy-pages.yml`) injects `FIREBASE_*` dart-defines and writes
`build/web/firebase-config.json` from repository secrets.

## Secrets (Actions)

`FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`,
`FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`,
`FIREBASE_VAPID_KEY`.

## Why later (send)

iOS Safari delivers Web Push **only** for apps added to the Home Screen (iOS 16.4+).
Needs HTTPS, service worker, VAPID, user permission, and a **server cron** to send.

Outline for later phases:

1. Store FCM tokens in Supabase.
2. Edge Function / cron for remind days.
3. Copy: “Hôm nay chụp hoá đơn điện — Nhà ba mẹ”, etc.
