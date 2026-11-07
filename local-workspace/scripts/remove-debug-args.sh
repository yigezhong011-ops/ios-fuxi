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
removed = []
for arg in ('-enable_kprintf_spam', 'fuxi_unixnu_diff=1'):
    if arg in cmd:
        cmd = cmd.replace(arg, '')
        removed.append(arg)
cmd = re.sub(r'\s+', ' ', cmd).strip()
p.write_text(t[:m.start(1)] + cmd + ' ' + t[m.end(1):])
print('removed:', removed)
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'kprintf|unixnu_diff|sweetfb_hz|fuxicores' | head -5
