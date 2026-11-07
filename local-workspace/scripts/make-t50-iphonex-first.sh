#!/bin/bash
# t50-auto-iphonex-first: t50-auto-iphonex2's volume (iPhone X identity, stored Data) with a longer reset, 420 s, for the first boot on a reset Data store. Temp boot only.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh /root/fuxi/t50-ipx2 420 t50-auto-iphonex-first
export MTOOLS_SKIP_CHECK=1
mtype -i /root/fuxi/auto-t50-auto-iphonex-first/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'sheng-data-persist=[0-9]|sheng-setup=[0-9]|sheng-autoreset=[0-9]+|sheng-data-reset=[0-9]' | tr '\n' ' '; echo
mcopy -n -i /root/fuxi/auto-t50-auto-iphonex-first/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt /tmp/f.adt
strings -a /tmp/f.adt | grep -E '^(iPhone|D22)' | sort -u | tr '\n' ' '; echo; rm -f /tmp/f.adt
