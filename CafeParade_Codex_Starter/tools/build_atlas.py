#!/usr/bin/env python3
"""Rebuilds the wrapping Joker atlas, Satan's floating layer and grid preview.
Run: python tools/build_atlas.py --filter lanczos
"""
from PIL import Image
from pathlib import Path
import argparse
import json

ROOT = Path(__file__).resolve().parents[1]
LAYOUT = json.loads((ROOT / "COLOR_PALETTE.json").read_text())
NAMES = [spec["id"] for spec in LAYOUT["jokers"]]
COLUMNS = LAYOUT["atlas_columns"]

def frame(name, size, resampling):
    source = ROOT / "art" / "source" / (name + ".png")
    if not source.exists():
        raise FileNotFoundError(f"Missing source art: {source}")
    with Image.open(source) as image:
        return image.convert("RGBA").resize(size, resampling)

def build(mode):
    resampling = Image.Resampling.NEAREST if mode == "nearest" else Image.Resampling.LANCZOS
    for scale in [1, 2]:
        width,height=71*scale,95*scale
        rows = (len(NAMES) + COLUMNS - 1) // COLUMNS
        atlas=Image.new("RGBA",(width*min(COLUMNS,len(NAMES)),height*rows),(0,0,0,0))
        for i,name in enumerate(NAMES):
            img=frame(name,(width,height),resampling)
            atlas.paste(img,(width*(i % COLUMNS),height*(i // COLUMNS)))
        output=ROOT / "assets" / f"{scale}x" / "cafeparade_jokers.png"
        output.parent.mkdir(parents=True,exist_ok=True)
        atlas.save(output)
        print(f"Built {output.relative_to(ROOT)} : {atlas.width} x {atlas.height}")
        # Keep the transparent foreground on its original full-card canvas.
        top = frame("satan_top", (width, height), resampling)
        output = output.with_name("cafeparade_satan_top.png")
        top.save(output)
        print(f"Built {output.relative_to(ROOT)} : {top.width} x {top.height}")
        if scale == 2:
            preview = atlas.copy()
            satan_index = NAMES.index("satan")
            preview.alpha_composite(top, (width * (satan_index % COLUMNS), height * (satan_index // COLUMNS)))
            output = ROOT / "previews" / "cafeparade_card_preview.png"
            output.parent.mkdir(parents=True, exist_ok=True)
            preview.save(output)
            print(f"Built {output.relative_to(ROOT)} : {preview.width} x {preview.height}")

if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument("--filter", choices=["nearest","lanczos"],default="nearest")
    build(parser.parse_args().filter)
