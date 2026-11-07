#!/bin/bash
# Read-only: which image wrote the log window? Fast-log and 120 Hz images print FUXI120 and write several rounds a second.
D=$(ls -dt /root/fuxi/hang/hanglog-hang/*/ | head -1); S=$(ls -dt /root/fuxi/hang/swipe-120/*/ | head -1)
export MTOOLS_SKIP_CHECK=1
for n in t50-auto-hanglog t50-mine-gpu-fix; do
  cat > /tmp/gv.py <<'PY'
import struct, sys, zlib
d = open(sys.argv[1], 'rb').read(); ks = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + ks])
fat = next(m for m in range(0, 8 << 20, 2) if b[m+0x52:m+0x5a].startswith(b'FAT32') and b[m+0x1fe:m+0x200] == b'\x55\xaa')
open(sys.argv[2], 'wb').write(b[fat:fat + struct.unpack_from('<I', b, fat + 32)[0] * 512])
PY
  python3 -I /tmp/gv.py /mnt/e/DSH-Fuxi/$n.img /tmp/$n.vol
  echo "== $n"; mtype -i /tmp/$n.vol ::/EFI/UniXNU/unixnu.toml | grep -a -m1 '^args' | tr ' ' '\n' | grep -E 'autoreset|sheng-vsync|qcom-usb|boot-ui' | tr '\n' ' '; echo
  rm -f /tmp/$n.vol
done
for x in "$D" "$S"; do
  echo "== log $x"; grep -E 'boot_id|uptime_s|rounds' $x/header.txt | tr '\n' ' '; echo
  echo "FUXI120 in msgbuf: $(grep -a -c FUXI120 $x/msgbuf.txt)   in slots: $(grep -a -c FUXI120 $x/slots.txt)"
  grep -a -E '^\[clocks\]' $x/latest.txt | cut -c1-120
  grep -a -E '^#slot' $x/slots.txt | head -4 | tr '\n' ' '; echo
  grep -a -E '^prepare calls' $x/latest.txt | cut -c1-140
done
echo "== coherence (hang log)"; grep -a -E '^\[coherence\]' $D/latest.txt | cut -c1-150
echo "== first rows of slot 0..7"; awk '/^#slot [0-7] /{p=1; print; next} /^#slot/{p=0} p&&/^X[56] /{print}' $D/slots.txt | cut -c1-90
