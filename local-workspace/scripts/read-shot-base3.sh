#!/bin/bash
# Read-only: how the t50 kernel presents a GPU frame, and the values it keeps for the scanout mapping.
set -u
A=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt; K=/root/fuxi/t50/kernel.macho
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
echo '== who reads the gop globals'; grep -n -E 'c180e(08|10|18|20|28|2c)\b' "$A" | head -5
for s in _native_legacy_gop_map _native_legacy_gop_virtual _native_legacy_gop_physical _native_legacy_gop_bytes _native_legacy_gop_width _native_legacy_gop_height; do grep -E " $s$" "$N"; done
echo '== gpu present symbols'; grep -i -E 'gpu.*(present|scanout|blit|swap)|(present|scanout|blit).*gpu|dpu|scanout' "$N" | grep -v -E 'startup|MetaClass|vtable|__ZTV|__ZTS' | cut -c1-100 | head -40
echo '== validateSwap calls'; awk 'index($0,"<__ZN19NativeLegacyDisplay12validateSwapEPK25OriginalLegacySwapRequest>:"){p=1} p&&/\sbl?r?\s/{print} p&&/^$/{exit}' "$A" | cut -c1-110 | head -30
echo '== kickSwapQueue calls'; awk 'index($0,"<__ZN19NativeLegacyDisplay13kickSwapQueueEv>:"){p=1} p&&/\sbl?r?\s/{print} p&&/^$/{exit}' "$A" | grep -E '\sbl\s|blr' | cut -c1-110 | head -40
echo '== boot args of interest in wall17'; mtype -i /root/fuxi/t50-wall17/vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -a -o -E '[a-z-]*(gpu|scanout|present|legacy)[a-z-]*=[0-9a-z]+' | sort -u | tr '\n' ' '; echo
