#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu
echo "=== 我们内核里所有启动参数（PE_parse_boot_argn）==="
grep -rhno 'PE_parse_boot_argn([^,)]*' "$D"/fuxi-* "$D"/fuxi-h1 "$D"/fuxi-adreno 2>/dev/null \
  | sed 's/.*PE_parse_boot_argn(//' | tr -d '"' | sort -u | head -30
echo
echo "=== 全树里 fuxi 相关参数名 ==="
grep -rhno '"fuxi[a-z_]*' "$D"/fuxi-* 2>/dev/null | sed 's/.*"//' | sort -u | head -25
