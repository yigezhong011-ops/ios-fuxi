#!/bin/bash
# Show what the entry probe wrote: the patched call site in _arm_init and the stage-4 cave.
# Usage: show-probe-cave.sh <pkg-dir> <call-site-va>
set -euo pipefail
K=$1/kernel.macho
read -r LO HI < <(python3 -c "s=int('$2',16); print(hex(s-8), hex(s+12))")
echo "== call site $2 in $K"
llvm-objdump -d --no-show-raw-insn --start-address=$LO --stop-address=$HI "$K" | tail -n +7
echo "== stage-4 cave"
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff0073f0620 --stop-address=0xfffffff0073f0690 "$K" | tail -n +7
