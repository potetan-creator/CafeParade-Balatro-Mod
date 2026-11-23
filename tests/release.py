"""Check the actual distribution boundary, reproducibility and standalone Lua loading."""
import hashlib
import json
from pathlib import Path
import runpy
import shutil
import tempfile
from zipfile import ZipFile

from lupa.lua51 import LuaRuntime
from PIL import Image

PROJECT = Path(__file__).resolve().parents[1]
builder = runpy.run_path(str(PROJECT / 'tools/build_release.py'))
build_release = builder['build_release']
optional = {f'Cafetro/{name}' for name in builder['OPTIONAL_FILES']
            if (PROJECT / 'Cafetro' / name).is_file()}

with tempfile.TemporaryDirectory(prefix='cafetro-release-') as directory:
    temp = Path(directory)
    archive = build_release(temp / 'first')
    second = build_release(temp / 'second')
    assert archive.read_bytes() == second.read_bytes(), 'same source produces the same ZIP'
    checksum = archive.with_suffix('.sha256').read_text(encoding='utf-8').split()[0]
    assert checksum == hashlib.sha256(archive.read_bytes()).hexdigest()
    with ZipFile(archive) as package:
        assert package.testzip() is None
        paths = package.namelist()
        assert len(paths) == len(set(paths)) == 35 + len(optional)
        assert all(path.startswith('Cafetro/') and '..' not in Path(path).parts for path in paths)
        assert not any(part in {'art', 'docs', 'tests', 'tools', 'previews', '__pycache__'}
                       for path in paths for part in Path(path).parts)
        assert 'Cafetro/challenges/practice.lua' not in paths
        assert 'Cafetro/README.txt' in paths
        assert 'Cafetro/SAKI_CARDS_NOTICE.txt' not in paths
        assert {path for path in paths if Path(path).name.lower().startswith('readme')} == {
            'Cafetro/README.txt',
            *(path for path in optional if Path(path).name.lower().startswith('readme'))}
        for info in package.infolist():
            assert info.date_time == (1980, 1, 1, 0, 0, 0)
            assert info.external_attr >> 16 == 0o100644
            assert package.read(info) == (PROJECT / info.filename).read_bytes()
        package.extractall(temp / 'installed')

    installed = temp / 'installed/Cafetro'
    metadata = json.loads((installed / 'Cafetro.json').read_text(encoding='utf-8'))
    assert metadata['name'] == 'Cafetro!' and metadata['id'] == 'CafeParade' and metadata['prefix'] == 'cp'
    # Load only files extracted from the archive, with no development source tree.
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().ROOT = str(installed)
    lua.execute('''
        registered = {jokers={}, challenges={}, atlases={}, skins={}}
        Blind = {debuff_card=function() end}
        SMODS = {
            current_mod={},
            load_file=function(path) return loadfile(ROOT .. '/' .. path) end,
            Atlas=function(def) registered.atlases[def.key]=def end,
            Joker=function(def) registered.jokers[def.key]=def end,
            Challenge=function(def) registered.challenges[def.key]=def end,
            DeckSkin=function(def) registered.skins[def.key]=def end,
        }
        dofile(ROOT .. '/main.lua')
        assert(registered.challenges.practice == nil)
        assert(registered.challenges.finale:unlocked() == false)
    ''')
    definitions = lua.globals().registered
    assert len(list(definitions.jokers.items())) == 13
    assert len(list(definitions.challenges.items())) == 6
    assert len(list(definitions.skins.items())) == 4
    for _, atlas in definitions.atlases.items():
        for scale in (1, 2):
            with Image.open(installed / f'assets/{scale}x' / atlas.path) as image:
                assert image.width >= atlas.px * scale and image.height >= atlas.py * scale

    # A stray development file must never leak into the installable package.
    project = temp / 'source'
    shutil.copytree(PROJECT / 'Cafetro', project / 'Cafetro')
    (project / 'art').mkdir()
    shutil.copyfile(PROJECT / 'art/COLOR_PALETTE.json', project / 'art/COLOR_PALETTE.json')
    (project / 'Cafetro/tests').mkdir()
    (project / 'Cafetro/tests/debug.lua').write_text('error("not for release")', encoding='utf-8')
    (project / 'Cafetro/.DS_Store').write_bytes(b'not for release')
    clean = build_release(temp / 'filtered', project)
    assert clean.read_bytes() == archive.read_bytes(), 'unlisted files are excluded'
    # An additional author-supplied Markdown README can also be included.
    readme = project / 'Cafetro/README.md'
    readme.write_text('Author-supplied README', encoding='utf-8')
    documented = build_release(temp / 'documented', project)
    with ZipFile(documented) as package:
        assert package.read('Cafetro/README.md') == readme.read_bytes()
    # Incomplete source must fail before overwriting an existing good ZIP.
    (project / 'Cafetro/main.lua').unlink()
    previous = clean.read_bytes()
    try:
        build_release(temp / 'filtered', project)
    except FileNotFoundError:
        pass
    else:
        raise AssertionError('missing runtime module must fail the build')
    assert clean.read_bytes() == previous

print('Release ZIP: runtime-only files, integrity, reproducibility, standalone Lua registration, author README replacement and missing-file checks passed')
