#!/bin/bash
set -euo pipefail
F=/mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh
python3 - "$F" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
m = re.search(r'^CMDLINE="([^"]*)"', t, re.M)
assert m, 'CMDLINE not found'
cmd = m.group(1)
if 'fuxigpuscanout=1' in cmd:
    print('already present')
else:
    cmd = cmd.rstrip() + ' fuxigpuscanout=1 '
    t = t[:m.start(1)] + cmd + t[m.end(1):]
    p.write_text(t)
    print('added fuxigpuscanout=1')
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'fuxigpuscanout|sweetfb_noconsole|fuxigpu=' | head -5
