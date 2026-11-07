#!/bin/bash
set -uo pipefail
F=/root/.local/xnu-linux/bin/iig
echo "=== 关键函数/关键字行 ==="
grep -n 'KernelMethods\|LOCAL\|def \|skip\|PRIVATE_WIFI' "$F" | head -30 | cut -c1-150
