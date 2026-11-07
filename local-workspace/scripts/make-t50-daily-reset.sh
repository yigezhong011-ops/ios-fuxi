#!/bin/bash
# The daily image, but returning to fastboot by itself after 90 s. For a test session only: while it sits in boot_b, a hang's fall-back boot comes back unattended
# and writes under 60 low slots, so the fast-log image's slots from 500 survive. Must be replaced by t50-mine-gpu-fix.img afterwards. Built only; flashing needs the user's OK.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh
ls -la /root/fuxi/gpu-new-t50-mine/vol.img
bash /tmp/a.sh base 90 t50-daily-reset | tail -3 | cut -c1-120
export MTOOLS_SKIP_CHECK=1
cat > /tmp/gv.py <<'PY'
import struct, sys, zlib
d = open(sys.argv[1], 'rb').read(); ks = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + ks])
fat = next(m for m in range(0, 8 << 20, 2) if b[m+0x52:m+0x5a].startswith(b'FAT32') and b[m+0x1fe:m+0x200] == b'\x55\xaa')
open(sys.argv[2], 'wb').write(b[fat:fat + struct.unpack_from('<I', b, fat + 32)[0] * 512])
PY
for n in t50-daily-reset t50-mine-gpu-fix; do
  python3 -I /tmp/gv.py /mnt/e/DSH-Fuxi/$n.img /tmp/$n.vol
  mtype -i /tmp/$n.vol ::/EFI/UniXNU/Payloads/kernel.macho | sha256sum | cut -c1-16
  mtype -i /tmp/$n.vol ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | sha256sum | cut -c1-16
  mtype -i /tmp/$n.vol ::/EFI/UniXNU/unixnu.toml | grep -a -m1 '^args' | tr ' ' '\n' | sort > /tmp/$n.args
done
echo "== args only in reset"; comm -23 /tmp/t50-daily-reset.args /tmp/t50-mine-gpu-fix.args | tr '\n' ' '; echo
echo "== args only in daily"; comm -13 /tmp/t50-daily-reset.args /tmp/t50-mine-gpu-fix.args | tr '\n' ' '; echo
rm -f /tmp/t50-daily-reset.vol /tmp/t50-mine-gpu-fix.vol
