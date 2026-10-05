#!/usr/bin/env python3
"""Audit this app only, printing rules and paths rather than file contents."""
import plistlib, subprocess, sys
from pathlib import Path

app=Path(sys.argv[1]).resolve()
expected={
 'Contents/Info.plist','Contents/MacOS/CodexPets',
 'Contents/Resources/Assets.car','Contents/Resources/AppIcon.icns',
 'Contents/Resources/PetMark.png','Contents/Resources/LICENSE.txt',
 'Contents/Resources/THIRD_PARTY_NOTICES.md','Contents/_CodeSignature/CodeResources'
}
actual={str(p.relative_to(app)) for p in app.rglob('*') if p.is_file()}
assert actual==expected, f'Unexpected shipping files: {sorted(actual^expected)}'
assert not any(p.is_symlink() for p in app.rglob('*')), 'Bundle symlinks are not expected'
info=plistlib.loads((app/'Contents/Info.plist').read_bytes())
assert info['CFBundleIdentifier']=='com.duoduocat.codexpetstore'
assert info['CFBundleIconName']=='AppIcon'
assert info['LSMinimumSystemVersion']=='13.0'
assert (app/'Contents/Resources/LICENSE.txt').read_text().startswith('                    GNU GENERAL PUBLIC LICENSE')
assert 'GPL-3.0-only' in (app/'Contents/Resources/THIRD_PARTY_NOTICES.md').read_text()
subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True)
print('Shipping bundle audit passed')
