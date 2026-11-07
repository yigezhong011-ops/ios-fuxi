#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== fuxigpulevel / fuxigpuclock 的用法 ==="
grep -rn 'fuxigpulevel\|fuxigpuclock\|gpu_level\|level' "$D"/*.c "$D"/*.inc 2>/dev/null | grep -i 'level' | head -15
echo
echo "=== 档位表（OPP/khz）==="
grep -rn 'khz\|LEVELS\|levels\[' "$D"/*.c "$D"/*.inc 2>/dev/null | head -15
