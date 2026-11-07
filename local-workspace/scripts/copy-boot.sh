#!/bin/bash
set -uo pipefail
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
cp "$OUT/boot/boot.img" /mnt/e/DSH-Fuxi/unixnu-boot.img
ls -lh /mnt/e/DSH-Fuxi/unixnu-boot.img
python3 - "$OUT/boot/boot.img" <<'PY'
import struct, pathlib, sys
d = pathlib.Path(sys.argv[1]).read_bytes()
print("magic:", d[:8])
print("size:", len(d))
print("v0-view header_version:", struct.unpack_from("<I", d, 40)[0])
# 找 payload 是否在镜像里（payload 开头是 FAT 引导区，含 'FAT' 标记）
print("has FAT marker (payload):", b'FAT' in d[:6_000_000] or d.find(b'FAT', 0, 8_000_000) != -1)
PY
