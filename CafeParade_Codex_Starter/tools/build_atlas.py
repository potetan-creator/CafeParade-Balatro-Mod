#!/usr/bin/env python3
"""Rebuilds the six-frame Joker atlas and Satan's separate floating layer.
Run: python tools/build_atlas.py --filter lanczos
"""
from PIL import Image
from pathlib import Path
import argparse

ROOT = Path(__file__).resolve().parents[1]
NAMES = ["kamiya", "shinonome", "aslan", "makio", "saki", "satan"]

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
        atlas=Image.new("RGBA",(width*len(NAMES),height),(0,0,0,0))
        for i,name in enumerate(NAMES):
            img=frame(name,(width,height),resampling)
            atlas.paste(img,(width*i,0))
        output=ROOT / "assets" / f"{scale}x" / "cafeparade_jokers.png"
        output.parent.mkdir(parents=True,exist_ok=True)
        atlas.save(output)
        print(f"Built {output.relative_to(ROOT)} : {atlas.width} x {atlas.height}")
        # Keep the transparent foreground on its original full-card canvas.
        top = frame("satan_top", (width, height), resampling)
        output = output.with_name("cafeparade_satan_top.png")
        top.save(output)
        print(f"Built {output.relative_to(ROOT)} : {top.width} x {top.height}")

if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument("--filter", choices=["nearest","lanczos"],default="nearest")
    build(parser.parse_args().filter)
