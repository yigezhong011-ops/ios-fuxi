#!/bin/bash
# Read-only: the REBOOT worker and the panic flush in the t50 kernel, to find call sites that can go straight to the reset. Writes only under /tmp.
set -u
K=/root/fuxi/t50/kernel.macho
O=/tmp/t50-syms.txt
llvm-nm --defined-only "$K" 2>/dev/null > "$O"; wc -l "$O"
grep -E ' _?(qcom_usb_debug_control_take_reboot|qcom_usb_debug_control_reboot|control_reboot_[a-z]+|reboot_kernel|qcom_usb_debug_panic[a-z_]*|qcom_usb_debug_worker[a-z_]*|PE_halt_restart|panic_trap_to_debugger|Debugger|DebuggerTrapWithState|handle_debugger_trap|halt_all_cpus|qcom_usb_[a-z_]*reboot[a-z_]*)$' "$O"
A=/tmp/t50.dis
[ -s "$A" ] || llvm-objdump -d --no-show-raw-insn "$K" > "$A" 2>/dev/null
wc -l "$A"
echo '== callers of take_reboot'
grep -n -E 'bl\s.*qcom_usb_debug_control_take_reboot' "$A" | head
grep -n -E 'bl\s.*_reboot_kernel>' "$A" | head -12
for f in qcom_usb_debug_control_take_reboot qcom_usb_debug_panic_flush; do
  echo "== $f"; awk -v n="<_$f>:" 'index($0,n){p=1} p{print; c++} p&&/^$/{exit} c>70{exit}' "$A" | cut -c1-90
done
echo '== callers of panic flush'; grep -n -E 'bl\s.*qcom_usb_debug_panic' "$A" | cut -c1-100 | head
echo '== usb worker strings'; strings -a -t x "$K" | grep -E 'QCOM USB REBOOT|QCOM PANIC' | head
