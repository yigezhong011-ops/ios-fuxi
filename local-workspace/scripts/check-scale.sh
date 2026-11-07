#!/bin/bash
set -uo pipefail
echo "=== SweetFramebuffer 里的缩放/拷贝逻辑 ==="
grep -n -E 'canvas|scale|src_w|dst_w|width|stride' /mnt/e/DSH-Fuxi/SweetFramebuffer.repo.cpp 2>/dev/null | head -25
echo
echo "=== 内核里读 canvas 的地方 ==="
grep -rn 'canvas' /root/ios-fuxi/xnu/ 2>/dev/null | head -10
