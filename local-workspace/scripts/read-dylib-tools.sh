#!/bin/bash
# Read only: can a small dylib be built and signed here, and how the daily plugin binary is laid out in the addon.
for t in clang clang++ ld64.lld lld llvm-otool llvm-nm llvm-objdump ldid rcodesign codesign insert_dylib zsign otool ldid2 install_name_tool llvm-install-name-tool; do printf '%s: ' $t; command -v $t || echo -; done
ls /usr/bin | grep -E '^(clang|ld64|lld|llvm-otool)' | head -12
find /root/fuxi -maxdepth 3 \( -name 'ldid*' -o -name 'rcodesign*' -o -name 'iPhoneOS*.sdk' -o -name 'MacOSX*.sdk' -o -name 'libobjc*.tbd' \) 2>/dev/null | head -10
echo '== addon tree of t50-gpu7'; ls /root/fuxi/t50-gpu7 | head -30
B=$(find /root/fuxi/t50-gpu7 -type f -name 'NativeAdrenoMetal*' 2>/dev/null | head -5); echo "$B"
for s in /root/fuxi/gpu-plugin-1105/cdhashes.txt /root/fuxi/gpu-plugin-m2v/cdhashes.txt /root/fuxi/gpu-plugin-1105/trust.json; do echo "--- $s"; cut -c1-200 $s; done
tar tzf /root/fuxi/gpu-plugin-1105/gpu.tar.gz | head -20
grep -n -E 'codesign|ldid|cdhash|trust' /mnt/e/DSH-Fuxi/dump/wsl/*.sh | grep -v -E 'read-|survey' | cut -c1-140 | head -14
