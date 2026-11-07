#!/bin/bash
# t36-usb-trace5: t36-bl2 volume on the UsbMsdDxe firmware with boot-ui-trace=1, so the
# kernel publishes the "USB ph=<phase> res=<result>" row into the persistent log.
# room: menu titles are shortened, which nothing reads.
set -euo pipefail
OUT=${1:-t36-usb-trace5}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36-bl2/vol.img $W/vol.img
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
t = t.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "x"')
t = t.replace('title = "Restart"', 'title = "R"')
t = t.replace('title = "Power off"', 'title = "P"')
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
for a in ('serial=3', 'debug=0x14e', 'boot-ui-trace=1'):
    if a not in args:
        args.insert(0, a)
if 'qcom-usb-debug=1' not in args:
    args.append('qcom-usb-debug=1')
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)
open(sys.argv[2], 'wb').write(new)
print('args 字符数', len(' '.join(args)))
for k in ('boot-ui-trace', 'qcom-usb-debug', 'serial=', 'debug='):
    print('  ', [a for a in args if k in a])
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-fdmsd.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py /mnt/e/DSH-Fuxi/$OUT.img
