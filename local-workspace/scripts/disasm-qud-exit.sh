#!/bin/bash
# qcom_usb_debug_init's early-exit path and what the "_native" state at its start is (who sets field 0).
K=/root/fuxi/t36/kernel.macho
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00c06b13c --stop-address=0xfffffff00c06b1b0 $K | tail -n +7
echo "--- symbols around _native"
llvm-nm -n $K | awk '$1 >= "fffffff00c46b000" && $1 < "fffffff00c46b500"' | head -12
echo "--- related entry points"
llvm-nm $K | grep -iE ' _native$|qcom_usb_debug_(early|enable|boot|configure|set|arm)|qud_' | head -20
