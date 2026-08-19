# home-manager

Flutter Web PWA for family electricity (two homes, Google login, Supabase). Vietnamese UI. No App Store, no Developer Mode.

## Requirements

- Flutter **3.29.2**
- A Supabase project (see [supabase/README.md](supabase/README.md))

## Run locally

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Copy [env.example](env.example) for the names of those values. Do not commit real keys in `.env`.

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
