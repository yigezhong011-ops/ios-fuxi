#!/bin/bash
set -uo pipefail
SRC=/mnt/e/DSH-Fuxi/dump/wsl/step24-build-diag2.sh
DST=/mnt/e/DSH-Fuxi/dump/wsl/step24c-build-final.sh
sed "s#^EXT=.*#EXT=/mnt/e/DSH-Fuxi/dump/ext-new2.json#" "$SRC" > "$DST"
chmod +x "$DST"
bash "$DST" 2>&1 | tail -8
