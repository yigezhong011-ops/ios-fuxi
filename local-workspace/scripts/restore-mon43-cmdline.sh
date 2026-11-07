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
# back to the exact command line that reached the lock screen (mon43)
cmd = re.sub(r'\s*fuxicores=\S+', ' ', cmd)
for arg in ('sweetfb_hz=30', '-enable_kprintf_spam', 'fuxi_unixnu_diff=1'):
    if arg not in cmd:
        cmd = cmd.rstrip() + ' ' + arg + ' '
cmd = re.sub(r'\s+', ' ', cmd).strip()
p.write_text(t[:m.start(1)] + cmd + ' ' + t[m.end(1):])
print(cmd)
PY
