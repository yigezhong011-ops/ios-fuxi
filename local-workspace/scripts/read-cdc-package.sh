#!/bin/bash
set -uo pipefail
cd /root
rm -rf cdc
mkdir -p cdc
tar xzf /mnt/c/Users/USER/Downloads/cdc-kernel-20261030.tar.gz -C cdc
echo "=== 解出 ==="
find cdc -type f | head -25
echo
echo "=== AGENTS.md ==="
sed -n '1,60p' cdc/AGENTS.md 2>/dev/null
