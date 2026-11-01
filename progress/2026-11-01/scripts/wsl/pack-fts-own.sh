#!/bin/bash
# Check the CI kernel of fts-touch (run 41294613121) carries the FTS probe, then pack its payload.
set -euo pipefail
D=/mnt/e/DSH-Fuxi/fts-touch-ci
K=$D/unixnu-fuxi-kernel/fuxi/kernel/kernel.macho
P=$D/unixnu-fuxi-payload/fuxi/payload/payload.img
echo "FTS rows in kernel:   $(grep -a -c 'FTS pwr vdd' "$K")"
echo "Novatek core strings: $(grep -a -c 'NvtTouchCore' "$K" || true)"
export MTOOLS_SKIP_CHECK=1
cmp -s <(mtype -i "$P" ::/EFI/UniXNU/Payloads/kernel.macho) "$K" && echo "payload kernel == CI kernel" || echo "payload kernel differs from CI kernel"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/pack-payload.sh > /root/fuxi/pack-payload.sh
bash /root/fuxi/pack-payload.sh "$P" unixnu-fts-own
