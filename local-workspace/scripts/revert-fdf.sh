#!/bin/bash
set -uo pipefail
FDF=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.fdf
echo "=== DXE.inc 里是否已有 FuxiRamDiskDxe ==="
grep -n -i 'ramdisk\|fat\|diskio' /root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc 2>/dev/null | head -10
echo
echo "=== 撤销我加的显式行 ==="
python3 - "$FDF" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
block = """

  # Payload volume: expose the fastboot ramdisk as block IO, then partition + FAT
  INF fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.inf"""
if 'Payload volume: expose the fastboot ramdisk' in t:
    t = t.replace(block, "")
    p.write_text(t)
    print('reverted explicit ramdisk line')
else:
    print('nothing to revert')
PY
grep -n -i 'ramdisk' "$FDF" || echo "(fuxi.fdf 中无显式 ramdisk 行)"
echo
echo "=== 旧固件里的 UTF-16 字符串 ==="
strings -el /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd 2>/dev/null | grep -i 'ramdisk' | head -3
strings -el /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd 2>/dev/null | grep -i 'unixnu' | head -3
