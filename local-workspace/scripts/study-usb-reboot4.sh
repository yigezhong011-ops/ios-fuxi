#!/bin/bash
# Read-only: the end of t50's reboot chain and the autoreset path. What really resets the phone, and where does it land?
K=/root/fuxi/t50/kernel.macho; S=/mnt/e/DSH-Fuxi/dump/wsl
dis() { local a=$(llvm-nm $K | awk -v s=$1 '$3==s{print $1}'); [ -z "$a" ] && { echo "no $1"; return; }; echo "--- $1 $a"; llvm-objdump -d --start-address=0x$a --stop-address=$(printf '0x%x' $((0x$a + $2))) $K 2>/dev/null | tail -n +7 | cut -c19-96; }
dis __ZN18IODTPlatformExpert11haltRestartEj 0x60
dis __ZN16IOPlatformExpert11haltRestartEj 0x60
dis _PEHaltRestartInternal 0xa0
dis _halt_all_cpus 0x50
dis _boot_reset_probe 0x90
echo "=== boot_reset symbols and callers"; llvm-nm $K | grep -E 'boot_reset|fuxi_reset|ArmDTPlatform.*(halt|Halt)' | cut -c1-100
python3 $S/find-bl-callers.py $K _boot_reset_bootloader _boot_reset_probe 2>&1 | head -12
dis _boot_reset_bootloader 0x240 | tail -60
echo "=== earlier notes on autoreset"; tr -d '\r' < $S/study-autoreset.sh | head -14 | cut -c1-150
grep -n -E 'autoreset|boot_reset|回 fastboot|bootloader' /mnt/e/DSH-Fuxi/交接-给DeepSeek-20261105.md | cut -c1-240 | head -10
grep -rn -E 'boot_reset_bootloader|boot_reset_probe' /root/fuxi/up-latest /root/fuxi/unixnu-fuxi --include='*.c' --include='*.patch' --include='*.h' 2>/dev/null | cut -c1-160 | head -8
