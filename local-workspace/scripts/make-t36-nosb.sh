#!/bin/bash
# t36-usb-nosb: the t36-bl2 volume on the UsbMsdDxe firmware, with SpringBoard disabled so
# the 128 KB msgbuf ring keeps the boot messages instead of being flooded by userland.
# room: the title is reduced to "x" and the SpringBoard focus argument is dropped.
set -euo pipefail
OUT=${1:-t36-usb-nosb}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36-bl2/vol.img $W/vol.img
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
t = t.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "x"')
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
for a in ('serial=3', 'debug=0x14e'):
    if a not in args:
        args.insert(0, a)
if 'qcom-usb-debug=1' not in args:
    args.append('qcom-usb-debug=1')
out = []
for a in args:
    if a.startswith('boot-ui-focus4='):
        continue                      # SpringBoard is disabled, the focus trace is useless
    if a.startswith('sheng-disable-jobs=') and 'com.apple.SpringBoard' not in a:
        a = a + ',com.apple.SpringBoard'
    out.append(a)
args = out
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)
open(sys.argv[2], 'wb').write(new)
print('args 字符数', len(' '.join(args)))
print('disable-jobs:', [a for a in args if a.startswith('sheng-disable-jobs')][0][:160])
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-fdmsd.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py /mnt/e/DSH-Fuxi/$OUT.img
