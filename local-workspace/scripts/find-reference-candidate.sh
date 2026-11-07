#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
echo "=== audit-amfi-pmgr-contract.py 里的 reference candidate ==="
grep -n 'candidate\|reference\|prelink' "$D/scripts/audit-amfi-pmgr-contract.py" 2>/dev/null | head -12
echo
echo "=== build-sheng-platform-power.py 前 30 行 ==="
sed -n '1,30p' "$D/scripts/build-sheng-platform-power.py" 2>/dev/null
echo
echo "=== 设备仓库里提到 candidate 的地方 ==="
grep -rn 'xnu-prelink\|candidate' "$D"/*.toml "$D"/scripts/*.py 2>/dev/null | head -10
