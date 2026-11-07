#!/bin/bash
# The build method, the store's init checks, and any public failure text in the logs. Read-only.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $S
python3 -I read-dsc-xref.py $D x 'could not setup data store' 'could not validate data store integrity' 'PBFPosterExtensionDataStore Init' 'Unable to setup extension store coordinator' 'model store coordinator could not be created' 'Unable to reach dataStore URL' 2>&1 | cut -c1-170 | tail -7
echo "== build method"
python3 -I read-dsc-xref.py $D d 0x1ca914b60 1e0 180 2>&1 | grep -E ' ; |^==|cbz|cbnz|tbz|tbnz|ret|pacibsp' | cut -c1-150
echo "== log text"
python3 -I - <<'EOF'
import re
from collections import Counter
for name, p in (('this boot', '/root/fuxi/wall1/new.txt'), ('all', '/mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt')):
    t = open(p, 'rb').read().decode('latin1')
    print('--', name)
    for pat in (r'PRBPosterExtensionDataStore[^\n]{0,120}', r'PRDataStoreErrorDomain[^\n]{0,160}', r'PBFPosterExtensionDataStoreErrorDomain[^\n]{0,160}', r'Error Domain=PR[A-Z]\w+[^\n]{0,200}', r'Error Domain=com\.apple\.PosterBoard[^\n]{0,170}', r'SQLITE|sqlite3_open[^\n]{0,100}|disk I/O error[^\n]{0,100}', r'[^\n]{0,80}com\.apple\.PosterBoard[^\n]{0,20}(?:denied|Permission|deny)[^\n]{0,120}', r'Sandbox: PosterBoard[^\n]{0,140}'):
        c = Counter(re.sub(r'[0-9A-F]{8}-[0-9A-F-]{27}|0x[0-9a-f]+|\(\d+\)', '#', x)[:210] for x in re.findall(pat, t))
        print(' ', pat[:40], sum(c.values()))
        for k, v in c.most_common(6):
            print(f'  {v:4d} {k}')
EOF
