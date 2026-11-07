#!/bin/bash
# Is the os_log export reachable with our image? Read-only.
A=/root/fuxi/src-adrenometal; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150; U=/root/fuxi/src-unixnu
echo "== zh doc mentions"
git -C $U show origin/main:docs/zh/porting/gpu-diagnostics.md > /root/fuxi/gpu-diag.md
wc -l /root/fuxi/gpu-diag.md
grep -n -E 'oslog|os_log|系统日志|sheng-diag-export|zz-|导出|PosterBoard|WidgetRenderer|Poster' /root/fuxi/gpu-diag.md | cut -c1-260 | head -24
echo "== CacheExport.h"
git -C $A show $P:CacheExport.h | sed -n 1,30p | cut -c1-210
git -C $A show $P:CacheExport.h | grep -n -E 'getenv|boot-args|sysctl|sheng-|argument|kern\.' | cut -c1-180 | head
echo "== probe daemon"
git -C $A show $P:NativeAdrenoProbeDaemon.cpp | sed -n 1,32p | cut -c1-200
echo "== what the current addon carries"
I=/mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img
grep -n -E 'addon|mdir|mcopy' /mnt/e/DSH-Fuxi/dump/wsl/verify-gpu-image.sh | cut -c1-170 | head -12
echo "== sheng args in kernel and in this boot"
L=$(ls -d /root/fuxi/log-gpu3/*/ | head -1)
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -E 'sheng-[a-z-]+=[0-9a-z,_-]+' | sort -u | tr '\n' ' ' | cut -c1-900; echo
cat "$L/header.txt" | cut -c1-300 | head -8
echo "== non-slot data in the log window"
python3 - <<'EOF'
import glob,re
b=open(glob.glob('/root/fuxi/log-gpu3/*/log.bin')[0],'rb').read()
print('log.bin',len(b))
for k in (b'zz-oslog',b'oslog.txt',b'# sheng oslog',b'\x1f\x8b\x08'):
    print(k, b.count(k), b.find(k))
EOF
python3 - <<'EOF'
b=open('/mnt/e/DSH-Fuxi/logs/twrp-gpu3.bin','rb').read()
for k in (b'zz-oslog',b'oslog.txt',b'\x1f\x8b\x08'):
    print('window',k,b.count(k),b.find(k))
EOF
