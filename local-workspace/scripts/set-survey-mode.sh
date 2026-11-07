#!/bin/bash
set -euo pipefail
F=/mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh
python3 - "$F" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
m = re.search(r'^CMDLINE="([^"]*)"', t, re.M)
assert m
cmd = m.group(1)
cmd = re.sub(r'\bfuxibbgpu=\d', 'fuxibbgpu=2', cmd)
p.write_text(t[:m.start(1)] + cmd + t[m.end(1):])
print('survey mode:', 'fuxibbgpu=2' in cmd)
PY
