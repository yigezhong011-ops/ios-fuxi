#!/bin/bash
# Exact branch after the database init, the database's own init, and SQLite complaints in the logs. Read-only.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $S
echo "== call and branch"
python3 -I read-dsc-xref.py $D d 0x1ca835098 44 24 0x1ca835218 0 90 2>&1 | cut -c1-120 | grep -v '^{'
python3 -I read-dsc-xref.py $D x 'com.apple.posterboard.PBFPosterExtensionDataStoreSQLiteDatabase' 2>&1 | tail -1 | cut -c1-150
Q=$(python3 -I read-dsc-xref.py $D x 'com.apple.posterboard.PBFPosterExtensionDataStoreSQLiteDatabase' 2>&1 | tail -1 | grep -o -E "xrefs \['0x[0-9a-f]+" | grep -o -E '0x[0-9a-f]+')
echo "== database init near $Q"
[ -n "$Q" ] && python3 -I read-dsc-xref.py $D d "$Q" 120 500 2>&1 | grep -E ' ; |^==|cbz|cbnz|tbz|tbnz|ret|pacibsp' | cut -c1-150
echo "== strings: database"
python3 -I - <<'EOF'
import re
for p, title in (('/root/fuxi/wall1/new.txt', 'this boot'), ('/mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt', 'all')):
    t = open(p, 'rb').read().decode('latin1')
    print('--', title)
    from collections import Counter
    for pat in (r'unable to open[^\n]{0,140}', r'cannot open file[^\n]{0,140}', r'os_unix\.c[^\n]{0,140}', r'SQLITE_[A-Z_]+[^\n]{0,100}', r'[^\n]{0,60}PosterBoard[^\n]{0,60}\.sqlite[^\n]{0,80}', r'[^\n]{0,100}PRBPoster[^\n]{0,100}', r'[^\n]{0,40}Containers/Data/Application/353FB615[^\n]{0,130}', r'[^\n]{0,70}(?:EPERM|Operation not permitted|Permission denied)[^\n]{0,70}'):
        c = Counter(re.sub(r'0x[0-9a-f]+', '#', x)[:220] for x in re.findall(pat, t))
        print(' ', pat[:30], sum(c.values()))
        for k, v in c.most_common(7):
            print(f'  {v:5d} {k}')
EOF
