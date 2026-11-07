#!/bin/bash
# t36-bl2-usb2: the daily t36-bl2 volume with the USB debug console switched on as on t32 (qcom-usb-debug=1 with serial=3;
# the console backend needs the serial switch) and debug=0x14e back, on the loader of DeepSeek's t32-usb.img (uefi-fuxi +
# UsbPwrEnablerDxe). The room comes from the boot menu title, which nothing reads ("fuxi first boot: ..." -> "fuxi").
set -euo pipefail
OUT=${1:-t36-bl2-usb2}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36-bl2/vol.img $W/vol.img
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
t = t.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "fuxi"')
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
for a in ('serial=3', 'debug=0x14e', 'qcom-usb-debug=1'):
    if a not in args:
        args.insert(0, a) if a != 'qcom-usb-debug=1' else args.append(a)
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)
open(sys.argv[2], 'wb').write(new)
print('args head:', ' '.join(args[:3]), '... tail:', ' '.join(args[-4:]))
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t32-usb.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py /mnt/e/DSH-Fuxi/$OUT.img
