#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== common/build.sh 前 60 行 ==="
sed -n '1,60p' common/build.sh
echo
echo "=== common/ 目录 ==="
ls common/
echo
echo "=== uefi/ 目录（Mu-Silicium 补丁与集成）==="
ls uefi/
