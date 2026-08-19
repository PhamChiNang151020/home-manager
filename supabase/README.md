# Supabase

Run this SQL in the Supabase SQL editor (or `supabase db push` if the CLI is linked).

1. Create a project at [supabase.com](https://supabase.com).
2. **Authentication → Providers → Google**: enable, add Client ID/secret from Google Cloud.
3. **Authentication → URL configuration**: add
   - `http://localhost:port` (Flutter web debug)
   - `https://phamchinang151020.github.io/home-manager/` (Pages)
4. Execute [`migrations/20260819000000_init.sql`](migrations/20260819000000_init.sql).
5. Copy **Project URL** and **anon public** key. Never use the service role in the Flutter app.

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Storage paths: `homes/{home_id}/{yyyy-mm}.jpg` in bucket `bill-photos`.
