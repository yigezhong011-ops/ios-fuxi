#!/bin/bash
set -uo pipefail
D=/root/fuxi/dtbcmp
mkdir -p "$D"
echo "=== 从当前 boot.img 取设备树 ==="
python3 - <<'PY'
import struct, zlib
from pathlib import Path
d = Path('/mnt/e/DSH-Fuxi/unixnu-final.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
un.decompress(d[start:start + ksize])
Path('/root/fuxi/dtbcmp/final.dtb').write_bytes(un.unused_data)
print('dtb %d 字节' % len(un.unused_data))
PY
dtc -I dtb -O dts -o "$D/final.dts" "$D/final.dtb" 2>/dev/null
echo "=== chosen 里的帧缓冲 ==="
awk '/chosen \{/,/};/' "$D/final.dts" | grep -i 'framebuffer\|fb\|stride\|row\|1080\|1000\|height\|width' | head -16 | cut -c1-170
