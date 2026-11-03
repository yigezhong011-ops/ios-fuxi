#!/bin/bash
# Disassemble qcom_usb_debug_init (and its size) in a kernel, to see whether it is the real backend or an early-return stub.
K=${1:-/root/fuxi/t36/kernel.macho}
A=$(llvm-nm --defined-only $K | awk '$3=="_qcom_usb_debug_init"{print $1}')
N=$(llvm-nm --defined-only -n $K | awk -v a="$A" 'found{print $1; exit} $1==a{found=1}')
echo "qcom_usb_debug_init at 0x$A, next symbol at 0x$N, size $(( 0x$N - 0x$A )) bytes"
llvm-objdump -d --no-show-raw-insn --start-address=0x$A --stop-address=$(printf '0x%x' $(( 0x$A + 0x140 ))) $K | tail -n +7 | head -80
