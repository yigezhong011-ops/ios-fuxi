#!/bin/bash
# In the t32 kernel: who defines native_buttons_set_sink, where the sink is stored, and which functions read it
# (a button source would call the stored sink). Also list button / pon / spmi-ish symbols.
set -uo pipefail
K=/root/fuxi/t32/kernel.macho
echo "== symbols"
llvm-nm --defined-only "$K" 2>/dev/null | grep -i -E 'button|_pon|spmi|pmic|keypad|volume|sheng_key|native_key' | head -40
echo "== native_buttons_set_sink"
A=$(llvm-nm --defined-only "$K" | awk '$3=="_native_buttons_set_sink"{print $1}')
echo "addr=$A"
[ -n "$A" ] && llvm-objdump -d --no-show-raw-insn --start-address=0x$A --stop-address=$(printf '0x%x' $((0x$A + 0x40))) "$K" | tail -n +7
