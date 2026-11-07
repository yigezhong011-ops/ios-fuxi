#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/ci/kinject/kernel.development.fuxi.unstripped
START=0xfffffe00078468c8
END=0xfffffe000784b8d4
echo "=== _exec_mach_imgact 里的 and 指令（找 CS 掩码） ==="
llvm-objdump --macho --disassemble --start-address=$START --stop-address=$END "$K" 2>/dev/null \
  | grep -E '\band\b' | head -40
