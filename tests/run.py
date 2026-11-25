"""Headless Lua 5.1 contracts and release checks; no Balatro engine emulation."""
import hashlib
import json
from pathlib import Path
import runpy
import shutil
import subprocess
import sys
import tempfile

from lupa.lua51 import LuaRuntime
from PIL import Image

PROJECT = Path(__file__).resolve().parents[1]
ROOT = PROJECT / 'Cafetro'
TESTS = PROJECT / 'tests'


def run_lua(name):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().ROOT = str(ROOT)
    lua.globals().TEST_ROOT = str(TESTS)
    lua.execute((TESTS / name).read_text(encoding='utf-8'))


syntax = LuaRuntime()
for directory in (ROOT, TESTS):
    for path in directory.rglob('*.lua'):
        syntax.execute('assert(loadfile(...))', str(path))
print('Lua 5.1 syntax: all runtime and test files passed')
for name in ('contracts.lua', 'cake_set.lua', 'food.lua', 'goldpeople.lua', 'chocolate_spacial.lua', 'challenges.lua', 'deck_skins.lua'):
    run_lua(name)

metadata = json.loads((ROOT / 'Cafetro.json').read_text(encoding='utf-8'))
assert metadata['name'] == 'Cafetro!'
assert metadata['id'] == 'CafeParade' and metadata['prefix'] == 'cp'
assert (ROOT / metadata['main_file']).is_file()
palette = json.loads((PROJECT / 'art/COLOR_PALETTE.json').read_text(encoding='utf-8'))
assert len(palette['jokers']) == 13
columns = palette['atlas_columns']
assert columns == 5
for index, spec in enumerate(palette['jokers']):
    assert spec['atlas_pos'] == {'x': index % columns, 'y': index // columns}
    assert (ROOT / 'jokers' / (spec['id'] + '.lua')).is_file()
with tempfile.TemporaryDirectory(prefix='cafetro-assets-') as directory:
    project = Path(directory)
    for name in ('Cafetro', 'art', 'tools'):
        shutil.copytree(PROJECT / name, project / name)
    target = project / 'Cafetro'
    for mode in ('nearest', 'lanczos'):
        subprocess.run([sys.executable, 'tools/build_atlas.py', '--filter', mode], cwd=project, check=True)
        resampling = Image.Resampling.NEAREST if mode == 'nearest' else Image.Resampling.LANCZOS
        for scale in (1, 2):
            with Image.open(target / f'assets/{scale}x/cafeparade_jokers.png') as atlas:
                rows = (len(palette['jokers']) + columns - 1) // columns
                assert atlas.size == (71 * columns * scale, 95 * rows * scale) and atlas.mode == 'RGBA'
                for spec in palette['jokers']:
                    with Image.open(project / 'art/source' / (spec['id'] + '.png')) as source:
                        expected = source.convert('RGBA').resize((71 * scale, 95 * scale), resampling)
                    x, y = spec['atlas_pos']['x'] * 71 * scale, spec['atlas_pos']['y'] * 95 * scale
                    assert atlas.crop((x, y, x + 71 * scale, y + 95 * scale)).tobytes() == expected.tobytes()
                for index in range(len(palette['jokers']), columns * rows):
                    x, y = (index % columns) * 71 * scale, (index // columns) * 95 * scale
                    assert atlas.crop((x, y, x + 71 * scale, y + 95 * scale)).getchannel('A').getbbox() is None
            with Image.open(target / f'assets/{scale}x/cafeparade_satan_top.png') as top:
                assert top.size == (71 * scale, 95 * scale) and top.mode == 'RGBA'
                assert top.getchannel('A').getextrema() == (0, 255)
                with Image.open(project / 'art/source/satan_top.png') as source:
                    expected = source.convert('RGBA').resize(top.size, resampling)
                assert top.tobytes() == expected.tobytes(), 'foreground retains full canvas and alpha'
            with Image.open(project / 'art/source/icon.png') as source:
                expected = source.convert('RGBA').resize((34 * scale, 34 * scale), resampling)
            with Image.open(target / f'assets/{scale}x/cafeparade_icon.png') as icon:
                assert icon.size == expected.size and icon.mode == 'RGBA'
                assert icon.tobytes() == expected.tobytes()
                assert icon.getchannel('A').getextrema() == (0, 255)
            if mode == 'nearest':
                for name in ('cafeparade_jokers', 'cafeparade_satan_top', 'cafeparade_icon'):
                    with Image.open(target / f'assets/{scale}x/{name}.png') as rebuilt:
                        with Image.open(ROOT / f'assets/{scale}x/{name}.png') as committed:
                            assert rebuilt.size == committed.size and rebuilt.tobytes() == committed.tobytes()
        with Image.open(target / 'assets/2x/cafeparade_jokers.png') as atlas:
            expected = atlas.convert('RGBA')
        satan = next(spec for spec in palette['jokers'] if spec['id'] == 'satan')['atlas_pos']
        with Image.open(target / 'assets/2x/cafeparade_satan_top.png') as top:
            expected.alpha_composite(top, (satan['x'] * 142, satan['y'] * 190))
        with Image.open(project / 'docs/images/cafetro_cards.png') as preview:
            assert preview.size == (710, 570) and preview.tobytes() == expected.tobytes()
print('Metadata, all atlas cells, icons, alpha, both resamplers and committed runtime images: passed')

hashes = json.loads((TESTS / 'asset_hashes.json').read_text(encoding='utf-8'))
for relative, digest in hashes.items():
    assert hashlib.sha256((PROJECT / relative).read_bytes()).hexdigest() == digest, relative
for scale in (1, 2):
    images = {}
    for palette in ('lc', 'hc'):
        with Image.open(ROOT / f'assets/{scale}x/saki_cards_{palette}.png') as image:
            assert image.size == (923 * scale, 380 * scale) and image.mode == 'RGBA'
            assert image.getchannel('A').getextrema() == (0, 255)
            for row in range(4):
                for column in range(13):
                    cell = image.crop((column * 71 * scale, row * 95 * scale,
                                       (column + 1) * 71 * scale, (row + 1) * 95 * scale))
                    assert cell.getchannel('A').getextrema()[1] == 255
            images[palette] = image.tobytes()
    assert images['lc'] != images['hc']
print('Playing cards: two palettes, 1x/2x, all 52 cells and original image hashes: passed')
runpy.run_path(str(TESTS / 'release.py'), run_name='__main__')
