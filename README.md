# Glory Quest Arcade

> *The Kerubic Signs descend into Samsara — four legendary beings, four unique battles, one sacred mission.*

A browser-playable Godot 4.6 arcade collection built around the four Holy Living Creatures (Tetramorph) from Ezekiel 1:10 and Revelation 4:7. Drawing from **Hermetic**, **Thelemic**, and **Gnostic** mystical traditions.

**Play:** [https://khrollo963.github.io/Occult-Video-Game-/](https://khrollo963.github.io/Occult-Video-Game-/)

---

## The Four Games (Current Build)

| Character | Game | Genre | Score |
|-----------|------|-------|-------|
| **Mike** (Lion) | Mike's Daunting Quest | Side-scrolling platformer + melee | Reach the goal; defeat enemies |
| **Gabe** (Eagle) | Gabe's Spectacular Collector | Flying collector / hazard dodge | Collect apples; survive hazards |
| **Yuri** (Bull) | Yuri's Crazy Endless Runner | Endless runner (jump + duck) | Distance traveled |
| **Raph** (Angel) | Raph's Funny Flight | Vertical platformer | Height climbed |

### Controls

See **Settings → How to Play** in-game for the full control reference.

| Action | Keys |
|--------|------|
| Move | `A` / `D` or Arrow keys |
| Jump | `Space` |
| Attack | `Enter` |
| Duck | `S` or Down arrow (Yuri) |
| Pause | `Escape` |

---

## What's Done

- [x] Godot 4.6 project with four playable prototypes
- [x] Main menu (character select, random start, Lore, Dev Team, Scripture, Settings, Leaderboard)
- [x] Settings with per-game tuning sliders + background style toggle
- [x] How to Play + Controls in Settings
- [x] Shared HUD, game over flow, scene transitions
- [x] Local high scores + medals; global Supabase leaderboard
- [x] AudioManager, EventBus, VFX particles, parallax backgrounds
- [x] Character sprite pipeline (`tools/slice_sprites.py`)
- [x] GitHub Pages Web export CI
- [x] Button sheen shader on menu buttons
- [x] Yuri duck mechanic for overhead obstacles

---

## What's Left (Stretch)

- [ ] Full boss battles for Raph (original README vision)
- [ ] Dedicated occult art pass (replace placeholder sprites)
- [ ] Mobile touch controls
- [ ] Localization

---

## Occult Themes

| Character | Element | Zodiac | Hermetic Principle |
|-----------|---------|--------|-------------------|
| **Mike** | Fire | Leo | Sulfur — Spirit ascending |
| **Gabe** | Air/Water | Scorpio | Mercury — The Word in motion |
| **Yuri** | Earth | Taurus | Salt — Matter reclaimed |
| **Raph** | Quintessence | Aquarius | The Great Work completed |

---

## Project Structure

```
Occult-Video-Game-/
├── assets/
│   ├── characters/       # Source PNGs + frames/*.tres
│   ├── enemies/          # Enemy placeholder sprites
│   ├── obstacles/        # Hazard / platform sprites
│   ├── audio/            # Music & SFX
│   ├── fonts/
│   └── ui/               # Theme, shaders
├── config/
│   └── leaderboard.cfg.example
├── docs/
│   └── leaderboard-setup.md
├── scenes/
│   ├── levels/
│   │   ├── Michael/      # Mike platformer
│   │   ├── Gabriel/      # Gabe collector
│   │   ├── Uriel/        # Yuri runner
│   │   └── Raphael/      # Raph vertical jumper
│   ├── UI/               # Menu, settings, leaderboard, HUD
│   └── vfx/              # Shared particle effects
├── scripts/              # Autoloads
├── supabase/migrations/  # Leaderboard schema
├── tests/                # GUT smoke tests
├── tools/
│   └── slice_sprites.py
└── project.godot
```

---

## Local Development

1. Open the project in **Godot 4.6+** (or run `godot4.exe` from project root if present).
2. Regenerate character frames: `.venv\Scripts\python.exe tools\slice_sprites.py`
3. Generate placeholder art: `python tools/generate_placeholders.py`
4. Player settings persist to `user://settings.cfg`; scores to `user://arcade_save.cfg`.
5. Copy `config/leaderboard.cfg.example` → `config/leaderboard.cfg` and fill Supabase URL + anon key (see [docs/leaderboard-setup.md](docs/leaderboard-setup.md)).

---

## Development Roadmap

### Phase 1 — Foundation ✅
- [x] Repo, Godot project, main menu, four prototypes, Web CI

### Phase 2 — Arcade Polish ✅
- [x] AudioManager, transitions, local scores, EventBus, VFX, How to Play

### Phase 3 — Visual Identity ✅
- [x] Parallax backgrounds, placeholder sprites, hit/glow shaders

### Phase 4 — Game Depth ✅
- [x] Mike level variety, Gabe 9 waves, Yuri power-ups, Raph hazards + HP

### Phase 5 — Global Leaderboard ✅
- [x] OccultVideoGame Supabase project, 3-char initials, public leaderboard UI

### Phase 6 — Meta & Release ✅
- [x] Menu high scores, medals, random-start splash, Leaderboard button

### Phase 7 — Production ✅
- [x] UID fixes, GUT tests, visual quality preset, leaderboard docs

---

## Known Issues

- On a fresh clone, delete `.godot/` and reimport if you see invalid UID warnings.
- Theme is referenced via `res://assets/ui/arcade_theme.tres` in `project.godot` (not hand-written UIDs).

---

## Leaderboard

Global scores are stored in Supabase project **OccultVideoGame**. Setup instructions: [docs/leaderboard-setup.md](docs/leaderboard-setup.md).

For local dev, copy `config/leaderboard.cfg.example` to `config/leaderboard.cfg` and add your anon key. For GitHub Pages, set the `SUPABASE_URL` and `SUPABASE_ANON_KEY` repository secrets so CI injects config at export time.

---

*Built with Godot 4 • Inspired by the Western Esoteric Tradition • Glory Quest Arcade*
