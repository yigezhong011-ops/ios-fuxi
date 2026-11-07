#!/bin/bash
set -euo pipefail
DSC=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc
INC=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc
FDF=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.fdf

python3 - "$DSC" "$INC" "$FDF" <<'PY'
import pathlib, sys
dsc, inc, fdf = (pathlib.Path(p) for p in sys.argv[1:4])

t = dsc.read_text()
if 'HobLib|' not in t:
    anchor = '  FdtLib|MdePkg/Library/BaseFdtLib/BaseFdtLib.inf'
    assert anchor in t, 'FdtLib anchor missing'
    t = t.replace(anchor, anchor + '\n  HobLib|MdePkg/Library/DxeHobLib/DxeHobLib.inf', 1)
if 'UniXNURamDiskDxe.inf' not in t:
    anchor = '  UniXNUPkg/Driver/UniXNUDxe/UniXNUDxe.inf'
    assert anchor in t, 'UniXNUDxe anchor missing'
    t = t.replace(anchor, anchor + '\n  UniXNUPkg/Driver/UniXNURamDiskDxe/UniXNURamDiskDxe.inf', 1)
dsc.write_text(t)

t = fdf.read_text()
if 'UniXNURamDiskDxe.inf' not in t:
    anchor = '  INF UniXNUPkg/Driver/UniXNUDxe/UniXNUDxe.inf'
    assert anchor in t, 'fdf anchor missing'
    t = t.replace(anchor, anchor + '\n  INF UniXNUPkg/Driver/UniXNURamDiskDxe/UniXNURamDiskDxe.inf', 1)
    fdf.write_text(t)

t = inc.read_text()
old = '  INF fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.inf'
if old in t:
    t = t.replace(old, '  # ' + old.strip() + '   # replaced by UniXNUPkg/Driver/UniXNURamDiskDxe', 1)
    inc.write_text(t)
print('patched dsc/inc/fdf')
PY

grep -n 'HobLib\|UniXNURamDiskDxe' "$DSC" | head -5
grep -n 'UniXNURamDiskDxe' "$FDF"
grep -n 'FuxiRamDiskDxe' "$INC"
