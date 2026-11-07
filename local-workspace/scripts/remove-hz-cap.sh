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
# The documented FUXI default is 60 Hz; only set sweetfb_hz when we want the old cap.
cmd = re.sub(r'\s*sweetfb_hz=\d+\s*', ' ', cmd)
cmd = re.sub(r'\s+', ' ', cmd).strip()
p.write_text(t[:m.start(1)] + cmd + ' ' + t[m.end(1):])
print('removed sweetfb_hz (default 60 Hz)')
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'sweetfb_hz|fuxicores|cpus=' | head -4
