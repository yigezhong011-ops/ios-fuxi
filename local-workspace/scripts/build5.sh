#!/bin/bash
set -uo pipefail
D=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
python3 - "$D" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
t = t.replace("    UINT64 BestPages;\n", "")
p.write_text(t)
print("removed unused var")
PY
grep -n 'BestPages' "$D" || echo "(clean)"
echo "=== 开始重建固件 ==="
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw5.log 2>&1
echo "FW5_EXIT=$?"
grep -E 'error|ERROR' /root/fw5.log | head -5
ls -lh /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
