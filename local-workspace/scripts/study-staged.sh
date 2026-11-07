#!/bin/bash
# The staged-app copy: what the patch does and whether our kernel and Data have it; then the shared cache. Images are only read.
U=/root/fuxi/src-unixnu; K=/root/fuxi/t50-mine/kernel.macho; I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img; W=/mnt/e/DSH-Fuxi/dump/root-peek
git -C $U show --stat --format='%h %cI %s%n%b' 9c3bda1 | cut -c1-200 | head -24
F=$(git -C $U show --name-only --format= 9c3bda1 | grep -E '\.patch$' | head -1)
echo "patch: $F"
git -C $U show 9c3bda1 -- "$F" | grep -E '^\+' | cut -c2-190 | head -90
echo "== at the pin and in the board"
R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
git -C $U ls-tree -r --name-only $R | grep -i -E 'stag' | head
grep -a -n -i -E 'stag|data-seed|sheng-data' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/board.toml 2>/dev/null | cut -c1-160 | head
echo "== kernel"
strings -a $K | grep -E 'staged_system_apps|staged-system|sheng-[a-z-]*(seed|stage)[a-z-]*' | cut -c1-150 | sort -u | head
echo "== Data"
grep -a -c staged_system_apps /mnt/e/DSH-Fuxi/logs/crashes/chunk.dat
python3 - <<'EOF'
import re
b=open('/mnt/e/DSH-Fuxi/logs/crashes/chunk.dat','rb').read()
for p in (rb'staged_system_apps',rb'com\.apple\.weather',rb'com\.apple\.Health',rb'com\.apple\.mobilecal',rb'com\.apple\.reminders',rb'com\.apple\.mobilenotes'):
    print(p, len(re.findall(p,b)))
EOF
echo "== shared cache"
if [ ! -s "$W/systemos.img" ]; then dd if="$I" of="$W/systemos.img" bs=1048576 iflag=skip_bytes skip=6079643648 count=3150 status=none; fi
ls -la "$W/systemos.img" | cut -c24-100
[ -s "$W/sys-list.txt" ] || 7z l -ba "$W/systemos.img" > "$W/sys-list.txt" 2>/dev/null
wc -l "$W/sys-list.txt"
grep -E 'dyld_shared_cache' "$W/sys-list.txt" | awk '{print $4, $NF}' | cut -c1-100 | head -30
df -h /mnt/e | tail -1
