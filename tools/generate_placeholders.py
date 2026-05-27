#!/usr/bin/env python3
"""Generate simple occult-themed placeholder PNG sprites."""

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    raise SystemExit("Install Pillow: pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]

SPECS = {
    "assets/enemies/shade.png": ((48, 48), (0.45, 0.1, 0.55, 1.0), "eye"),
    "assets/obstacles/spike.png": ((32, 32), (0.7, 0.15, 0.15, 1.0), "spike"),
    "assets/obstacles/sigil.png": ((32, 32), (0.85, 0.2, 0.85, 1.0), "circle"),
    "assets/obstacles/platform.png": ((96, 24), (0.55, 0.35, 0.15, 1.0), "rect"),
    "assets/obstacles/apple_glow.png": ((24, 24), (0.2, 0.85, 0.3, 1.0), "circle"),
    "assets/obstacles/particle_dot.png": ((8, 8), (1.0, 0.95, 0.6, 1.0), "circle"),
}


def draw_shape(draw: ImageDraw.ImageDraw, shape: str, size: tuple[int, int], rgba: tuple) -> None:
    w, h = size
    color = tuple(int(c * 255) for c in rgba[:3]) + (255,)
    if shape == "rect":
        draw.rounded_rectangle((2, 4, w - 2, h - 4), radius=4, fill=color)
    elif shape == "circle":
        draw.ellipse((2, 2, w - 2, h - 2), fill=color)
    elif shape == "spike":
        draw.polygon([(w // 2, 0), (w - 2, h - 2), (2, h - 2)], fill=color)
    elif shape == "eye":
        draw.ellipse((4, 8, w - 4, h - 6), fill=color)
        draw.ellipse((w // 2 - 4, h // 2 - 2, w // 2 + 4, h // 2 + 6), fill=(255, 220, 80, 255))


def main() -> None:
    for rel, (size, rgba, shape) in SPECS.items():
        path = ROOT / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        img = Image.new("RGBA", size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        draw_shape(draw, shape, size, rgba)
        img.save(path)
        print(f"Wrote {path}")


if __name__ == "__main__":
    main()
