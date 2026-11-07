#!/bin/bash
# Disassemble the start of the DarwinBoot/UEFI loader that precedes the FAT payload in the boot image
# (userboot/body.bin), to see whether it relocates itself (so the ARM64 header's text_offset could be 0).
set -euo pipefail
B=${1:-/root/fuxi/userboot/body.bin}
xxd -l 64 "$B"
head -c 4096 "$B" > /tmp/loader-head.bin
llvm-objcopy -I binary -O elf64-littleaarch64 --rename-section .data=.text,code /tmp/loader-head.bin /tmp/loader-head.o
llvm-objdump -d --no-show-raw-insn /tmp/loader-head.o | sed -n '7,70p'
