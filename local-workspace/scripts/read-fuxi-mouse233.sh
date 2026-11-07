#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs/devices/fuxi-mouse233.md
echo "=== 前 60 行（状态表）==="
sed -n '1,60p' "$F"
