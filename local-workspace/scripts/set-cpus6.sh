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
before = cmd
cmd = re.sub(r'\bcpus=\d+', 'cpus=6', cmd)
if 'sweetfb_hz=' not in cmd:
    cmd = cmd.rstrip() + ' sweetfb_hz=30 '
p.write_text(t[:m.start(1)] + cmd + t[m.end(1):])
print('before:', before[:120])
print('after :', cmd[:120])
PY
grep '^CMDLINE=' "$F" | head -1 | tr ' ' '\n' | grep -E 'cpus=|sweetfb_hz|fuxibacklight|fuxigpuscanout|sweetfb_noconsole' | head -6
