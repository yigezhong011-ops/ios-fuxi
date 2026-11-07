#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon15/boot.log
echo "=== swap 数 ==="; grep -a -c 'SWEET FB: swap' "$L" || true
echo "=== display on/off ==="; grep -a -n 'SWEET FB: display' "$L" | head -5
echo "=== Metal / accelerator ==="
grep -a -niE 'fuximetal|IOAcceleratorES|metal2vulkan|MTL' "$L" | head -12 || echo "(none)"
echo "=== GPU 状态 ==="
grep -a -n 'FUXI GPU' "$L" | head -6
echo "=== 行数 ==="; wc -l "$L"
