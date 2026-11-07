#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import pathlib
p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/make-inject-v2.py')
t = p.read_text()
old = 'if (exec_inject_target(imgp)) {'
new = ('/* declared below, next to the rest of the injection code */\n'
       '\tstatic bool exec_inject_target(struct image_params *imgp);\n\n'
       '\tif (exec_inject_target(imgp)) {')
if 'static bool exec_inject_target(struct image_params *imgp);' in t:
    print('already declared')
else:
    assert old in t, 'anchor missing'
    t = t.replace(old, new, 1)
    p.write_text(t)
    print('prototype added')
PY
