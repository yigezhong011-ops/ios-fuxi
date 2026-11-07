#!/bin/bash
set -uo pipefail
echo "=== /root/fuxi/unixnu 目录 ==="
ls -l /root/fuxi/unixnu/ 2>/dev/null | head -12
echo
echo "=== uefi.img 前 16 字节 ==="
xxd -l 16 /root/fuxi/unixnu/uefi.img 2>/dev/null
echo
echo "=== 从备份镜像里重新取一次（核对）==="
python3 - <<'PY'
import struct
d = open('/mnt/c/Users/USER/Downloads/BACKUP-ufs-works.img', 'rb').read()
ksize = struct.unpack_from('<I', d, 8)[0]
hsize = struct.unpack_from('<I', d, 20)[0]
hver = struct.unpack_from('<I', d, 40)[0]
page = 4096
start = (hsize + page - 1)//page*page
k = d[start:start+ksize]
print('header v%d kernel_size=%d' % (hver, ksize))
print('前 16 字节:', k[:16].hex())
print('是 FDT 吗:', k[:4] == b'\xd0\x0d\xfe\xed')
import gzip, io
if k[:2] == b'\x1f\x8b':
    raw = gzip.decompress(k)
    print('gzip 解出 %d 字节，前 16: %s' % (len(raw), raw[:16].hex()))
    print('  其中含 FDT:', raw[:4] == b'\xd0\x0d\xfe\xed')
    # 找 shim 与 FD 的边界：FDT 之后可能还有内容；先看总量
    print('  尾部 16:', raw[-16:].hex())
PY
