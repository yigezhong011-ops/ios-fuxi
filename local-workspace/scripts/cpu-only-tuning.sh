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
# CPU-only composition: no backboardd GPU admission, recommend the faster cores
cmd = re.sub(r'\s*fuxibbgpu=\S+', ' ', cmd)
if 'fuxicores=' not in cmd:
    cmd = cmd.rstrip() + ' fuxicores=0x3c '
p.write_text(t[:m.start(1)] + re.sub(r'\s+', ' ', cmd).strip() + ' ' + t[m.end(1):])
print(re.sub(r'\s+', ' ', cmd).strip()[-160:])
PY
