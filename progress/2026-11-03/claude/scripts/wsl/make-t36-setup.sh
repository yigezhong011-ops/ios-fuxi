#!/bin/bash
# t36 variants with sheng-setup=0 / =1 (the kernel switch next to its purplebuddy "Setup done" writer), for the fresh-Data
# black screen (every frame fails NativeLegacyDisplay verify_swap). The toml is edited in place at its own length; the
# image keeps t36's own loader and DTB. Usage: make-t36-setup.sh <value>
set -euo pipefail
V=$1; OUT=t36-setup$V
W=/root/fuxi/t36s-$V; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36/vol.img $W/vol.img
mtype -i $W/vol.img ::/EFI/UniXNU/unixnu.toml > $W/toml.orig
python3 - $W/toml.orig $W/toml "$V" <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t); args = m.group(1).split()
args = [a for a in args if not a.startswith('sheng-setup=')]
args.append('sheng-setup=' + sys.argv[3])
# room for the new argument: drop the diagnostic-only USB debug switch if needed
new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
if len(new) > len(old) and 'qcom-usb-debug=1' in args:
    args.remove('qcom-usb-debug=1')
    new = (t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)
open(sys.argv[2], 'wb').write(new)
print('args tail:', ' '.join(args[-4:]))
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/unixnu.toml $W/toml
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-phone-cache-miss.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/diff-bootimg-payload.py /mnt/e/DSH-Fuxi/t36-phone-cache-miss.img /mnt/e/DSH-Fuxi/$OUT.img | grep -E 'changed|gzip end'
