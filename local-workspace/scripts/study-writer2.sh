#!/bin/bash
# Read-only: how the log writer chooses a slot.
K=/root/fuxi/t50/kernel.macho
grep -rl -E '#slot %|slot_first|SHLOG001' /root/fuxi/ref-fuxi-v2 --include='*' 2>/dev/null | head -8
F=$(grep -rl -E 'slot_first' /root/fuxi/ref-fuxi-v2 --include='*.c*' 2>/dev/null | head -1); echo "src: $F"
[ -n "$F" ] && grep -n -E 'slot_first|slot_count|slots_written|rounds|slotLba|% *.*slot|window_blocks|writeSlot|IOSleep' "$F" | cut -c1-130 | head -40
echo "== writer disassembly: udiv/msub (modulo by slot count), and stores"
llvm-objdump -d --start-address=0xfffffff00c029680 --stop-address=0xfffffff00c029a00 $K | tail -n +7 | cut -c19-90 | grep -n -E 'udiv|msub|madd|mul |#0x3fb|#1019|#0x21|#0x8$|bl\s' | head -40
