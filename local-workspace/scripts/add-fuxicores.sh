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
if 'fuxicores=' in cmd:
    print('already present')
else:
    cmd = cmd.rstrip() + ' fuxicores=0x3c '
    p.write_text(t[:m.start(1)] + cmd + t[m.end(1):])
    print('added fuxicores=0x3c (logical CPUs 2-5)')
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'fuxicores|cpus=|sweetfb_hz' | head -4
