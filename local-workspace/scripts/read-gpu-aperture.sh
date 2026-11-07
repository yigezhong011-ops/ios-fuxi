#!/bin/bash
# Read-only: how the 2 GiB GPU aperture is compiled in bringUp and what the SMMU kit requires of a larger one.
set -u
A=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt; S=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers/Adreno740
grep -E 'NativeAdrenoGpuContext.*bringUp|NativeAdrenoSmmuContext.*prepare|ArmSmmu4K.*(Prepare|Init|Arena|Live)[A-Za-z]*' "$N" | cut -c1-110 | head -12
B=$(grep -E 'NativeAdrenoGpuContext6bringUp' "$N" | head -1 | cut -d' ' -f1)
echo "bringUp $B"
L=$(grep -n "^$B <" "$A" | cut -d: -f1)
sed -n "$L,$((L+320))p" "$A" | sed -E 's/<[^>]*>//' | grep -n -E '#0x(403|403000|80000|80000000|7fffffff)\b|mov[zk]?.*(#0x403|#0x80000|#0x8000)|lsl #(12|16)|bl\s' | cut -c1-74 | head -40
echo '== SMMU context prepare'
grep -n -A28 'NativeAdrenoSmmuContext::prepare' "$S/NativeAdrenoSmmuContext.cpp" | cut -c1-150 | head -44
echo '== other aperture users'
grep -n -E 'GpuApertureBytes|MaxLeaves|TablePages' "$S"/*.cpp "$S"/*.h | cut -c${#S}- | cut -c1-140
grep -n -E 'NativeAdrenoDeviceClientIova' "$S"/*.h "$S"/*.cpp /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package/*.cpp | cut -c30-170 | head -6
echo '== kit limits'
K=$(grep -rl -E 'ArmSmmu4KLiveArena' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package --include=*.c --include=*.cpp --include=*.h 2>/dev/null | head -8)
echo "$K" | cut -c30-
grep -n -E 'InputBits|input_bits|t0sz|T0SZ|aperture|>= *\(?1ULL|1ull<<3|1ULL<<3|0x80000000|0x100000000' $K 2>/dev/null | cut -c30-180 | head -24
