#!/bin/bash
# t36-bl2: t36-setup0 with both of our proven t32 pieces in t36's kernel: the PMIC button poller (REPLACE_SINK: it takes
# native_buttons_set_sink over from t36's fuxi-buttons, which gave no key events) and the DSI brightness, with
# sheng-backlight=1 added and fuxi-buttons=1 removed (that also leaves room to keep serial/debug in the toml).
set -euo pipefail
OUT=${1:-t36-bl2}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36s-0/vol.img $W/vol.img
BLOB_DEFS="-DBACKLIGHT" REPLACE_SINK=1 python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t36/kernel.macho $W/kernel.macho | tail -3
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
args = [a for a in args if a != 'fuxi-buttons=1'] + ['sheng-backlight=1']
build = lambda a: (t[:m.start()] + 'args = "' + ' '.join(a) + '"' + t[m.end():]).encode()
new = build(args)
for spare in ('qcom-usb-debug=1', 'serial=3', 'debug=0x14e'):
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
