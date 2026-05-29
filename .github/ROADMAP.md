# Glory Quest Arcade — Roadmap

Technical backlog and release plan for [Glory Quest Arcade](https://khrollo963.github.io/Occult-Video-Game-/).  
Source: technical issues document (May 2026).

**How to use this roadmap**

| Mechanism | Purpose |
|-----------|---------|
| [Milestones](https://github.com/khrollo963/Occult-Video-Game-/milestones) | Month 1–6 and Q2/Q3 goals — filter issues by target window |
| Labels `bug`, `enhancement`, `game:*`, `area:*`, `roadmap` | Triage and board views |
| Issues `BUG-###` / `FEAT-###` | Actionable work items |
| Scaffolding issues [#1](https://github.com/khrollo963/Occult-Video-Game-/issues/1)–[#5](https://github.com/khrollo963/Occult-Video-Game-/issues/5) | Original high-level buckets |

### GitHub Projects (optional)

The repo owner can attach these milestones to a **GitHub Project** board:

1. Run `gh auth refresh -h github.com -s project,read:project` locally.
2. Create a project: **Projects → New project → Board**.
3. Add the `Occult-Video-Game-` repository and group by **Milestone** or **Labels**.

Until Projects are configured, **Milestones** are the canonical schedule.

---

## Month 1 — Bug Triage and Stability (June 2026)

**Theme:** Close scaffolding bugs; fix renderer and export config; reliable CI.

| Issue | Title |
|-------|-------|
| [#8](https://github.com/khrollo963/Occult-Video-Game-/issues/8) | BUG-003: Raph apex scoring |
| [#9](https://github.com/khrollo963/Occult-Video-Game-/issues/9) | BUG-004: Raph platform collision |
| [#10](https://github.com/khrollo963/Occult-Video-Game-/issues/10) | BUG-005: Raph animation choppy |
| [#6](https://github.com/khrollo963/Occult-Video-Game-/issues/6) | BUG-001: Gabe flip_h |
| [#7](https://github.com/khrollo963/Occult-Video-Game-/issues/7) | BUG-002: Gabe spawner scaling |
| [#13](https://github.com/khrollo963/Occult-Video-Game-/issues/13) | BUG-008: Compatibility renderer |
| [#14](https://github.com/khrollo963/Occult-Video-Game-/issues/14) | BUG-009: Remove Jolt |
| [#11](https://github.com/khrollo963/Occult-Video-Game-/issues/11) | BUG-006: Return key on attack |
| [#23](https://github.com/khrollo963/Occult-Video-Game-/issues/23) | FEAT-007: CI headless import |

**Exit criteria:** Close [#1](https://github.com/khrollo963/Occult-Video-Game-/issues/1) and [#4](https://github.com/khrollo963/Occult-Video-Game-/issues/4); GitHub Pages CI clean.

---

## Month 2 — Raph Feature Complete (July 2026)

| Issue | Title |
|-------|-------|
| [#17](https://github.com/khrollo963/Occult-Video-Game-/issues/17) | FEAT-001: Spring pads |
| [#18](https://github.com/khrollo963/Occult-Video-Game-/issues/18) | FEAT-002: Coins |
| [#19](https://github.com/khrollo963/Occult-Video-Game-/issues/19) | FEAT-003: Hazard platforms |
| [#12](https://github.com/khrollo963/Occult-Video-Game-/issues/12) | BUG-007: Leaderboard fallback UI |
| [#15](https://github.com/khrollo963/Occult-Video-Game-/issues/15) | BUG-010: UID cache / reimport |
| [#21](https://github.com/khrollo963/Occult-Video-Game-/issues/21) | FEAT-005: Session score history |

**Exit criteria:** Raph playable end-to-end; leaderboard shows offline state when needed. Close [#3](https://github.com/khrollo963/Occult-Video-Game-/issues/3).

---

## Month 3 — Gabe Expansion and Test Health (August 2026)

| Issue | Title |
|-------|-------|
| [#16](https://github.com/khrollo963/Occult-Video-Game-/issues/16) | BUG-011: Exclude tests from export |
| [#20](https://github.com/khrollo963/Occult-Video-Game-/issues/20) | FEAT-004: Duck action audit |
| [#24](https://github.com/khrollo963/Occult-Video-Game-/issues/24) | FEAT-008: CI Supabase bundle check |

**Also:** Fill [#5](https://github.com/khrollo963/Occult-Video-Game-/issues/5) (Gabe features); open Mike/Yuri bug sweeps; GUT smoke tests for ScoreManager, LeaderboardService, AudioManager.

**Exit criteria:** All four games have filed bug/feature issues; GUT passes headlessly.

---

## Q2 2026 — Four Pillars Standing

All four mini-games bug-free to documented scope; CI validates import, export, and Supabase injection. See milestone **Q2 2026**.

---

## Month 4 — Mobile and Visual Identity (September 2026)

| Issue | Title |
|-------|-------|
| [#22](https://github.com/khrollo963/Occult-Video-Game-/issues/22) | FEAT-006: Touch controls |

**Also:** Occult art pass start; `slice_sprites.py` updates; touch opacity setting.

---

## Month 5 — Cross-Game Systems (October 2026)

| Issue | Title |
|-------|-------|
| [#25](https://github.com/khrollo963/Occult-Video-Game-/issues/25) | AudioManager tab blur |
| [#26](https://github.com/khrollo963/Occult-Video-Game-/issues/26) | TransitionManager leak audit |
| [#27](https://github.com/khrollo963/Occult-Video-Game-/issues/27) | GameData / completion tracking |

---

## Month 6 — Polish and v1.0 Release (November 2026)

| Issue | Title |
|-------|-------|
| [#28](https://github.com/khrollo963/Occult-Video-Game-/issues/28) | Art pass (all characters) |
| [#29](https://github.com/khrollo963/Occult-Video-Game-/issues/29) | Web performance profiling |
| [#30](https://github.com/khrollo963/Occult-Video-Game-/issues/30) | Tag v1.0.0 |

**Exit criteria:** Shareable public URL; original art; no open critical bugs.

---

## Q3 2026 — Glory Quest v1.0 Ships

Polished arcade collection: mobile, leaderboard, original art. See milestone **Q3 2026**.

---

## Scaffolding → tracked issues

| Scaffolding | Tracked issues |
|-------------|----------------|
| [#1](https://github.com/khrollo963/Occult-Video-Game-/issues/1) Raph bugs | #8, #9, #10 |
| [#3](https://github.com/khrollo963/Occult-Video-Game-/issues/3) Raph features | #17, #18, #19 |
| [#4](https://github.com/khrollo963/Occult-Video-Game-/issues/4) Gabe bugs | #6, #7 |
| [#5](https://github.com/khrollo963/Occult-Video-Game-/issues/5) Gabe features | *(fill body; add issues in Month 3)* |
| [#2](https://github.com/khrollo963/Occult-Video-Game-/issues/2) Raph features (dup) | Consolidate with #3 |

---

## Regenerating issues

```bash
python .github/scripts/create_roadmap_issues.py
```

The script skips existing labels/milestones by title and only creates missing milestones. **Do not re-run** after issues exist unless you intend duplicates.
