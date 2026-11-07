#!/bin/bash
set -euo pipefail
cd /root/hackios
CONF=common/devices/fuxi.conf
python3 - "$CONF" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
subs = {
    r'^NAME=.*$': 'NAME="Xiaomi 13 (fuxi)"',
    r'^SOC=.*$': 'SOC="Qualcomm SM8550"',
    r'^FD_BASE=.*$': 'FD_BASE=0xA7100000',
    r'^FD_SIZE=.*$': 'FD_SIZE=0x300000',
    r'^PAYLOAD_BASE=.*$': 'PAYLOAD_BASE=0xA8000000',
    r'^FB_BASE=.*$': 'FB_BASE=0xB8000000',
}
for pat, rep in subs.items():
    t = re.sub(pat, rep, t, count=1, flags=re.M)
p.write_text(t)
print('profile updated')
PY
grep -E 'NAME=|SOC=|FD_BASE|FD_SIZE|PAYLOAD_BASE|FB_BASE|BOOTARGS' "$CONF"
echo
echo "=== 试着把 hackios 的 UEFI 补丁打到我们的 uefi-fuxi ==="
cd /root/uefi-fuxi
git init -q 2>/dev/null || true
git apply --check /root/hackios/uefi/mu-silicium.patch 2>&1 | head -10 && echo "PATCH_CHECKS_OK" || echo "PATCH_HAS_CONFLICTS"
