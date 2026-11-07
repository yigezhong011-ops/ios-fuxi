#!/bin/bash
# t50-mine: the author's t50 (kernel with working USB debug and his own DSI brightness) plus our PMIC button poller (his
# fuxi-buttons gave no key events on this phone; REPLACE_SINK, buttons only, no BACKLIGHT since t50 has fuxi-backlight=dsi),
# unit scale back to 3 (t36's: the Dynamic Island shape; 2 showed a notch and the red bar stayed) and sheng-setup=0.
set -euo pipefail
OUT=${1:-t50-mine}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t50/vol.img $W/vol.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/find-caves.py /root/fuxi/t50/kernel.macho | grep -A1 __hib_text | head -2
BLOB_DEFS="" REPLACE_SINK=1 python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t50/kernel.macho $W/kernel.macho | tail -2
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
args = ['offline-legacy-unit-scale=3' if a.startswith('offline-legacy-unit-scale=') else a for a in args]
args = [a for a in args if a != 'fuxi-buttons=1']
if 'sheng-setup=0' not in args:
    args.append('sheng-setup=0')
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
body = new.rstrip(b'\n ')
new = body + b'\n' + b' ' * (len(old) - len(body) - 1)
open(sys.argv[2], 'wb').write(new)
print('args:', [a for a in args if a.split('=')[0] in ('offline-legacy-unit-scale', 'sheng-setup', 'sheng-backlight', 'fuxi-backlight', 'qcom-usb-debug', 'serial', 'fuxi-buttons')])
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho $W/kernel.macho
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t50-subtype2556-nodiag.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
