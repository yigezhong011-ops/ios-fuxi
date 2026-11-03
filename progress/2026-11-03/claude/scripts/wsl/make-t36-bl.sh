#!/bin/bash
# t36-bl: the daily t36-setup0 (iPhone 14 Pro layout, the author's buttons) plus our DSI brightness: the BACKLIGHT part of
# fuxi-buttons-blob.c in t36's kernel (NO_SINK: native_buttons_set_sink stays the author's) and sheng-backlight=1.
# Kernel and toml are rewritten in place at their own sizes; the image keeps t36's loader and DTB.
set -euo pipefail
OUT=${1:-t36-bl}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36s-0/vol.img $W/vol.img
BLOB_DEFS="-DBACKLIGHT" NO_SINK=1 python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t36/kernel.macho $W/kernel.macho
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
assert not any(a.startswith('sheng-backlight') for a in args), 'already has sheng-backlight'
args.append('sheng-backlight=1')
build = lambda a: (t[:m.start()] + 'args = "' + ' '.join(a) + '"' + t[m.end():]).encode()
new = build(args)
for spare in ('qcom-usb-debug=1', 'serial=3', 'debug=0x14e'):   # diagnostic-only, dropped only if the toml needs the room
    if len(new) > len(old) and spare in args:
        args.remove(spare); new = build(args); print('dropped', spare)
assert len(new) <= len(old), len(new) - len(old)
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)
open(sys.argv[2], 'wb').write(new)
print('args tail:', ' '.join(args[-5:]))
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho $W/kernel.macho
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-phone-cache-miss.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/diff-bootimg-vs-vol.py /root/fuxi/t36/vol.img /mnt/e/DSH-Fuxi/$OUT.img | grep changed
