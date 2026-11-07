#!/bin/bash
set -euo pipefail
SRC=/mnt/e/DSH-Fuxi/dump/wsl/step24-build-diag2.sh
DST=/mnt/e/DSH-Fuxi/dump/wsl/step24b-build-iphonex.sh
sed "s#^EXT=.*#EXT=/mnt/e/DSH-Fuxi/dump/ext-new.json#" "$SRC" > "$DST"
chmod +x "$DST"
grep -n '^EXT=' "$DST"
echo "=== 运行 ==="
bash "$DST" 2>&1 | tail -12
