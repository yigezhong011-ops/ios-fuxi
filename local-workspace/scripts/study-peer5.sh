#!/bin/bash
# Read-only on the images: pull each payload FAT volume out and compare its files.
set -uo pipefail
export MTOOLS_SKIP_CHECK=1
cat > /tmp/getvol.py <<'PY'
import struct, sys
b = open(sys.argv[1], 'rb').read()
fat = next(m for m in range(0, 8 << 20, 2) if b[m+0x52:m+0x5a].startswith(b'FAT32') and b[m+0x1fe:m+0x200] == b'\x55\xaa')
total = struct.unpack_from('<I', b, fat + 32)[0]
open(sys.argv[2], 'wb').write(b[fat:fat + total * 512])
print(sys.argv[1], 'fat at', hex(fat), 'bytes', hex(total * 512))
PY
for n in peer1 peer-ours; do
  python3 -I /tmp/getvol.py /root/fuxi/$n/m0.bin /root/fuxi/$n/vol.img
  rm -rf /root/fuxi/$n/files; mkdir -p /root/fuxi/$n/files
  mcopy -s -n -i /root/fuxi/$n/vol.img ::/ /root/fuxi/$n/files/ 2>/dev/null
  (cd /root/fuxi/$n/files && find . -type f -printf '%s ' -exec sha256sum {} \; | awk '{print $3, $1, substr($2,1,16)}' | sort) > /tmp/$n.lst
  echo "== $n"; cat /tmp/$n.lst
done
echo "== differing"; diff /tmp/peer1.lst /tmp/peer-ours.lst
echo "== kernel strings (peer m0)"
for k in sheng-backlight fuxi-backlight sheng-setup sheng-data-reset PE_halt_restart control_hook_owned reboot_hook; do printf '%s ' $k; grep -a -c "$k" /root/fuxi/peer1/m0.bin; done
echo "== toml peer"; cat /root/fuxi/peer1/files/EFI/UniXNU/unixnu.toml | cut -c1-200 | head -30
