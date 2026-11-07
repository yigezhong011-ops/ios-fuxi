#!/bin/bash
# Audit both GPU fix images, the CI run and how the addon's entries get consumed. Read-only.
cd /mnt/e/DSH-Fuxi/dump/wsl
ls -la /mnt/e/DSH-Fuxi/*-gpu-fix.img
bash /root/fuxi/crst.sh 41747200375 | cut -c1-110
for b in t50-mine t36-bl2; do python3 audit-gpu-fix.py $b; done
echo "== who parses the addon"
grep -rlE 'NGPUADD2' /root/fuxi/unixnu-build 2>/dev/null --include='*.py' --include='*.c' --include='*.h' --include='*.cpp' --include='*.mm' --include='*.md' | head -20
echo "== NGPUADD2 in kernels"
for k in /root/fuxi/t50-mine/kernel.macho /root/fuxi/t36-bl2/kernel.macho; do [ -f $k ] && echo "$k $(grep -c -a NGPUADD2 $k)"; done
mtype -i /root/fuxi/t50-mine/vol.img ::/EFI/UniXNU/ | head -20
mtype -i /root/fuxi/t50-mine/vol.img ::/EFI/UniXNU/Payloads/ 2>/dev/null | head -2
mdir -i /root/fuxi/t50-mine/vol.img ::/EFI/UniXNU 2>/dev/null | head -20
mdir -i /root/fuxi/t50-mine/vol.img ::/EFI/UniXNU/Payloads 2>/dev/null | head -30
