#!/bin/bash
set -uo pipefail
echo "=== NuGet 错误上下文 ==="
grep -n -B3 -A3 'mu_nasm' /root/uefi-hak-fuxi/Build/UPDATE_LOG.txt 2>/dev/null | head -25 | cut -c1-160
echo
echo "=== 谁需要 mu_nasm ==="
grep -rn 'mu_nasm' /root/uefi-hak-fuxi --include='*.py' --include='*.json' --include='*.txt' 2>/dev/null | head -6 | cut -c1-160
echo
echo "=== 是否已缓存 ==="
ls ~/.nuget/packages 2>/dev/null | head -8
