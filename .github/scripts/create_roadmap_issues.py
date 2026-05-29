#!/usr/bin/env python3
"""Create labels, milestones, and roadmap GitHub issues. Run once: python create_roadmap_issues.py"""
import json
import subprocess
import sys

REPO = "khrollo963/Occult-Video-Game-"


def run(cmd: list[str], check: bool = True) -> str:
    r = subprocess.run(cmd, capture_output=True, text=True)
    if check and r.returncode != 0:
        print(r.stderr or r.stdout, file=sys.stderr)
        sys.exit(r.returncode)
    return (r.stdout or "").strip()


def gh_api(method: str, path: str, fields: dict | None = None) -> dict:
    cmd = ["gh", "api", "-X", method, f"repos/{REPO}/{path}"]
    if fields:
        for k, v in fields.items():
            cmd.extend(["-f", f"{k}={v}"])
    out = run(cmd)
    return json.loads(out) if out else {}


def ensure_label(name: str, color: str, description: str) -> None:
    r = subprocess.run(
        ["gh", "label", "create", name, "--color", color, "--description", description, "--repo", REPO],
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        print(f"  label {name}: already exists or skipped")


def get_or_create_milestone(title: str, description: str, due_on: str) -> int:
    milestones = json.loads(run(["gh", "api", f"repos/{REPO}/milestones", "--paginate"]))
    for m in milestones:
        if m["title"] == title:
            return m["number"]
    created = gh_api("POST", "milestones", {"title": title, "description": description, "due_on": due_on})
    return created["number"]


def create_issue(title: str, labels: list[str], milestone: int, body: str) -> int:
    fields = {
        "title": title,
        "body": body,
        "labels": ",".join(labels),
    }
    cmd = ["gh", "api", "-X", "POST", f"repos/{REPO}/issues", "-f", f"title={title}", "-f", f"body={body}"]
    for lab in labels:
        cmd.extend(["-f", f"labels[]={lab}"])
    cmd.extend(["-f", f"milestone={milestone}"])
    out = run(cmd)
    data = json.loads(out)
    num = data["number"]
    print(f"  #{num} {title}")
    return num


LABELS = [
    ("bug", "d73a4a", "Something is broken"),
    ("enhancement", "a2eeef", "New feature or improvement"),
    ("game:gabe", "1d76db", "Gabe's Spectacular Collector"),
    ("game:raph", "0e8a16", "Raph's Funny Flight"),
    ("game:mike", "fbca04", "Mike's Daunting Quest"),
    ("game:yuri", "d876e3", "Yuri's Crazy Endless Runner"),
    ("area:global", "5319e7", "Cross-game / project-wide"),
    ("area:ci", "006b75", "CI/CD and export pipeline"),
    ("roadmap", "c5def5", "Tracked on milestone roadmap"),
]

MILESTONES = [
    ("Month 1 - Bug Triage and Stability", "Close scaffolding bugs; renderer/export fixes; CI import validation.", "2026-06-30T23:59:59Z"),
    ("Month 2 - Raph Feature Complete", "Spring pads, coins, hazards; leaderboard UX; session scores.", "2026-07-31T23:59:59Z"),
    ("Month 3 - Gabe Expansion and Test Health", "Export exclusions; Mike/Yuri sweeps; GUT coverage.", "2026-08-31T23:59:59Z"),
    ("Month 4 - Mobile and Visual Identity", "Touch controls; art pass begins.", "2026-09-30T23:59:59Z"),
    ("Month 5 - Cross-Game Systems", "Unified save/meta; audio tab-blur; transition audit.", "2026-10-31T23:59:59Z"),
    ("Month 6 - Polish and v1.0 Release", "Full art pass; performance; tag v1.0.0.", "2026-11-30T23:59:59Z"),
    ("Q2 2026 - Four Pillars Standing", "All four mini-games stable; CI validates import/export/Supabase.", "2026-08-31T23:59:59Z"),
    ("Q3 2026 - Glory Quest v1.0 Ships", "Polished public release with original art and mobile.", "2026-11-30T23:59:59Z"),
]

ISSUES = [
    # (title, labels, milestone_index 0-7, body)
    (
        "BUG-001: Gabe flip_h not tied to velocity direction",
        ["bug", "game:gabe", "roadmap"],
        0,
        """**Game:** Gabe's Spectacular Collector
**Parent:** #4

Gabe's sprite flips in the wrong direction relative to movement.

**Likely causes:**
- `flip_h` set from `Input.get_axis()` without proper sign handling
- Parent `CharacterBody2D` has x scale -1 inverting flip again
- Sprite sheet sliced right-to-left in `tools/slice_sprites.py`

**Expected fix:**
```gdscript
if velocity.x != 0:
    $AnimatedSprite2D.flip_h = velocity.x < 0
```

Audit `tools/slice_sprites.py` output order against source PNG.""",
    ),
    (
        "BUG-002: Gabe obstacle spawner not scaling with waves",
        ["bug", "game:gabe", "roadmap"],
        0,
        """**Game:** Gabe's Spectacular Collector
**Parent:** #4

Obstacle spawn rate stays static; some sessions see no obstacle for over a minute despite 9 waves.

**Expected fix:**
```gdscript
func _on_wave_changed(wave: int) -> void:
    $SpawnTimer.wait_time = max(0.4, base_interval - (wave * 0.15))
    $SpawnTimer.start()
```

Verify `EventBus.wave_changed.connect(...)` in `_ready()`.""",
    ),
    (
        "BUG-003: Raph high score records fall position, not apex",
        ["bug", "game:raph", "roadmap"],
        0,
        """**Game:** Raph's Funny Flight
**Parent:** #1

Score uses Y at game-over instead of max height. Apex = minimum Y during play.

```gdscript
var apex_score: int = 0
func _physics_process(delta: float) -> void:
    var height = int(-position.y / SCORE_SCALE_FACTOR)
    if height > apex_score:
        apex_score = height
# On game over: ScoreManager.submit_score("raphael", apex_score)
```""",
    ),
    (
        "BUG-004: Raph platform texture randomiser - collision mismatch",
        ["bug", "game:raph", "roadmap"],
        0,
        """**Game:** Raph's Funny Flight
**Parent:** #1

Random textures without matching `CollisionShape2D` size.

```gdscript
func set_platform_type(type: int) -> void:
    $Sprite2D.texture = PLATFORM_TEXTURES[type]
    var tex_size = PLATFORM_TEXTURES[type].get_size()
    $CollisionShape2D.shape.size = tex_size
```""",
    ),
    (
        "BUG-005: Raph sprite animation choppy (frame rate / import)",
        ["bug", "game:raph", "roadmap"],
        0,
        """**Game:** Raph's Funny Flight
**Parent:** #1

Check AnimatedSprite2D FPS (10-12+), `.tres` frame count vs `slice_sprites.py`, reimport after slice.""",
    ),
    (
        "BUG-006: attack / ui_accept missing main Return key",
        ["bug", "area:global", "roadmap"],
        0,
        """**File:** `project.godot`

Add `KEY_ENTER` to `attack` action (not only numpad Enter).""",
    ),
    (
        "BUG-007: Leaderboard silent failure when Supabase config invalid",
        ["bug", "area:global", "roadmap"],
        1,
        """**Files:** `scripts/leaderboard_service.gd`, `config/leaderboard.cfg`

Validate config on `_ready()`; expose `is_available` for UI fallback message.""",
    ),
    (
        "BUG-008: Forward Plus renderer incompatible with Web export",
        ["bug", "area:global", "roadmap"],
        0,
        """**File:** `project.godot`

Switch to Compatibility renderer for browser-first Web export.""",
    ),
    (
        "BUG-009: Jolt Physics declared but unused (2D-only game)",
        ["bug", "area:global", "roadmap"],
        0,
        """**File:** `project.godot`

Remove `3d/physics_engine="Jolt Physics"` to reduce Web export size.""",
    ),
    (
        "BUG-010: .godot/ UID mismatches on fresh clone",
        ["bug", "area:global", "roadmap"],
        1,
        """Commit `uid_cache.bin`, add `make reimport`, or CI headless import validation on PRs.""",
    ),
    (
        "BUG-011: GUT tests/ not excluded from Web export",
        ["bug", "area:ci", "roadmap"],
        2,
        """**File:** `export_presets.cfg`

`exclude_filter="tests/*,addons/gut/*"`""",
    ),
    (
        "FEAT-001: Raph spring/jump pad Area2D node",
        ["enhancement", "game:raph", "roadmap"],
        1,
        """**Parent:** #3

`scenes/levels/Raphael/spring_pad.tscn` with impulse, animation, SFX. ~15% platform spawn rate.""",
    ),
    (
        "FEAT-002: Raph coin collectibles with height-weighted value",
        ["enhancement", "game:raph", "roadmap"],
        1,
        """**Parent:** #3

`coin.tscn` Area2D; ~30% platforms; value scales with apex (BUG-003).""",
    ),
    (
        "FEAT-003: Raph hazardous platforms (crumble / spike)",
        ["enhancement", "game:raph", "roadmap"],
        1,
        """**Parent:** #3

`platform_type`: NORMAL, CRUMBLE, SPIKE. Hazard frequency vs height.""",
    ),
    (
        "FEAT-004: Audit duck action across Mike and Gabe",
        ["enhancement", "area:global", "roadmap"],
        2,
        """Implement dodge for Mike / evasive drop for Gabe, or document intentional no-op.""",
    ),
    (
        "FEAT-005: ScoreManager per-session score history",
        ["enhancement", "area:global", "roadmap"],
        1,
        """Last N runs in `arcade_save.cfg` (PackedInt32Array, cap 10).""",
    ),
    (
        "FEAT-006: Mobile touch controls overlay",
        ["enhancement", "area:global", "roadmap"],
        3,
        """`scenes/UI/touch_controls.tscn` with TouchScreenButton; load on mobile/touchscreen.""",
    ),
    (
        "FEAT-007: CI headless Godot import validation",
        ["enhancement", "area:ci", "roadmap"],
        0,
        """Add `godot4 --headless --import --quit` before Web export in GitHub Actions.""",
    ),
    (
        "FEAT-008: CI verify Supabase config in export bundle",
        ["enhancement", "area:ci", "roadmap"],
        2,
        """Post-export grep check that `build/leaderboard.cfg` has populated Supabase fields.""",
    ),
    (
        "ROADMAP: AudioManager mute on tab blur (Web)",
        ["enhancement", "area:global", "roadmap"],
        4,
        """Mute/pause audio when document visibility hidden on Web export.""",
    ),
    (
        "ROADMAP: TransitionManager scene leak audit",
        ["enhancement", "area:global", "roadmap"],
        4,
        """Ensure queue_free on scene change; no orphaned AudioStreamPlayer nodes.""",
    ),
    (
        "ROADMAP: Unified GameData / four-game completion tracking",
        ["enhancement", "area:global", "roadmap"],
        4,
        """Extend GameManager for meta-progression across all four mini-games.""",
    ),
    (
        "ROADMAP: Occult art pass - all four characters",
        ["enhancement", "roadmap"],
        5,
        """Replace placeholders; update slice_sprites.py. Q3 v1.0 exit criteria.""",
    ),
    (
        "ROADMAP: Web export performance profiling (mobile mid-tier)",
        ["enhancement", "area:ci", "roadmap"],
        5,
        """FPS profiling on mid-tier mobile before v1.0.0 tag.""",
    ),
    (
        "ROADMAP: Tag release v1.0.0",
        ["enhancement", "roadmap"],
        5,
        """GitHub release when Month 6 exit criteria met.""",
    ),
]


def main() -> None:
    print("Creating labels...")
    for name, color, desc in LABELS:
        ensure_label(name, color, desc)

    print("Creating milestones...")
    ms: list[int] = []
    for title, desc, due in MILESTONES:
        n = get_or_create_milestone(title, desc, due)
        ms.append(n)
        print(f"  M{n}: {title}")

    print("Creating issues...")
    created: list[int] = []
    for title, labels, mi, body in ISSUES:
        num = create_issue(title, labels, ms[mi], body)
        created.append(num)

    print(f"\nCreated {len(created)} issues: #{created[0]}..#{created[-1]}")
    print(f"https://github.com/{REPO}/milestones")


if __name__ == "__main__":
    main()
