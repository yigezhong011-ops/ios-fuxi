#!/bin/bash
# Override the accelerator builder in the device repository and have it repair the
# stale include path in the driver source before compiling.
set -uo pipefail
DEV=/root/fuxi/fork-device
T=/root/ux3/fuxi/tree
cd "$DEV" || exit 1
git checkout -q old && git pull -q origin old

cp "$T/scripts/build-adreno740-accelerator.py" scripts/build-adreno740-accelerator.py

python3 - <<'PY'
from pathlib import Path
p = Path('scripts/build-adreno740-accelerator.py')
t = p.read_text()
inject = '''
# The driver source includes the ABI header from the wrong driver directory; the
# header lives in AdrenoMetal in this tree, so repair the include before compiling.
_abi_source = None
for _candidate in (ROOT / 'drivers/Adreno740/NativeAdrenoAccelerator.cpp',):
    if _candidate.is_file():
        _text = _candidate.read_text()
        if '../NativeMetal/OriginalAcceleratorABI.h' in _text:
            _candidate.write_text(_text.replace('../NativeMetal/OriginalAcceleratorABI.h',
                                                '../AdrenoMetal/OriginalAcceleratorABI.h'))
            print('repaired the accelerator include path')
'''
if 'repaired the accelerator include path' in t:
    print('已经加过')
else:
    lines = t.splitlines()
    for i, line in enumerate(lines):
        if line.startswith('subprocess.run('):
            lines.insert(i, inject)
            break
    p.write_text('\n'.join(lines) + '\n')
    print('已插入 include 修复')
PY

git add -f scripts/build-adreno740-accelerator.py
git -c user.name=dsh -c user.email=dsh@local commit -qm "scripts: repair the accelerator include path before compiling"
git push -q origin old && echo "已推送"
