#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import pathlib
p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/make-exec-inject-patch.py')
t = p.read_text()
old = 'static char exec_inject_conf[512];'
new = 'static char exec_inject_conf[512] =\n    "/redwood/lib/libredwood-gl.dylib backboardd";'
if new.split('\n')[0] in t:
    print('already set')
else:
    assert old in t
    t = t.replace(old, new, 1)
    p.write_text(t)
    print('default value written')
PY
grep -n 'exec_inject_conf\[512\]' /mnt/e/DSH-Fuxi/dump/wsl/make-exec-inject-patch.py
