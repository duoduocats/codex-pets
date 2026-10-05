#!/usr/bin/env python3
"""Synthetic staged install, rollback and tamper rejection from a real DMG."""
import hashlib, os, shutil, subprocess, sys, tempfile
from pathlib import Path
from ds_store import DSStore

dmg=Path(sys.argv[1]).resolve()
with tempfile.TemporaryDirectory(prefix='codex-pets-dmg-check-',dir='/private/tmp') as work:
 root=Path(work);mount=root/'mount';mount.mkdir()
 subprocess.run(['hdiutil','attach',str(dmg),'-readonly','-mountpoint',str(mount),'-nobrowse','-noautoopen','-quiet'],check=True)
 try:
  allowed={'Codex Pets.app','Applications','安装指南 Installation Guide.pdf','.background','.DS_Store','.fseventsd','.Trashes','.HFS+ Private Directory Data\r'}
  assert set(p.name for p in mount.iterdir())<=allowed
  assert os.readlink(mount/'Applications')=='/Applications'
  with DSStore.open(str(mount/'.DS_Store'),'r') as store:
   assert store['Codex Pets.app']['Iloc']==(204,220)
   assert store['Applications']['Iloc']==(516,220)
  app=mount/'Codex Pets.app'
  subprocess.run([sys.executable,str(Path(__file__).with_name('check-package.py')),str(app)],check=True)
  stage=root/'stage';subprocess.run(['ditto',str(app),str(stage/'Codex Pets.app')],check=True)
  staged=stage/'Codex Pets.app';subprocess.run(['codesign','--verify','--deep','--strict',str(staged)],check=True)
  target=root/'Applications'/'Codex Pets.app';target.mkdir(parents=True)
  (target/'synthetic-previous.txt').write_text('Synthetic previous installation')
  previous=root/'Previous.app';target.rename(previous);staged.rename(target)
  binary=target/'Contents/MacOS/CodexPets'
  assert hashlib.sha256(binary.read_bytes()).digest()==hashlib.sha256((app/'Contents/MacOS/CodexPets').read_bytes()).digest()
  target.rename(root/'Failed-new.app');previous.rename(target)
  assert (target/'synthetic-previous.txt').read_text()=='Synthetic previous installation'
  tampered=root/'Tampered.app';subprocess.run(['ditto',str(app),str(tampered)],check=True)
  with (tampered/'Contents/Resources/PetMark.png').open('ab') as f:f.write(b'Synthetic tamper')
  rejected=subprocess.run(['codesign','--verify','--deep','--strict',str(tampered)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  assert rejected.returncode!=0, 'Tampered shipping files must be rejected'
 finally:
  subprocess.run(['hdiutil','detach',str(mount),'-quiet'],check=True)
print('Real DMG, staged install, rollback and tamper rejection passed')
