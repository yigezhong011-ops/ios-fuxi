#!/bin/bash
# Read-only: every document and source line about the USB reboot hook. Nothing from the clones is run.
Q=/root/fuxi/ref-qud; F=/root/fuxi/ref-fuxi-v2; K=/root/fuxi/t50/kernel.macho
echo "=== V2 USB-RESTORE doc"; git -C $F show origin/V2:USB-RESTORE-20261102.md | cut -c1-400
echo "=== QUD docs list"; git -C $Q ls-files | grep -iE '\.md$|\.txt$|docs/'
echo "=== QUD docs mentioning reboot"; git -C $Q grep -n -iE 'reboot|nohook|psci|hook' -- '*.md' '*.txt' | cut -c1-300 | head -60
echo "=== QUD kernel reboot code"; git -C $Q grep -n -E 'nohook|PSCI|reboot_hook|arm_reboot|take_reboot|PE_halt_restart|halt_restart|SMC_RESET' -- kernel patches scripts | cut -c1-200 | head -60
echo "=== V2 reboot settings"; git -C $F grep -n -E 'QUD_PSCI_SMC_RESET|nohook|arm_reboot|PE_halt_restart' origin/V2 | cut -c1-220 | head -30
echo "=== t50 symbols"; llvm-nm $K | grep -iE 'qcom_usb.*reboot|PE_halt_restart|halt_restart|psci|_Debugger$|_PEHaltRestart|_halt_all_cpus' | cut -c1-120 | head -30
echo "=== t50 callers"; python3 /mnt/e/DSH-Fuxi/dump/wsl/find-bl-callers.py $K _qcom_usb_debug_control_arm_reboot _PE_halt_restart _PEHaltRestart _halt_all_cpus 2>&1 | head -30
grep -a -o -E 'qcom-usb-[a-z-]+' $K | sort -u
