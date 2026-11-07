#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== BootProgress.c 里的 stride / row / bpr ==="
grep -n 'stride\|rowbytes\|row_bytes\|bpr\|pitch\|1080\|1000' "$T/kits/sheng/BootProgress.c" 2>/dev/null | head -12 | cut -c1-170
echo
echo "=== native legacy display 里的 stride ==="
grep -n 'stride\|rowbytes\|pitch' "$T/drivers/GopFramebuffer/NativeLegacyDisplay.cpp" 2>/dev/null | head -10 | cut -c1-170
echo
echo "=== console 渲染的地方 ==="
grep -rn 'console' "$T/kits/sheng/BootProgress.c" 2>/dev/null | head -6 | cut -c1-170
