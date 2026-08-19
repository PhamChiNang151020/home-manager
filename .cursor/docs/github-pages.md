# GitHub Pages

Production URL (project site): `https://phamchinang151020.github.io/home-manager/`

Build:

```bash
flutter build web --release --base-href /home-manager/ \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

CI: `.github/workflows/deploy-pages.yml` (Flutter 3.29.2, analyze, test, upload Pages artifact).

Enable: repo Settings → Pages → Source = GitHub Actions. Add secrets `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Add the Pages origin to Supabase Auth redirect URLs.

## Private repo

GitHub Pages on a **private** repository often requires GitHub Pro. The published site is still public.

Fallback (same `build/web` folder, still free):

1. **Cloudflare Pages** — connect the GitHub repo, build command as above, output `build/web`.
2. **Firebase Hosting** — `firebase deploy --only hosting` after `flutter build web --base-href /`.

Keep GitHub as the source of truth either way.
