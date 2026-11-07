#!/bin/bash
# Disassemble NativeHidInput::start of the t32 kernel around its native_buttons_set_sink call, and buttonsNotify / buttonsAction,
# to see what has to hold for the sink to be registered and for a button mask to become a HID report.
K=/root/fuxi/t32/kernel.macho
dis() { llvm-objdump -d --no-show-raw-insn --start-address=$1 --stop-address=$2 "$K" | tail -n +7; }
echo "== NativeHidInput::start, around the set_sink call (0xfffffff00c031798)"
dis 0xfffffff00c031700 0xfffffff00c0317b0
echo "== buttonsNotify"
dis 0xfffffff00c031bc4 0xfffffff00c031bfc
echo "== buttonsAction (first part)"
dis 0xfffffff00c032630 0xfffffff00c0326f0
