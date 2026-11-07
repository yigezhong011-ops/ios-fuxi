#!/bin/bash
# Read-only: slot guards in the compiled stats and overflow code, the grant string's user, grant matching, other users of slots and queue limits.
set -u
A=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt; K=/root/fuxi/t50/kernel.macho; S=/mnt/e/DSH-Fuxi/unixnu-build
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
ls -la /root/fuxi/t50-shot/kernel.macho 2>/dev/null | cut -c24-; ls /root/fuxi/t50-shot | head
echo '== users of client_stats (0xfffffff00c180b30) and overflow (b00)'
grep -n -A1 -E 'adrp.*0xfffffff00c180000' "$A" | grep -E 'add.*#0xb(00|30)' | cut -c1-90 | head -12
for l in $(grep -n -A1 -E 'adrp.*0xfffffff00c180000' "$A" | grep -E 'add.*#0xb(00|30)' | cut -d- -f1 | head -8); do echo "-- $l"; sed -n "$((l-10)),$((l+6))p" "$A" | cut -f2- | sed -E 's/<[^>]*>//' | cut -c1-50; done
echo '== grant string VA 0xfffffff0071433b6'
grep -n -A1 -E 'adrp.*0xfffffff007143000' "$A" | grep -E '#0x3b6' | cut -c1-90
L=$(grep -n -A1 -E 'adrp.*0xfffffff007143000' "$A" | grep -E '#0x3b6' | cut -d- -f1 | head -1)
[ -n "$L" ] && sed -n "$((L-6)),$((L+6))p" "$A" | cut -c1-80
echo '== grant patch'
sed -n 1,45p "$S/fuxi/patches/xnu/zzw-native-adreno-sandbox-grant.patch" | cut -c1-120
echo '== queue use in submit'
grep -n -E 'queue' "$S/unixnu/drivers/Adreno740/NativeAdrenoSubmit.h" | cut -c1-140 | head -14
grep -n -E 'NativeAdrenoSubmit::submit|queue>|queue<|\.queue=|max_queue' "$S/unixnu/drivers/Adreno740/NativeAdrenoSubmit.cpp" | cut -c1-140 | head -10
echo '== other kernel slot-indexed uses'
grep -n -E 'slot' "$S/unixnu/drivers/Adreno740/NativeAdrenoUserClient.cpp" | cut -c1-140 | head -14
grep -n -E 'slot_\b' "$S/unixnu/drivers/Adreno740/NativeAdrenoPublish.cpp" | cut -c1-120
echo '== VM bound'
grep -n -E 'input_bits|inputBits' "$S/unixnu/drivers/Adreno740/NativeAdrenoVm.cpp" "$S/unixnu/drivers/Adreno740/NativeAdrenoVm.h" "$S/unixnu/drivers/Adreno740/NativeAdrenoUserClient.cpp" | cut -c44-180 | head -12
echo '== plugin use of va_start, anything capped to 2 GiB?'
grep -rn -E 'va_start|va_size' "$S/unixnu/drivers/AdrenoMetal" --include=*.c --include=*.cpp --include=*.h --include=*.rs --include=*.patch 2>/dev/null | cut -c40-190 | head -10
