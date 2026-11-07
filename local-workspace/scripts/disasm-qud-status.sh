#!/bin/bash
# What qcom_usb_debug_get_status copies from, and the kernel API available for running code on the boot CPU.
K=/root/fuxi/t36/kernel.macho
A=$(llvm-nm --defined-only $K | awk '$3=="_qcom_usb_debug_get_status"{print $1}')
llvm-objdump -d --no-show-raw-insn --start-address=0x$A --stop-address=$(printf '0x%x' $(( 0x$A + 0x90 ))) $K | tail -n +7 | head -36
echo "--- boot-CPU helpers"
llvm-nm --defined-only $K | grep -E ' _(thread_bind|master_processor|cpu_to_processor|processor_array|master_cpu|cpu_number|thread_block|kernel_thread_start_priority)$'
