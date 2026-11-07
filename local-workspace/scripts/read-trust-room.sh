#!/bin/bash
# Read only: trust cache size against its FAT clusters, its modules, what reads it, and whether adrenoprobed matters.
export MTOOLS_SKIP_CHECK=1
W=/root/fuxi/plug-t50-auto-sb; cd $W
mdir -i vol.img ::/EFI/UniXNU/Payloads | cut -c1-70
minfo -i vol.img :: | grep -E 'sector size|cluster size|sectors per cluster' | head -4
python3 -I - trust-cur.bin <<'EOF'
import struct, sys
d = open(sys.argv[1], 'rb').read(); n = struct.unpack_from('<I', d)[0]; st = struct.unpack_from('<%dI' % n, d, 4)
print('bytes', len(d), 'modules', n, 'starts', st)
for i, s in enumerate(st):
    e = st[i + 1] if i + 1 < n else len(d)
    print(i, 'version', struct.unpack_from('<I', d, s)[0], 'entries', struct.unpack_from('<I', d, s + 20)[0], 'len', e - s)
EOF
grep -n -iE 'trustcache|trust_cache' $(ls /root/fuxi/ref-fuxi-v2/scripts/*.py 2>/dev/null | head -20) 2>/dev/null | cut -c1-150 | head -12
git -C /root/fuxi/ref-fuxi-v2 grep -n -iE 'trustcache|trust.cache' HEAD -- '*.c' '*.h' '*.toml' 2>/dev/null | sed 's#^HEAD:##' | cut -c1-170 | head -16
echo '== adrenoprobed'
cat /root/fuxi/up-latest/drivers/AdrenoMetal/AGENTS.md 2>/dev/null | grep -n -i 'probe' | cut -c1-200 | head -6
git -C /root/fuxi/src-adrenometal grep -n -E 'adrenoprobed|AdrenoProbe|org.blu-sharky.adrenoprobed' ce63701 -- '*.mm' '*.h' '*.md' | cut -c1-190 | head -12
