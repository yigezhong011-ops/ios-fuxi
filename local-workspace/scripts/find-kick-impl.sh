#!/bin/bash
set -uo pipefail
echo "=== 全仓搜索 fuxi_display_kick ==="
grep -rn 'fuxi_display_kick' /root/ios-fuxi/ 2>/dev/null | grep -v '\.patch' | head -10
echo
echo "=== patch 里的实现 ==="
grep -rn -A12 'fuxi_display_kick(void)' /root/ios-fuxi/xnu/patches/*.patch 2>/dev/null | head -30
