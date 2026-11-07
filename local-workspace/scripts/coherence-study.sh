#!/bin/bash
python3 /mnt/e/DSH-Fuxi/dump/wsl/coherence-study.py
U=/root/fuxi/src-unixnu; K=/root/fuxi/t50-mine/kernel.macho
echo "===== kernel strings"
strings -a $K | grep -i -E 'coherence|coherent|sheng-[a-z-]*(coher|cache|snoop)[a-z-]*' | cut -c1-170 | sort -u | head -30
echo "===== UniXNU commits"
git -C $U log origin/main --format='%h %cI %s' -i --grep='coheren\|snoop\|cache maint\|dcache\|io-coher' | cut -c1-130 | head -25
echo "===== local docs"
grep -r -l -i -E 'coherence' /mnt/e/DSH-Fuxi/*.md /mnt/e/DSH-Fuxi/docs 2>/dev/null | head
echo "===== same kernel in both images?"
cat /root/fuxi/install-gpu-t50-mine.log 2>/dev/null | tail -5 | cut -c1-160
cd /mnt/e/DSH-Fuxi
for f in t50-mine-gpu-fix1.img t50-mine-gpu-fix.img t50-mine.img; do python3 - "$f" <<'EOF'
import sys,hashlib,struct
d=open(sys.argv[1],'rb').read()
ks,rs=struct.unpack('<II',d[8:12]+d[16:20])
print(sys.argv[1],len(d),'kernel',ks,hashlib.sha256(d[4096:4096+ks]).hexdigest()[:16],'ramdisk',rs,hashlib.sha256(d[4096+((ks+4095)//4096)*4096:][:rs]).hexdigest()[:16])
EOF
done
