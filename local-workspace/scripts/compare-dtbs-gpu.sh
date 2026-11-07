#!/bin/bash
# Compare the GPU/GMU/SMMU nodes of the device tree inside the GPU16 boot image
# with the one the device repository builds against.
set -uo pipefail
W=/root/fuxi/dtbcmp
mkdir -p "$W"

echo "=== 1) 从 GPU16 boot 取设备树 ==="
python3 - "$W" <<'PY'
import struct, sys, zlib
from pathlib import Path
w = Path(sys.argv[1])
d = Path('/mnt/e/DSH-Fuxi/boot-fuxi-GPU16.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
tree = un.unused_data
(w / 'gpu16.dtb').write_bytes(tree)
print('  GPU16 dtb %d 字节' % len(tree))
PY

echo "=== 2) 反编译两份设备树 ==="
dtc -I dtb -O dts -o "$W/gpu16.dts" "$W/gpu16.dtb" 2>/dev/null
dtc -I dtb -O dts -o "$W/repo.dts" /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Resources/DTBs/fuxi.dtb 2>/dev/null
wc -l "$W/gpu16.dts" "$W/repo.dts"

for f in gpu16 repo; do
  echo
  echo "=== $f 的 GPU 关键节点 ==="
  grep -n 'kgsl-3d0@\|gmu@3d69000\|kgsl-iommu@\|zap-shader\|gpu_micro_code_region' "$W/$f.dts" | head -8
  echo "  --- GMU iommus / 中断 ---"
  awk '/gmu@3d69000/,/};/' "$W/$f.dts" | grep -E 'iommus|interrupts|reg =|compatible' | head -6 | sed 's/^/    /'
  echo "  --- kgsl-3d0 关键属性 ---"
  awk '/kgsl-3d0@3d00000/,/};/' "$W/$f.dts" | grep -E 'reg =|interrupts =|compatible|ubwc' | head -5 | sed 's/^/    /'
done
