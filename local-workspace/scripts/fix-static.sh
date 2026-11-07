#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = "STATIC\nVOID\nConsoleAscii ("
new = "VOID\nConsoleAscii ("
if old in t:
    t = t.replace(old, new, 1)
    p.write_text(t)
    print('helper no longer STATIC')
else:
    print('pattern not found (maybe already fixed)')
PY
sed -n '28,44p' "$F"
echo "=== 重建 ==="
touch "$F"
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw-xnu3.log 2>&1
echo "FW_EXIT=$?"
grep -n 'XnuLoader.c:' /root/fw-xnu3.log | head -3
ls -l --time-style=+%H:%M /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
