# Supabase

Run this SQL in the Supabase SQL editor (or `supabase db push` if the CLI is linked).

1. Create a project at [supabase.com](https://supabase.com).
2. **Authentication → Providers → Google**: enable, add Client ID/secret from Google Cloud.
3. **Authentication → URL configuration**: add
   - `http://localhost:port` (Flutter web debug)
   - `https://phamchinang151020.github.io/home-manager/` (Pages)
4. Execute [`migrations/20260819000000_init.sql`](migrations/20260819000000_init.sql).
5. Copy **Project URL** (Overview → **Copy**, do not type) and **anon** key. Never use the service role in the Flutter app.

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
