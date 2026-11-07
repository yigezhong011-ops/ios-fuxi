#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== NativeAdrenoABI.h：对外 ABI 表面 ==="
grep -n 'kMethod\|kSelector\|#define\|struct\|typedef' "$D/NativeAdrenoABI.h" 2>/dev/null | head -30
echo
echo "=== fuxi_gpu_abi.h ==="
grep -n '#define\|struct \|kFuxi\|METHOD' "$D/fuxi_gpu_abi.h" 2>/dev/null | head -25
echo
echo "=== 服务类名 ==="
grep -rn 'NativeAdrenoGpuPublished\|IOAcceleratorES\|serviceName\|setName' "$D"/*.c "$D"/*.cpp "$D"/*.h 2>/dev/null | head -10
