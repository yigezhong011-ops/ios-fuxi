#!/bin/bash
# The daily candidate: exactly the kernel and addon t50-auto-wall17 ran, with the daily image's own boot arguments (no sheng-autoreset, no qcom-usb-ctl). Writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-wall17; OUT=$E/t50-daily-wall17.img; D=/root/fuxi/gpu-new-t50-mine/vol.img
[ ! -e "$OUT" ] || { echo "refuse to overwrite $OUT"; exit 1; }
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > /tmp/t-cand.toml
mtype -i "$D" ::/EFI/UniXNU/unixnu.toml > /tmp/t-daily.toml
cmp /tmp/t-cand.toml /tmp/t-daily.toml && echo 'boot config identical to the daily base'
! grep -q -E 'sheng-autoreset|qcom-usb-ctl' /tmp/t-cand.toml
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho /tmp/k-cand
cmp /tmp/k-cand "$W/kernel.macho" && echo 'kernel is the one wall17 ran'
mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - "$W/addon-new.bin" && echo 'addon is the one wall17 ran'
for f in kernel.macho.trustcache kernel.macho.adt scratch-data.img; do
  mcopy -n -i "$W/vol.img" "::/EFI/UniXNU/Payloads/$f" /tmp/a.$f; mcopy -n -i "$D" "::/EFI/UniXNU/Payloads/$f" /tmp/b.$f; cmp /tmp/a.$f /tmp/b.$f && echo "same as daily base: $f"
done
python3 -I $S/repack-with-vol.py $E/t50-mine.img "$W/vol.img" "$OUT" >/dev/null
python3 -I $S/compare-loaders.py "$OUT" | tail -1
python3 -I $S/compare-loaders.py $E/t50-mine-gpu-fix.img | tail -1
ls -la "$OUT" $E/t50-mine-gpu-fix.img | cut -c24-
sha256sum "$OUT" | cut -c1-16
rm -f /tmp/k-cand /tmp/a.* /tmp/b.* /tmp/t-cand.toml /tmp/t-daily.toml
