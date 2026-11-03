#!/bin/bash
# t36-usbdiag: t36-bl2-usb2 (USB-power loader, qcom-usb-debug=1 serial=3) whose kernel also writes FuxiUsbCompat's
# fuxi_usbdbg_phase/result into the cpufreq row every ~0.6 s (USB_DIAG), booted with sheng-cpufreq=0 so nothing overwrites
# that row. The sheng log then shows "USB p.. r.." in each snapshot's [clocks] line.
set -euo pipefail
OUT=${1:-t36-usbdiag}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36-bl2-usb2/vol.img $W/vol.img
export BLOB_DEFS="${BLOB_DEFS:--DBACKLIGHT -DUSB_DIAG}"
REPLACE_SINK=1 python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py /root/fuxi/t36/kernel.macho $W/kernel.macho | tail -2
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
hits = [i for i, a in enumerate(args) if a.startswith('sheng-cpufreq=')]
assert len(hits) == 1, hits
args[hits[0]] = 'sheng-cpufreq=0'
import os
if '-DBACKLIGHT' not in os.environ.get('BLOB_DEFS', '-DBACKLIGHT'):
    # without the DSI patch, the plain sheng-backlight=1 service panics fuxi (it touches the disabled I2C engines)
    args = [a for a in args if a != 'sheng-backlight=1']
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
body = new.rstrip(b'\n ')   # earlier edits left the file padded with trailing spaces after its newline
new = body + b'\n' + b' ' * (len(old) - len(body) - 1)
open(sys.argv[2], 'wb').write(new)
print('args has:', [a for a in args if a.split('=')[0] in ('sheng-cpufreq', 'qcom-usb-debug', 'serial', 'sheng-backlight')])
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho $W/kernel.macho
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-bl2-usb2.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py /mnt/e/DSH-Fuxi/$OUT.img
