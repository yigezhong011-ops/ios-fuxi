#!/bin/bash
set -uo pipefail
echo "=== 我们 uefi-fuxi 的固件卷 ==="
find /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi -name 'SILICIUM_UEFI.fd' 2>/dev/null | head -3
find /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi -path '*fuxiPkg*' -name '*.fd' 2>/dev/null | head -3
echo
echo "=== 设备树 ==="
ls -l /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/FdtBlob/*.dtb 2>/dev/null | head -3
echo
echo "=== 他们的 bootimg 选项 ==="
cd /root/uni-odd || exit 1
python3 - <<'PY'
import subprocess
r = subprocess.run(['python3', 'unixnu', 'bootimg', '--help'], capture_output=True, text=True)
print((r.stdout or r.stderr)[:1200])
PY
echo
echo "=== payload 选项 ==="
python3 - <<'PY'
import subprocess
r = subprocess.run(['python3', 'unixnu', 'build', 'payload', '--help'], capture_output=True, text=True)
print((r.stdout or r.stderr)[:1200])
PY
