#!/bin/bash
# A copy of a t50 test volume that returns to fastboot by itself: sheng-autoreset=<seconds> plus qcom-usb-ctl=1. Temp boot only: never flash these
# as the daily image, the phone would restart every few minutes.
# t50-auto150 appended both to a line of about 1020 characters and did not come back; the kernel's boot-args buffer is 1024 bytes, so these go
# first and boot-ui-focus4 (a diagnostic) makes room.
# Usage: make-t50-auto.sh <work dir holding vol.img, or "base"> <seconds> <out name>
set -euo pipefail
SRC=$1; SECS=$2; OUT=$3
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/auto-$OUT
export MTOOLS_SKIP_CHECK=1
[ "$SRC" = base ] && SRC=/root/fuxi/gpu-new-t50-mine
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp "$SRC/vol.img" vol.img
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml > toml.orig
python3 -I - toml.orig toml "$SECS" <<'PY'
import os, re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
t = t.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "fuxi"')
m = re.search(r'args = "([^"]*)"', t)
args = [a for a in m.group(1).split() if not a.startswith(('sheng-autoreset=', 'qcom-usb-ctl=', 'boot-ui-focus4='))]
args = ['sheng-autoreset=' + sys.argv[3], 'qcom-usb-ctl=1'] + os.environ.get('EXTRA_ARGS', '').split() + args
line = ' '.join(args)
new = (t[:m.start()] + 'args = "' + line + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
assert len(line) < 1020, len(line)  # the kernel's buffer is 1024 with the terminator
body = new.rstrip(b'\n ')
open(sys.argv[2], 'wb').write(body + b'\n' + b' ' * (len(old) - len(body) - 1))
print('args chars', len(line), 'start:', ' '.join(args[:3]))
PY
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/unixnu.toml toml >/dev/null
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | cmp - toml
python3 -I $S/repack-with-vol.py $E/t50-mine.img vol.img $E/$OUT.img >/dev/null
python3 -I $S/compare-loaders.py $E/$OUT.img | tail -1
sha256sum $E/$OUT.img | cut -c1-16
