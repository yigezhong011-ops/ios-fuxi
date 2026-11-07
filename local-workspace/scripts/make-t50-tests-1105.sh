#!/bin/bash
# The three test images of 2026-11-05: clock only, 120 Hz only, both.
set -euo pipefail
T=$(tr -d '\r' < /dev/null; date +%s)
echo "clock floor $T ($(date -u -d @$T))"
M=/mnt/e/DSH-Fuxi/dump/wsl/make-t50-gpu-120.sh
tr -d '\r' < $M > /tmp/m.sh
bash /tmp/m.sh t50-mine-gpu-120 -DPANEL_120
bash /tmp/m.sh t50-mine-gpu-clock -DCLOCK_SECS=${T}UL
bash /tmp/m.sh t50-mine-gpu-120clock -DPANEL_120 -DCLOCK_SECS=${T}UL
df -h /mnt/e | tail -1
