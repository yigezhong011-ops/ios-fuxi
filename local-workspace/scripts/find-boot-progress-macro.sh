#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
echo "=== 树里 boot_progress_start 的宏定义 ==="
grep -rn '#define[[:space:]]*boot_progress_start' "$T" 2>/dev/null | head -5
echo
echo "=== 编译命令行里的 -D ==="
L=/root/ux2/fuxi/logs/archive-11-build-boot-progress.log
grep -a 'clang' "$L" 2>/dev/null | head -1 | tr ' ' '\n' | grep -a '^-D\|^-include\|^-I' | head -16
