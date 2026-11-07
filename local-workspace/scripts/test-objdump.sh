#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/ci/kinject/kernel.development.fuxi.unstripped
echo "=== 文件类型 ==="
file "$K"
echo
echo "=== llvm-objdump 头信息（前 20 行）==="
llvm-objdump --macho --all-headers "$K" 2>&1 | head -20
echo
echo "=== 直接反汇编一个已知符号 ==="
llvm-objdump --macho --disassemble-symbols=_panic "$K" 2>&1 | head -12
