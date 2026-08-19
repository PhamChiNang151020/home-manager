# home-manager

Flutter Web PWA for family electricity (two homes, Google login, Supabase). Vietnamese UI. No App Store, no Developer Mode.

## Requirements

- Flutter **3.29.2**
- A Supabase project (see [supabase/README.md](supabase/README.md))

## Run locally

**Cursor / VS Code (recommended):**

1. `cp .vscode/supabase.local.json.example .vscode/supabase.local.json`
2. Paste **Project URL** and **anon key** from Supabase (see [supabase/README.md](supabase/README.md))
3. Run and Debug → **home-manager (Chrome)** (port 8080)

**Terminal:**

```bash
flutter pub get
flutter run -d chrome --web-port=8080 \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Do not commit `.vscode/supabase.local.json` or `.env` with real keys.

## iPhone

After GitHub Pages (or fallback host) is live: Safari → Share → **Add to Home Screen**.

## Deploy (GitHub Pages)

Workflow: [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml).

1. Repo **Settings → Pages → Build and deployment → GitHub Actions**.
2. Secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
3. Add the Pages URL to Supabase Auth redirect URLs.

`flutter build web --base-href /home-manager/`

**Private repo:** GitHub Pages from a private repository often needs GitHub Pro. If Pages cannot be enabled, use **Cloudflare Pages** or **Firebase Hosting** with the same `build/web` output and keep this GitHub repo as source.

## Architecture

See [.cursor/notes.md](.cursor/notes.md) and [.cursor/docs/architecture.md](.cursor/docs/architecture.md).
