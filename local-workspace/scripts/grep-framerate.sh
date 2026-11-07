#!/bin/bash
# Who decides the frame rate on the userland side?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== 可能决定帧率的字段/服务 ==="
for k in 'maximumFramesPerSecond' 'preferredFramesPerSecond' 'CADisplayLink' 'framesPerSecond' \
         'targetFrameRate' 'refreshRate' 'ProMotion' 'kIOMFBFramebuffer' 'DisplayLink' \
         'requestedRefreshRate'; do
  printf '  %-28s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== 具体行（去重，前 12）==="
grep -a -E 'maximumFramesPerSecond|preferredFramesPerSecond|targetFrameRate|refreshRate' "$L" \
  | sed 's/^[^ ]* //' | sort -u | head -12 | cut -c1-220
