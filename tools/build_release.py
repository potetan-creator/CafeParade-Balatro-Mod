#!/usr/bin/env python3
"""Build a reproducible, installable Cafetro release ZIP using the standard library."""
import argparse
import hashlib
import json
from pathlib import Path
import re
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]
RUNTIME_FILES = (
    'Cafetro.json', 'main.lua', 'config.lua', 'common.lua', 'badges.lua',
    'cake_set.lua', 'deck_skins.lua', 'README.txt',
    'challenges/member_challenges.lua',
    'localization/ja.lua', 'localization/en-us.lua',
)
ASSETS = ('cafeparade_jokers', 'cafeparade_satan_top', 'cafeparade_icon',
          'saki_cards_lc', 'saki_cards_hc')
OPTIONAL_FILES = ('README.md', 'ReadMe.txt', 'LICENSE', 'LICENSE.txt')


def build_release(output_dir=None, project_root=ROOT):
    project_root = Path(project_root)
    mod = project_root / 'Cafetro'
    metadata = json.loads((mod / 'Cafetro.json').read_text(encoding='utf-8'))
    if metadata['name'] != 'Cafetro!' or metadata['id'] != 'CafeParade' or metadata['prefix'] != 'cp':
        raise ValueError('Unexpected display name or incompatible internal mod ID/prefix')
    version = metadata['version']
    if not re.fullmatch(r'\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?', version):
        raise ValueError(f'Invalid release version: {version!r}')

    palette = json.loads((project_root / 'art/COLOR_PALETTE.json').read_text(encoding='utf-8'))
    required = set(RUNTIME_FILES)
    for spec in palette['jokers']:
        identifier = spec['id']
        if not re.fullmatch(r'[a-z][a-z0-9_]*', identifier):
            raise ValueError(f'Invalid Joker identifier: {identifier!r}')
        required.add(f'jokers/{identifier}.lua')
    required.update(f'assets/{scale}x/{name}.png' for scale in (1, 2) for name in ASSETS)
    if metadata['main_file'] not in required:
        raise ValueError('main_file is not included in the runtime file list')
    # Validate everything before opening the ZIP, so a missing file cannot replace a good build.
    for relative in sorted(required):
        path = mod / relative
        if not path.is_file():
            raise FileNotFoundError(path)
        if path.is_symlink():
            raise ValueError(f'Symlinks are not supported: {relative}')
    included = required | {name for name in OPTIONAL_FILES if (mod / name).is_file()}
    for relative in included:
        if (mod / relative).is_symlink():
            raise ValueError(f'Symlinks are not supported: {relative}')

    destination = Path(output_dir) if output_dir is not None else project_root / 'dist'
    destination.mkdir(parents=True, exist_ok=True)
    archive = destination / f'Cafetro-v{version}.zip'
    with ZipFile(archive, 'w', compression=ZIP_DEFLATED, compresslevel=9) as output:
        for relative in sorted(included):
            info = ZipInfo(f'Cafetro/{relative}', date_time=(1980, 1, 1, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            output.writestr(info, (mod / relative).read_bytes(),
                            compress_type=ZIP_DEFLATED, compresslevel=9)
    checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix('.sha256').write_text(f'{checksum}  {archive.name}\n', encoding='utf-8')
    return archive


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, help='Output directory (default: dist/)')
    args = parser.parse_args()
    archive = build_release(args.output_dir)
    print(f'Built {archive} ({archive.stat().st_size:,} bytes)')
    print(f'SHA256: {archive.with_suffix(".sha256").read_text(encoding="utf-8").strip()}')
