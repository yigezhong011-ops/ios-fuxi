#!/bin/bash
set -euo pipefail
FDF=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.fdf
cp "$FDF" "$FDF.orig"
python3 - "$FDF" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
anchor = "  INF UniXNUPkg/Driver/UniXNUDxe/UniXNUDxe.inf"
add = anchor + """

  # Payload volume: expose the fastboot ramdisk as block IO, then partition + FAT
  INF fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.inf
  INF MdeModulePkg/Universal/Disk/DiskIoDxe/DiskIoDxe.inf
  INF MdeModulePkg/Universal/Disk/PartitionDxe/PartitionDxe.inf
  INF FatPkg/EnhancedFatDxe/Fat.inf"""
if 'FuxiRamDiskDxe.inf' in t:
    print('already present')
else:
    assert anchor in t, 'anchor missing'
    t = t.replace(anchor, add, 1)
    p.write_text(t)
    print('patched fdf')
PY
grep -n -A5 'UniXNUDxe.inf' "$FDF"
