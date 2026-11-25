#!/usr/bin/env python3
"""Rebuild runtime atlases, the mod icon and the development card preview."""
import argparse
import json
from pathlib import Path
import shutil

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / 'Cafetro'
SOURCE = ROOT / 'art/source'


def frame(name, size, resampling):
    with Image.open(SOURCE / f'{name}.png') as image:
        return image.convert('RGBA').resize(size, resampling)


def save(image, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)
    print(f'Built {path.relative_to(ROOT)}: {image.width} x {image.height}')


def build(mode):
    layout = json.loads((ROOT / 'art/COLOR_PALETTE.json').read_text(encoding='utf-8'))
    names = [spec['id'] for spec in layout['jokers']]
    columns = layout['atlas_columns']
    rows = (len(names) + columns - 1) // columns
    resampling = Image.Resampling.NEAREST if mode == 'nearest' else Image.Resampling.LANCZOS

    for scale in (1, 2):
        width, height = 71 * scale, 95 * scale
        assets = MOD / f'assets/{scale}x'
        atlas = Image.new('RGBA', (width * min(columns, len(names)), height * rows))
        for index, name in enumerate(names):
            atlas.paste(frame(name, (width, height), resampling),
                        (width * (index % columns), height * (index // columns)))
        save(atlas, assets / 'cafeparade_jokers.png')

        # Preserve the full-card canvas so the native soul layer stays aligned.
        top = frame('satan_top', (width, height), resampling)
        save(top, assets / 'cafeparade_satan_top.png')
        amehiko_front = frame('amehiko_front', (width, height), resampling)
        save(amehiko_front, assets / 'cafeparade_amehiko_front.png')
        save(frame('chun_chun', (width, height), resampling), assets / 'cafeparade_chun_chun.png')
        icon = frame('icon', (34 * scale, 34 * scale), resampling)
        save(icon, assets / 'cafeparade_icon.png')
        with Image.open(SOURCE / 'icon.png') as original:
            if original.size == icon.size and original.mode == 'RGBA':
                shutil.copyfile(SOURCE / 'icon.png', assets / 'cafeparade_icon.png')

        if scale == 2:
            preview = atlas.copy()
            satan = names.index('satan')
            preview.alpha_composite(top, (width * (satan % columns), height * (satan // columns)))
            amehiko = names.index('amehiko')
            preview.alpha_composite(amehiko_front,
                (width * (amehiko % columns), height * (amehiko // columns)))
            save(preview, ROOT / 'docs/images/cafetro_cards.png')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--filter', choices=('nearest', 'lanczos'), default='nearest')
    build(parser.parse_args().filter)
