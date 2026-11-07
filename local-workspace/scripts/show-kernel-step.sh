#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-star || exit 1
echo "=== Build kernel 步骤 ==="
awk '/name: Build kernel/,/name: Kernel log tail/' .github/workflows/macos.yml | head -30 | cut -c1-150
