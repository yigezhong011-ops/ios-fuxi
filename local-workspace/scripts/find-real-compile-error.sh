#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 行数 ==="
wc -l "$L" | tr -d '\n'; echo
echo
echo "=== 真正的编译错误（*.c/*.cpp:行:列: error）==="
grep -aE '\.(c|cpp|cc|h):[0-9]+:[0-9]+: error:' "$L" 2>/dev/null | head -8 | cut -c1-180
echo
echo "=== 链接器 / make 失败 ==="
grep -a 'Undefined symbols\|symbol(s) not found\|cannot find\|No such file' "$L" 2>/dev/null | head -6 | cut -c1-160
