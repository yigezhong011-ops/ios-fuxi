#!/bin/bash
set -uo pipefail
ADDON=/root/fuxi/t32/kernel.macho.gpuaddon
W=/root/addon-check
rm -rf "$W"; mkdir -p "$W"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/list-gpu-addon.py "$ADDON" --extract "$W" >/dev/null 2>&1 || \
python3 - "$ADDON" "$W" <<'PY'
import struct, sys, zlib
from pathlib import Path
addon, out = Path(sys.argv[1]), Path(sys.argv[2])
d = addon.read_bytes()
count, _, _ = struct.unpack_from('<IIQ', d, 8)
off = 24
for _ in range(count):
    nlen, mode, size, csize = struct.unpack_from('<IIQQ', d, off); off += 24
    name = d[off:off+nlen-1].decode(); off += nlen + (-nlen % 8)
    packed = d[off:off+csize]; off += csize + (-csize % 8)
    p = out / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(zlib.decompress(packed))
    print('extracted', name, len(zlib.decompress(packed)))
PY
echo "=== 插件是否引用 libvulkan_freedreno ==="
for f in "$W/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal" "$W/bin/adrenoprobed"; do
  [ -f "$f" ] || continue
  printf '%-24s ' "$(basename "$f")"
  strings -a "$f" | grep -c 'libvulkan_freedreno\|vulkan' || true
done
echo "=== 具体字符串 ==="
strings -a "$W/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal" 2>/dev/null | grep -i 'vulkan' | sort -u | head -8
