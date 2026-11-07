#!/bin/bash
# t50-auto-usbfast: wall17 with the worker and panic reset patches of patch-t50-usbfast.py. Autoreset stays as the fallback. Temp boot only; writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-usbfast
rm -rf "$W"; mkdir -p "$W"; cp /root/fuxi/t50-wall17/vol.img "$W/vol.img"
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.old"
cmp "$W/kernel.old" /root/fuxi/t50-wall17/kernel.macho
python3 -I $S/patch-t50-usbfast.py "$W/kernel.old" "$W/kernel.macho"
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.macho" >/dev/null
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.back"; cmp "$W/kernel.back" "$W/kernel.macho"
echo "kernel bytes changed: $(cmp -l "$W/kernel.old" "$W/kernel.macho" | wc -l)"
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00bd0d95c --stop-address=0xfffffff00bd0d968 "$W/kernel.macho" | tail -3 | cut -c1-90
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00b8a3228 --stop-address=0xfffffff00b8a3234 "$W/kernel.macho" | tail -3 | cut -c1-90
llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00c0903b8 --stop-address=0xfffffff00c0903c4 "$W/kernel.macho" | tail -3 | cut -c1-90
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-usbfast
mtype -i /root/fuxi/auto-t50-auto-usbfast/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'qcom-usb-ctl=[0-9]|sheng-data-persist=[0-9]|sheng-setup=[0-9]|sheng-autoreset=[0-9]+' | tr '\n' ' '; echo
