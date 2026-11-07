#!/bin/bash
# Read-only: why the first auto-return image may not have come back. Does the kernel in the image really carry the argument, and where is it read?
cd /root/fuxi
echo "== kernel strings"
for f in t50/kernel.macho; do ls -la $f; grep -a -c 'sheng-autoreset' $f; done
echo "== source"
for d in /root/fuxi/up-latest /root/fuxi/uni-old /root/fuxi/unixnu-fuxi /root/fuxi/t50; do [ -d $d ] && grep -rIln 'sheng-autoreset' $d 2>/dev/null | head -5; done
F=$(grep -rIl 'sheng-autoreset' /root/fuxi/up-latest --include='*.c' --include='*.h' --include='*.cpp' --include='*.patch' 2>/dev/null | head -1); echo "file=$F"
[ -n "$F" ] && { grep -n 'autoreset' "$F" | cut -c1-140 | head; }
echo "== args in the failed image and in the next"
for n in t50-auto150 t50-auto200; do
  python3 -I - "/mnt/e/DSH-Fuxi/$n.img" <<'EOF'
import sys,struct
b=open(sys.argv[1],'rb').read(0x4000)
print(sys.argv[1][-16:], b[:8], 'hdr ver', struct.unpack_from('<I',b,40)[0])
for off in (64,1600):
    s=b[off:off+1600].split(b'\0')[0]
    if s: print(off,len(s),s[:60],b'...',s[-120:])
EOF
done
echo "== log"
grep -rl 'pro24MainFragment' /root/fuxi/wall1/log 2>/dev/null | head -3
grep -rl 'FunctionConstant' /root/fuxi/wall1/log 2>/dev/null | head -3
