"""Headless Lua 5.1 contract tests; does not emulate Balatro's scoring engine."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().ROOT = str(root)
for path in root.rglob('*.lua'):
    lua.execute('assert(loadfile(...))', str(path))
print('Lua 5.1 syntax: all Lua files passed')
lua.execute((root / 'tests' / 'contracts.lua').read_text())

import json
import shutil
import subprocess
import sys
import tempfile
from PIL import Image
metadata = json.loads((root / 'CafeParade.json').read_text())
assert metadata['id'] == 'CafeParade' and (root / metadata['main_file']).is_file()
palette = json.loads((root / 'COLOR_PALETTE.json').read_text())
assert len(palette['jokers']) == 6
for index, spec in enumerate(palette['jokers']):
    assert spec['atlas_pos'] == {'x': index, 'y': 0}
    assert (root / 'jokers' / (spec['id'] + '.lua')).is_file()
with tempfile.TemporaryDirectory(prefix='cafeparade-assets-') as directory:
    target = Path(directory) / 'CafeParade'
    shutil.copytree(root, target)
    for mode in ('nearest', 'lanczos'):
        subprocess.run([sys.executable, 'tools/build_atlas.py', '--filter', mode], cwd=target, check=True)
        for scale in (1, 2):
            with Image.open(target / f'assets/{scale}x/cafeparade_jokers.png') as atlas:
                assert atlas.size == (426 * scale, 95 * scale) and atlas.mode == 'RGBA'
                for index, spec in enumerate(palette['jokers']):
                    with Image.open(target / 'art/source' / (spec['id'] + '.png')) as source:
                        expected = source.convert('RGBA').resize((71 * scale, 95 * scale),
                            Image.Resampling.NEAREST if mode == 'nearest' else Image.Resampling.LANCZOS)
                    assert atlas.crop((index * 71 * scale, 0, (index + 1) * 71 * scale, 95 * scale)).tobytes() == expected.tobytes()
    for scale in (1, 2):
        with Image.open(target / f'assets/{scale}x/cafeparade_icon.png') as icon:
            assert icon.size == (34 * scale, 34 * scale)
print('Metadata, six atlas positions, both resamplers, 1x/2x frame pixels and icons: passed')

# Separate VM: the registration test deliberately removes G to catch writes to defaults.
skin_lua = LuaRuntime(unpack_returned_tuples=True)
skin_lua.globals().ROOT = str(root)
skin_lua.execute((root / 'tests/deck_skins.lua').read_text())
for scale in (1, 2):
    images = {}
    for palette in ('lc', 'hc'):
        path = root / f'assets/{scale}x/saki_cards_{palette}.png'
        with Image.open(path) as image:
            image.load()
            assert image.size == (923 * scale, 380 * scale)
            assert image.mode == 'RGBA'
            assert image.getchannel('A').getextrema() == (0, 255)
            for row in range(4):
                for column in range(13):
                    cell = image.crop((column * 71 * scale, row * 95 * scale,
                                       (column + 1) * 71 * scale, (row + 1) * 95 * scale))
                    assert cell.size == (71 * scale, 95 * scale)
                    assert cell.getchannel('A').getextrema()[1] == 255
            images[palette] = image.tobytes()
        source = root.parent / 'Saki Mizushima Cards 1.0' / f'assets/{scale}x/MizushimaSakiCards_{palette}.png'
        if source.is_file():
            assert path.read_bytes() == source.read_bytes(), 'original PNG must be preserved byte-for-byte'
    assert images['lc'] != images['hc'], 'normal and high contrast must use their respective source files'
print('Playing cards: two palettes, 1x/2x, alpha, all 52 cells and source integrity passed')
