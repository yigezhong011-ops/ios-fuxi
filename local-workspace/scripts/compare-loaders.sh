#!/bin/bash
set -uo pipefail
echo "=== /root/fuxi/t32 里的东西 ==="
ls -l /root/fuxi/t32/ 2>/dev/null | head -20
echo
echo "=== userboot/body.bin（我们用的 loader）==="
ls -l /root/fuxi/userboot/body.bin 2>/dev/null
echo
echo "=== 各镜像的 loader 前缀比较（前 3145920 字节的 sha256）==="
for f in /mnt/e/DSH-Fuxi/t32-bl-daily.img /mnt/e/DSH-Fuxi/t32-gpu6.img /mnt/e/DSH-Fuxi/t32-wall2.img; do
  [ -f "$f" ] || continue
  printf '%-28s ' "$(basename "$f")"
  python3 - "$f" <<'PY'
import hashlib, struct, sys, zlib
from pathlib import Path
d = Path(sys.argv[1]).read_bytes()
hs = struct.unpack_from('<I', d, 20)[0]
ks = struct.unpack_from('<I', d, 8)[0]
start = (hs + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ks])
fat = next(m for m in range(0, 8 << 20, 2)
           if len(body[m:m+512]) == 512 and body[m+0x52:m+0x5a].startswith(b'FAT32')
           and body[m+0x1fe:m+0x200] == b'\x55\xaa')
print('loader %d 字节 sha256 %s' % (fat, hashlib.sha256(body[:fat]).hexdigest()[:16]))
PY
done
