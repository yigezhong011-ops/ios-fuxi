#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/ci/fuxi-winsys
LIB=$(find "$D" -name 'libOSMesa.8.dylib' | head -1)
echo "=== libOSMesa（fuxi winsys 版）==="
echo "大小: $(stat -c%s "$LIB") B"
echo
echo "=== 我们的 winsys 符号是否进了库（NativeAdreno 选择子调用的痕迹）==="
for s in fuxi-nativeadreno NativeAdrenoGpuPublished NativeAdrenoMethodSubmit IOConnectCallStructMethod IOConnectMapMemory64; do
  n=$(strings -a "$LIB" | grep -c "$s" || true)
  printf '%-32s %s\n' "$s" "$n"
done
echo
echo "=== 对比：参考 winsys（RedwoodGPU）应完全不存在 ==="
printf '%-32s %s\n' "RedwoodGPU" "$(strings -a "$LIB" | grep -c 'RedwoodGPU' || true)"
echo
echo "=== 驱动仍在内 ==="
for s in softpipe freedreno; do
  printf '%-12s %s\n' "$s" "$(strings -a "$LIB" | grep -c "$s" || true)"
done
echo
echo "=== install name ==="
python3 - "$LIB" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(1 << 20)
n = struct.unpack('<I', d[16:20])[0]
off = 32
for _ in range(n):
    c, s = struct.unpack('<II', d[off:off + 8])
    if c == 0xd:
        no = struct.unpack('<I', d[off + 8:off + 12])[0]
        e = d.index(b'\0', off + no)
        print('id =', d[off + no:e].decode())
        break
    if s == 0:
        break
    off += s
PY
