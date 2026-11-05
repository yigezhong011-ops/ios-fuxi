#!/bin/bash
# A copy of the t50-auto-120clock-p volume with one more boot argument. Temp boot only.
# Usage: make-t50-addarg.sh <source work dir> <argument> <out name>
set -euo pipefail
SRC=$1; ARG=$2; OUT=$3
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/auto-$OUT
export MTOOLS_SKIP_CHECK=1
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp "$SRC/vol.img" vol.img
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml > toml.orig
python3 -I - toml.orig toml "$ARG" <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
print('before', len(m.group(1)), 'args', len(args))
print('vsync args:', [a for a in args if 'vsync' in a])
print('title:', re.search(r'title = "([^"]*)"', t).group(1))
print('tail padding bytes', len(old) - len(old.rstrip(b'\n ')))
args.insert(2, sys.argv[3])
line = ' '.join(args)
new = (t[:m.start()] + 'args = "' + line + '"' + t[m.end():]).encode()
print('after', len(line), 'file growth', len(new) - len(old))
assert len(new.rstrip(b'\n ')) < len(old), 'no room in file'
assert len(line) < 1020, len(line)
body = new.rstrip(b'\n ')
open(sys.argv[2], 'wb').write(body + b'\n' + b' ' * (len(old) - len(body) - 1))
PY
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/unixnu.toml toml >/dev/null
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | cmp - toml
python3 -I $S/repack-with-vol.py $E/t50-mine.img vol.img $E/$OUT.img >/dev/null
python3 -I $S/compare-loaders.py $E/$OUT.img | tail -1
sha256sum $E/$OUT.img | cut -c1-16