#!/bin/bash
set -euo pipefail
FDF=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.fdf
python3 - "$FDF" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
for line in (
    "  INF MdeModulePkg/Universal/Disk/DiskIoDxe/DiskIoDxe.inf\n",
    "  INF MdeModulePkg/Universal/Disk/PartitionDxe/PartitionDxe.inf\n",
    "  INF FatPkg/EnhancedFatDxe/Fat.inf\n",
):
    t = t.replace(line, "")
p.write_text(t)
print("remaining block:")
for l in t.splitlines():
    if 'FuxiRamDiskDxe' in l or 'UniXNUDxe' in l:
        print(l)
PY
