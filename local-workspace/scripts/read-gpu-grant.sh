#!/bin/bash
# Read-only: the grant list in the t50 kernel, the rest of mount and the close path, the GPU VA limit.
set -u
K=/root/fuxi/t50/kernel.macho; A=/root/fuxi/t50.dis
strings -a -t x "$K" | grep -E 'backboardd,|iconservicesagent,|NativeSandboxGrantProcess' | cut -c1-110
echo '== mount tail'
awk '/^fffffff00c00eb34 </{p=1} /^fffffff00c00f0a4 </{p=0} p' "$A" | cut -f2- | sed -E 's/<[^>]*>//' | cut -c1-58 | sed -n 175,215p
echo '== close, slot part'
awk '/^fffffff00c00f18c </{p=1} /^fffffff00c00f2e4 </{p=0} p' "$A" | sed -E 's/<[^>]*>//' | cut -c1-70 | sed -n 30,52p
echo '== VA and queue limits in source'
S=/mnt/e/DSH-Fuxi/unixnu-build
grep -n -E 'gDeviceInfo|va_size|va_start' "$S/fuxi/package/GpuPowerProbe.cpp" | cut -c1-170 | head -10
grep -n -E 'va_size|aperture|0x100000000|kVaEnd|vaEnd|va_end|>>32' "$S/unixnu/drivers/Adreno740/NativeAdrenoVm.h" "$S/unixnu/drivers/Adreno740/NativeAdrenoVm.cpp" 2>/dev/null | cut -c40-190 | head -10
grep -n -E '\bqueue\b.*(\[|>=|<)|\[.*queue.*\]' "$S/unixnu/drivers/Adreno740/NativeAdrenoSubmit.cpp" | cut -c1-150 | head -12
tail -2 /root/fuxi/fw/build-base.log 2>/dev/null | cut -c1-140
