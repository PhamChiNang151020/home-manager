# VS Code / Cursor launch

1. Copy `supabase.local.json.example` → `supabase.local.json` (same folder).
2. Fill values from Supabase **Project Overview → Copy** (Project URL) and **API Keys**.
3. Run and Debug → **home-manager (Chrome)** (F5).

`supabase.local.json` is gitignored — do not commit keys.

## Which API key?

Prefer **Legacy anon** (JWT starting with `eyJ...`) from tab *Legacy anon, service_role API keys*.

If login still fails with publishable key (`sb_publishable_...`), switch to legacy anon.

## Fix login DNS error

If Chrome shows `DNS_PROBE_FINISHED_NXDOMAIN` on `*.supabase.co`, the **Project URL is wrong** (typo in project ref). Copy again from Supabase Overview — do not type by hand.

Test in browser: open `https://YOUR_PROJECT_REF.supabase.co` — you should see JSON `{"error":"requested path is invalid"}` (that means the domain exists).
