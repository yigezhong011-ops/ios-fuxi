#!/bin/bash
# t50-auto-iphonex-rej: the iPhone X first-boot image plus boot-progress=2, whose page prints the display's REJ rows (reason, layer state, surface). Temp boot only.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-ipx-rej
rm -rf "$W"; mkdir -p "$W"; cp /root/fuxi/t50-ipx2/vol.img "$W/vol.img"
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
EXTRA_ARGS='boot-progress=2' bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-iphonex-rej
mtype -i /root/fuxi/auto-t50-auto-iphonex-rej/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'boot-progress=[0-9]|sheng-data-persist=[0-9]|sheng-autoreset=[0-9]+|offline-legacy-validate=[0-9]|offline-legacy-unit-scale=[0-9]' | tr '\n' ' '; echo
mkdir -p /mnt/e/DSH-Fuxi/待删除/sheng-logs-copy
mv /mnt/e/DSH-Fuxi/unixnu-build/fuxi/build/sheng-logs/untagged-447e254a /mnt/e/DSH-Fuxi/待删除/sheng-logs-copy/ 2>/dev/null || true
