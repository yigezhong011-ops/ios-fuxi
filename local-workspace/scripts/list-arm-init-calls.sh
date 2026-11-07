#!/bin/bash
# List the `bl` targets inside a kernel function, in order (candidates for --reset-after).
# Usage: list-arm-init-calls.sh [kernel] [function]
set -euo pipefail
K=${1:-/root/fuxi/touch-kernel.macho}
F=${2:-_arm_init}
read -r START END < <(llvm-nm -n --defined-only "$K" | awk -v f="$F" '
  found && $1 != start { print start, $1; exit }
  $3 == f { found = 1; start = $1 }')
echo "$F: 0x$START .. 0x$END"
llvm-objdump -d --no-show-raw-insn --start-address=0x$START --stop-address=0x$END "$K" \
  | grep -E '\bbl\b' | sed -E 's/^ *([0-9a-f]+):.*<([^>]+)>.*/\1 \2/' | awk '{c[$2]++; print NR": "$1"  "$2"  (#"c[$2]")"}'
