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
cake_lua = LuaRuntime(unpack_returned_tuples=True)
cake_lua.globals().ROOT = str(root)
cake_lua.execute((root / 'tests' / 'cake_set.lua').read_text())
chocolate_lua = LuaRuntime(unpack_returned_tuples=True)
chocolate_lua.globals().ROOT = str(root)
chocolate_lua.execute((root / 'tests' / 'chocolate_spacial.lua').read_text())
challenge_lua = LuaRuntime(unpack_returned_tuples=True)
challenge_lua.globals().ROOT = str(root)
challenge_lua.execute((root / 'tests' / 'challenges.lua').read_text())

import json
import shutil
import subprocess
import sys
import tempfile
from PIL import Image
metadata = json.loads((root / 'CafeParade.json').read_text())
assert metadata['id'] == 'CafeParade' and (root / metadata['main_file']).is_file()
palette = json.loads((root / 'COLOR_PALETTE.json').read_text())
assert len(palette['jokers']) == 10
columns = palette['atlas_columns']
assert columns == 5
for index, spec in enumerate(palette['jokers']):
    assert spec['atlas_pos'] == {'x': index % columns, 'y': index // columns}
    assert (root / 'jokers' / (spec['id'] + '.lua')).is_file()
with tempfile.TemporaryDirectory(prefix='cafeparade-assets-') as directory:
    target = Path(directory) / 'CafeParade'
    shutil.copytree(root, target)
    for mode in ('nearest', 'lanczos'):
        subprocess.run([sys.executable, 'tools/build_atlas.py', '--filter', mode], cwd=target, check=True)
        for scale in (1, 2):
            with Image.open(target / f'assets/{scale}x/cafeparade_jokers.png') as atlas:
                rows = (len(palette['jokers']) + columns - 1) // columns
                assert atlas.size == (71 * columns * scale, 95 * rows * scale) and atlas.mode == 'RGBA'
                for index, spec in enumerate(palette['jokers']):
                    with Image.open(target / 'art/source' / (spec['id'] + '.png')) as source:
                        expected = source.convert('RGBA').resize((71 * scale, 95 * scale),
                            Image.Resampling.NEAREST if mode == 'nearest' else Image.Resampling.LANCZOS)
                    x, y = spec['atlas_pos']['x'] * 71 * scale, spec['atlas_pos']['y'] * 95 * scale
                    assert atlas.crop((x, y, x + 71 * scale, y + 95 * scale)).tobytes() == expected.tobytes()
            with Image.open(target / f'assets/{scale}x/cafeparade_satan_top.png') as top:
                assert top.size == (71 * scale, 95 * scale) and top.mode == 'RGBA'
                assert top.getchannel('A').getextrema() == (0, 255)
                with Image.open(target / 'art/source/satan_top.png') as source:
                    expected = source.convert('RGBA').resize(top.size,
                        Image.Resampling.NEAREST if mode == 'nearest' else Image.Resampling.LANCZOS)
                assert top.tobytes() == expected.tobytes(), 'foreground must retain the full-card canvas and alpha'
        with Image.open(target / 'assets/2x/cafeparade_jokers.png') as atlas:
            expected = atlas.convert('RGBA')
        satan = next(spec for spec in palette['jokers'] if spec['id'] == 'satan')['atlas_pos']
        with Image.open(target / 'assets/2x/cafeparade_satan_top.png') as top:
            expected.alpha_composite(top, (satan['x'] * 142, satan['y'] * 190))
        with Image.open(target / 'previews/cafeparade_card_preview.png') as preview:
            assert preview.size == (710, 380) and preview.tobytes() == expected.tobytes()
    uploaded = root.parent / '315_joker.png'
    if uploaded.is_file():
        assert uploaded.read_bytes() == (root / 'art/source/three_one_five.png').read_bytes()
    for scale in (1, 2):
        with Image.open(target / f'assets/{scale}x/cafeparade_icon.png') as icon:
            assert icon.size == (34 * scale, 34 * scale)
print('Metadata, ten atlas positions in a five-column grid, composite preview, separate Satan foreground, both resamplers, 1x/2x pixels and icons: passed')

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
