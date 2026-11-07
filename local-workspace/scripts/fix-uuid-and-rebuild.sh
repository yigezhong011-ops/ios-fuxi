#!/bin/bash
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl/rebuild-metal-boots.sh
python3 - <<'PY'
import pathlib
p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/rebuild-metal-boots.sh')
t = p.read_text()
old = 'UUID=FUXI0000-0000-4000-8000-0000B007B007'
new = 'UUID=f0c10000-0000-4000-8000-0000b007b007'
if new in t:
    print('already the hex uuid')
else:
    assert old in t, 'uuid line missing'
    p.write_text(t.replace(old, new, 1))
    print('uuid fixed to hex-only')
PY
bash "$S" 2>&1 | tail -12
