#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-probe/probe.c
echo "=== probe.c 里的 RPMh / LDO ==="
grep -n -i 'rpmh\|ldob12\|ldom6\|vreg\|rail\|cmd_db\|rsc' "$F" | head -20
echo
echo "=== 文件规模 ==="
wc -l "$F"
echo
echo "=== 是否有 touch 相关（request 0x55 附近）==="
grep -n -i 'touch\|fts\|0x55' "$F" | head -15
