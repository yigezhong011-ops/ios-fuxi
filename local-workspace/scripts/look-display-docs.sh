#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
for f in docs-lanes/touch-display.md docs-lanes/gpu-scanout.md; do
  echo "================ $f ================"
  grep -nE '^#' "$f" | head -12
  echo "--- 关键内容（scanout / CTL / INTF / framebuffer / 60 Hz）---"
  grep -n -i -E 'scanout|ctl0|intf|framebuffer|60 hz|present|vsync|copy' "$f" | head -20
  echo
done
