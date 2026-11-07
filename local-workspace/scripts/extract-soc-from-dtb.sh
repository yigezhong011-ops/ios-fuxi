#!/bin/bash
set -uo pipefail
D=/root/fuxi/dtbcmp
mkdir -p "$D"
[ -f "$D/final.dts" ] || dtc -I dtb -O dts -o "$D/final.dts" "$D/final.dtb" 2>/dev/null
F="$D/final.dts"
echo "=== reserved-memory 里相关节点 ==="
awk '/reserved-memory \{/,/^\t\};/' "$F" | grep -n -E 'cmd_db|mpss|ipa_fw|ipa-fw|adsp|memory-region|reg = ' | head -40 | cut -c1-150
