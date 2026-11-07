#!/bin/bash
set -euo pipefail
H=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.h
python3 - "$H" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
t = re.sub(r'#define XNU_PAYLOAD_BASE\s+0x[0-9A-Fa-f]+ULL',
           '#define XNU_PAYLOAD_BASE      0xA7400000ULL', t, count=1)
t = re.sub(r'#define XNU_PAYLOAD_MAX_SIZE\s+0x[0-9A-Fa-f]+ULL',
           '#define XNU_PAYLOAD_MAX_SIZE  0x00200000ULL', t, count=1)
p.write_text(t)
print('XnuLoader.h updated')
PY
grep -n 'XNU_PAYLOAD_BASE\|XNU_PAYLOAD_MAX_SIZE' "$H"

echo "=== 更新设备 profile 的 PAYLOAD_BASE ==="
python3 - <<'PY'
import pathlib, re
p = pathlib.Path('/root/hackios/common/devices/fuxi.conf')
t = p.read_text()
t = re.sub(r'^PAYLOAD_BASE=.*$', 'PAYLOAD_BASE=0xA7400000', t, count=1, flags=re.M)
p.write_text(t)
print([l for l in t.splitlines() if l.startswith('PAYLOAD_BASE')])
PY

echo "=== 重建固件 ==="
touch /root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw-xnu4.log 2>&1
echo "FW_EXIT=$?"
grep -c 'error' /root/fw-xnu4.log || true
ls -l --time-style=+%H:%M /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
