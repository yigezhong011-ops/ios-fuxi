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
if 'fuxibacklight=' in cmd:
    print('already present')
else:
    cmd = cmd.rstrip() + ' fuxibacklight=1 '
    t = t[:m.start(1)] + cmd + t[m.end(1):]
    p.write_text(t)
    print('added fuxibacklight=1')
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'fuxibacklight|fuxigpuscanout|sweetfb_noconsole' | head -5
