#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/ci/kinject/kernel.development.fuxi.unstripped
# ulimit -f 4096   # 4 MB split allows > 4 GB
ulimit -f 1048576
echo "=== 找 exec_mach_imgact 附近的 and 掩码（含 CS_HARD/CS_KILL/CS_RESTRICT/CS_ENFORCEMENT）==="
llvm-objdump --macho --disassemble-symbols=exec_mach_imgact "$K" 2>/dev/null \
  | grep -E '\band\b.*#0x' | head -30
echo
echo "=== 如果上面为空，列出该函数的前 40 条指令 ==="
llvm-objdump --macho --disassemble-symbols=exec_mach_imgact "$K" 2>/dev/null | head -50
