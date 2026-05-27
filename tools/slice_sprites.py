#!/usr/bin/env python3
"""Slice character sprite sheets and emit Godot 4 SpriteFrames .tres resources."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
CHAR_DIR = ROOT / "assets" / "characters"
FRAMES_DIR = ROOT / "assets" / "characters" / "frames"
OUTPUT_DIR = ROOT / "tools" / "output"


def rect(x: int, y: int, w: int, h: int) -> tuple[int, int, int, int]:
    return (x, y, w, h)


# Verified rects from Pillow analysis (top color variant for Mike).
MIKE_ANIMS: dict[str, list[tuple[int, int, int, int]]] = {
    "idle": [rect(0, 0, 50, 48)],
    "walk": [
        rect(0, 0, 50, 48),
        rect(50, 0, 50, 48),
        rect(100, 0, 50, 48),
        rect(150, 0, 50, 48),
        rect(200, 0, 50, 48),
        rect(250, 0, 50, 48),
    ],
    "attack": [
        rect(0, 48, 50, 48),
        rect(50, 48, 50, 48),
        rect(100, 48, 50, 48),
        rect(150, 48, 50, 48),
        rect(200, 48, 50, 48),
    ],
    "jump": [rect(50, 96, 50, 48)],
}

GABE_ANIMS: dict[str, list[tuple[int, int, int, int]]] = {
    "idle": [rect(1, 1, 79, 85)],
    "jump": [
        rect(1, 55, 99, 75),
        rect(100, 55, 100, 75),
        rect(200, 55, 100, 75),
    ],
    "fly": [
        rect(1, 165, 128, 55),
        rect(131, 171, 129, 49),
        rect(262, 173, 120, 47),
        rect(1, 220, 128, 55),
        rect(131, 220, 129, 55),
        rect(262, 220, 117, 55),
        rect(10, 275, 119, 55),
        rect(192, 275, 107, 55),
    ],
    "attack": [rect(200, 55, 100, 75)],
}

YURI_ANIMS: dict[str, list[tuple[int, int, int, int]]] = {
    "idle": [rect(0, 0, 149, 96)],
    "run": [
        rect(298, 0, 149, 96),
        rect(447, 0, 149, 96),
        rect(0, 96, 149, 96),
        rect(149, 96, 149, 96),
        rect(298, 96, 149, 96),
    ],
    "jump": [rect(0, 96, 149, 96)],
    "duck": [rect(298, 0, 149, 96)],
}

RALPH_ANIMS: dict[str, list[tuple[int, int, int, int]]] = {
    "idle": [rect(27, 9, 44, 71)],
    "jump": [
        rect(15, 480, 74, 120),
        rect(164, 480, 78, 120),
        rect(310, 480, 96, 120),
    ],
    "fall": [
        rect(19, 572, 72, 99),
        rect(178, 560, 66, 111),
        rect(356, 560, 55, 111),
    ],
}

CHARACTERS = {
    "mike_lion": {
        "texture": "res://assets/characters/Mike_lion.png",
        "file": CHAR_DIR / "Mike_lion.png",
        "animations": MIKE_ANIMS,
        "speeds": {"idle": 5.0, "walk": 8.0, "attack": 10.0, "jump": 5.0},
    },
    "gabe_eagle": {
        "texture": "res://assets/characters/Gabe Eagle.png",
        "file": CHAR_DIR / "Gabe Eagle.png",
        "animations": GABE_ANIMS,
        "speeds": {"idle": 5.0, "jump": 8.0, "fly": 10.0, "attack": 8.0},
    },
    "yuri_bull": {
        "texture": "res://assets/characters/Yuri Bull.png",
        "file": CHAR_DIR / "Yuri Bull.png",
        "animations": YURI_ANIMS,
        "speeds": {"idle": 5.0, "run": 10.0, "jump": 5.0, "duck": 5.0},
    },
    "ralph_char": {
        "texture": "res://assets/characters/Ralph_char.png",
        "file": CHAR_DIR / "Ralph_char.png",
        "animations": RALPH_ANIMS,
        "speeds": {"idle": 5.0, "jump": 8.0, "fall": 8.0},
    },
}


def make_preview(name: str, sheet_path: Path, animations: dict[str, list[tuple]]) -> None:
    img = Image.open(sheet_path).convert("RGBA")
    frames: list[tuple[str, Image.Image]] = []
    for anim_name, rects in animations.items():
        for i, (x, y, w, h) in enumerate(rects):
            crop = img.crop((x, y, x + w, y + h))
            frames.append((f"{anim_name}_{i}", crop))

    if not frames:
        return

    max_h = max(f[1].size[1] for f in frames)
    pad = 4
    x_cursor = pad
    preview = Image.new("RGBA", (sum(f[1].size[0] for f in frames) + pad * (len(frames) + 1), max_h + 30 + pad * 2), (32, 32, 48, 255))
    draw = ImageDraw.Draw(preview)

    for label, crop in frames:
        preview.paste(crop, (x_cursor, pad + 20), crop)
        draw.text((x_cursor, 2), label, fill=(220, 220, 255, 255))
        x_cursor += crop.size[0] + pad

    out = OUTPUT_DIR / f"{name}_preview.png"
    preview.save(out)
    print(f"Wrote preview {out}")


def _format_animations(animations: dict[str, list[tuple]], speeds: dict[str, float], atlas_id_map: list[tuple[str, str]]) -> str:
    """Build Godot animations array text with proper SubResource references."""
    cursor = 0
    lines = ["animations = ["]
    for anim_name, rects in animations.items():
        loop = anim_name not in ("attack", "jump")
        speed = speeds.get(anim_name, 5.0)
        lines.append("{")
        lines.append('"frames": [')
        for _ in rects:
            aid = atlas_id_map[cursor][0]
            lines.append('{')
            lines.append('"duration": 1.0,')
            lines.append(f'"texture": SubResource("{aid}")')
            lines.append("},")
            cursor += 1
        lines.append("],")
        lines.append(f'"loop": {"true" if loop else "false"},')
        lines.append(f'"name": &"{anim_name}",')
        lines.append(f'"speed": {speed}')
        lines.append("},")
    lines.append("]")
    return "\n".join(lines)


def emit_spriteframes(name: str, texture_path: str, animations: dict[str, list[tuple]], speeds: dict[str, float]) -> None:
    atlas_blocks: list[str] = []
    atlas_id_map: list[tuple[str, str]] = []

    idx = 0
    for anim_name, rects in animations.items():
        for x, y, w, h in rects:
            aid = f"AtlasTexture_{idx}"
            atlas_id_map.append((aid, anim_name))
            atlas_blocks.append(
                f'[sub_resource type="AtlasTexture" id="{aid}"]\natlas = ExtResource("1_tex")\nregion = Rect2({x}, {y}, {w}, {h})\n'
            )
            idx += 1

    load_steps = 1 + len(atlas_id_map) + 1
    lines = [
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]\n',
        f'[ext_resource type="Texture2D" path="{texture_path}" id="1_tex"]\n',
    ]
    lines.extend(atlas_blocks)
    lines.append("[resource]\n")
    lines.append(_format_animations(animations, speeds, atlas_id_map) + "\n")

    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    out_path = FRAMES_DIR / f"{name}.tres"
    out_path.write_text("".join(lines), encoding="utf-8")
    print(f"Wrote {out_path}")


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)

    for name, cfg in CHARACTERS.items():
        make_preview(name, cfg["file"], cfg["animations"])
        emit_spriteframes(name, cfg["texture"], cfg["animations"], cfg["speeds"])


if __name__ == "__main__":
    main()
