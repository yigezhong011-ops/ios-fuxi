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
if 'fuxibbgpu=' not in cmd:
    cmd = cmd.rstrip() + ' fuxibbgpu=1 '
p.write_text(t[:m.start(1)] + re.sub(r'\s+', ' ', cmd).strip() + ' ' + t[m.end(1):])
print('cmdline:', re.sub(r'\s+', ' ', cmd).strip()[:200])
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'fuxibbgpu|fuxigpuabi|fuxigpuscanout' | head -4
