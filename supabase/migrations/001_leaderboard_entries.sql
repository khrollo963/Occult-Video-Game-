-- OccultVideoGame leaderboard schema
create table if not exists public.leaderboard_entries (
  id          uuid primary key default gen_random_uuid(),
  initials    char(3) not null check (initials ~ '^[A-Z0-9]{3}$'),
  session_id  uuid not null,
  game_id     text not null check (game_id in ('mike', 'gabe', 'yuri', 'raph')),
  score       int not null check (score >= 0 and score <= 9999999),
  created_at  timestamptz not null default now()
);

create index if not exists idx_leaderboard_game_score
  on public.leaderboard_entries (game_id, score desc, created_at desc);

alter table public.leaderboard_entries enable row level security;

drop policy if exists "Public read leaderboard" on public.leaderboard_entries;
create policy "Public read leaderboard"
  on public.leaderboard_entries for select using (true);

drop policy if exists "Anon insert scores" on public.leaderboard_entries;
create policy "Anon insert scores"
  on public.leaderboard_entries for insert
  with check (
    length(initials) = 3
    and game_id in ('mike', 'gabe', 'yuri', 'raph')
    and score >= 0
  );
