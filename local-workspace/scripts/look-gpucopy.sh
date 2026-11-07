#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== sweet_surface_gpu_copy 实现位置 ==="
grep -rn 'sweet_surface_gpu_copy' --include='*.cpp' --include='*.h' xnu/ | head -5
echo
echo "=== 它的返回码含义 ==="
F=$(grep -rln 'int sweet_surface_gpu_copy' xnu/ | head -1)
echo "file: $F"
grep -n -E 'return 3|return -|busy|ring|fScanout|boot_arg|PE_parse' "$F" | head -30
echo
echo "=== 相关 boot-arg ==="
grep -rn 'fuxigpuscanout\|fuxigpuabi\|sweetgpu\|nogpucopy\|fuxigpu' --include='*.cpp' --include='*.c' xnu/ | head -15
