# Supabase Leaderboard Setup — OccultVideoGame

Global scores for Glory Quest Arcade use Supabase project **OccultVideoGame**.

## Project

| Field | Value |
|-------|-------|
| Name | OccultVideoGame |
| URL | `https://kcbfzmiqbogxydkepevm.supabase.co` |
| Table | `public.leaderboard_entries` |

## Schema

Applied via Supabase MCP or `supabase/migrations/001_leaderboard_entries.sql`:

- **initials** — 3 characters (A–Z, 0–9)
- **session_id** — UUID per browser/device
- **game_id** — `mike`, `gabe`, `yuri`, or `raph`
- **score** — integer 0–9,999,999

RLS: public `SELECT`, anon `INSERT` only.

## Local Godot config

1. Copy `config/leaderboard.cfg.example` to `config/leaderboard.cfg` (gitignored).
2. Set `url` and `anon_key` from Supabase Dashboard → Project Settings → API.
3. Only the **anon** or **publishable** key belongs in the client — never the service role key.

## GitHub Pages CI

Add these repository secrets (**Settings → Secrets and variables → Actions**):

| Secret | Value |
|--------|-------|
| `SUPABASE_URL` | `https://kcbfzmiqbogxydkepevm.supabase.co` |
| `SUPABASE_ANON_KEY` | Your project anon/publishable key |

The export workflow writes `config/leaderboard.cfg` before building the Web export. The Web export preset also lists that file in `include_filter` so Godot packs it into the build (plain `.cfg` files are not exported by default). If secrets are missing, the build still succeeds but the live leaderboard is disabled.

## MCP workflow

1. Authenticate Supabase MCP in Cursor.
2. `list_projects` → select OccultVideoGame (`kcbfzmiqbogxydkepevm`).
3. `apply_migration` with SQL from `supabase/migrations/001_leaderboard_entries.sql`.
4. `get_advisors` → confirm RLS is enabled.

## CORS

Supabase REST allows browser requests from GitHub Pages when using the standard anon key headers (`apikey`, `Authorization`).
