#!/bin/bash
# Who writes NativeHidInput's byte +0xe3 (it makes start() skip native_buttons_set_sink)? Scan the class's code and the
# fuxi touch sink (native_touch_set_sink and its neighbourhood) for byte stores at #0xe3, and list the strings near them.
K=/root/fuxi/t32/kernel.macho
dis() { llvm-objdump -d --no-show-raw-insn --start-address=$1 --stop-address=$2 "$K" | tail -n +7; }
echo "== NativeHidInput class code (0xc031168..0xc0327a0), stores at +0xe3"
dis 0xfffffff00c031168 0xfffffff00c0327a0 | grep -n -E 'strb.*#0xe3\]'
echo "== constructor C2Ev"
dis 0xfffffff00c0313e0 0xfffffff00c031570 | grep -E 'strb|strh|str\s' | head -20
echo "== native_touch_set_sink and the 0x400 bytes after"
dis 0xfffffff00c0336c0 0xfffffff00c033ac0 | grep -n -E '#0xe[0-4]\]|bl\s' | head -30
