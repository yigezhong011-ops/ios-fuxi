#!/bin/bash
# Override the kits builder so it seeds the firmware cache from the device
# repository instead of downloading (the runner's IP is rate limited).
set -euo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV"
git fetch -q origin old
git reset -q --hard origin/old

cp /root/ux3/fuxi/tree/scripts/build-adreno740-kits.py scripts/build-adreno740-kits.py

python3 - <<'PY'
from pathlib import Path
p = Path('scripts/build-adreno740-kits.py')
t = p.read_text()
seed = '''
# Seed the firmware cache from the device repository: the runner's shared IP hits
# GitHub's rate limit, and the blobs are pinned and shipped with the port.
import os as _os
import shutil as _shutil
from pathlib import Path as _Path
_device = _os.environ.get('UNIXNU_DEVICE')
_candidates = []
if _device:
    _candidates.append(_Path(_device) / 'build/firmware/fuxi-gpu')
_candidates.append(ROOT / '../../../../device/build/firmware/fuxi-gpu')
for _source in _candidates:
    if _source.is_dir():
        for _file in _source.rglob('*'):
            if _file.is_file():
                _target = local / _file.relative_to(_source)
                _target.parent.mkdir(parents=True, exist_ok=True)
                _shutil.copy2(_file, _target)
        print('seeded fuxi firmware cache from %s' % _source)
        break
'''
anchor = "ensure_fuxi_firmware(ROOT, local, fuxi_firmware['files'])"
if 'seeded fuxi firmware cache' in t:
    print('已经加过')
else:
    if anchor not in t:
        raise SystemExit('找不到 ensure_fuxi_firmware 调用')
    t = t.replace(anchor, seed + '\n' + anchor, 1)
    p.write_text(t)
    print('已插入固件缓存播种')
PY

git add -f scripts/build-adreno740-kits.py
git -c user.name=dsh -c user.email=dsh@local commit -q -m "scripts: seed the fuxi firmware cache from the device repository"
git push origin old
echo "已推送"
