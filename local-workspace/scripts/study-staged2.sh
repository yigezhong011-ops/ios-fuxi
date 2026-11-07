#!/bin/bash
# Is sheng-staged-apps on? How big is the copy? What installs the apps afterwards? And the wallpaper assertion. Read-only.
U=/root/fuxi/src-unixnu; W=/mnt/e/DSH-Fuxi/dump/root-peek
echo "== how the args are edited"
grep -n -E 'cmdline|sheng-|kernel-arg|bootargs|boot-args' /mnt/e/DSH-Fuxi/dump/wsl/make-t50-gpu-bgra.sh | cut -c1-170 | head -14
echo "== args of the daily image"
python3 - <<'EOF'
import struct,zlib,re
d=open('/mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img','rb').read()
ks=struct.unpack_from('<I',d,8)[0]; hs=struct.unpack_from('<I',d,20)[0]; st=(hs+4095)//4096*4096
body=zlib.decompressobj(16+zlib.MAX_WBITS).decompress(d[st:st+ks])
seen=set()
for m in re.finditer(rb'[ -~]{0,900}sheng-vsync=[ -~]{0,900}',body):
    t=m[0].decode()
    if t not in seen:
        seen.add(t); print(len(t),t[:1100])
EOF
echo "== size of the copy"
grep -E ' private/var/staged_system_apps/' "$W/list.txt" | awk '{s+=$4;n++} END {print n" entries", s/1048576" MiB uncompressed"}'
echo "== rest of the patch"
git -C $U show 793d6bddf7ea90678e3a61e2b2bd4350e5fdce16:patches/xnu/zzy-staged-system-apps.patch | grep -n -E 'migrat|Migrat|marker|data-reset|sheng-|panic|stage = |native_staged_apps_stage' | cut -c1-180 | head -30
echo "== docs"
git -C $U grep -n -E 'sheng-staged-apps|SystemAppMigrator|data migration|staged' origin/main -- docs/zh | sed 's/^origin.main://' | cut -c1-260 | head -14
git -C $U grep -n -E 'staged.apps|staged_apps' origin/main -- scripts/unixnu scripts/*.py | sed 's/^origin.main://' | cut -c1-190 | head -14
echo "== the log row"
L=$(ls -d /root/fuxi/log-daily1/*/ | head -1)
grep -a -i -E 'staged|^.*native_staged' "$L/latest.txt" | cut -c1-160 | head -5
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -i -E '.{0,70}(staged|SystemAppMigrator|DataMigrat|migration).{0,110}' | cut -c1-190 | sort -u | head -14
echo "== wallpaper assertion strings in SystemOS"
grep -a -b -o -F -e PBFModalRootViewController -e 'PosterBoard/PBFModal' "$W/systemos.img" | cut -c1-80 | head -14
grep -E 'PosterBoardUI|dyld_shared_cache_arm64$' "$W/sys-list.txt" | awk '{print $4, $NF}' | cut -c1-100 | head -5
