#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
CLANG=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi/toolchain/clang
FD_BASE=0xa7100000
FD_SIZE=0x300000
measure() {
  local src="$1" label="$2"
  "$CLANG" --target=aarch64-none-elf -c -DFD_BASE=$FD_BASE -DFD_SIZE=$FD_SIZE \
      -DREQUIRES_KERNEL_HEADER=1 "$src" -o /tmp/shim.o 2>/dev/null || return 1
  local ld=$(command -v ld.lld || echo /usr/bin/ld.lld)
  "$ld" -Ttext=$FD_BASE -e _Head /tmp/shim.o -o /tmp/shim.elf 2>/dev/null || return 1
  objcopy -O binary /tmp/shim.elf /tmp/shim.bin 2>/dev/null || return 1
  python3 - "$label" <<'PY'
import struct, sys, pathlib
b = pathlib.Path('/tmp/shim.bin').read_bytes()
text_off, image_size = struct.unpack_from('<QQ', b, 8)
magic = b[56:60]
print(f"{sys.argv[1]}: len={len(b)} text_off={text_off:#x} image_size={image_size:#x} "
      f"payload_delta={image_size - 0x300000:#x} magic={magic}")
PY
}
echo "=== 原始 shim ==="
measure BootShim/BootShim.S.orig "orig"
echo "=== 打过补丁的 shim ==="
measure BootShim/BootShim.S "patched"
