#!/bin/bash
python3 /mnt/e/DSH-Fuxi/dump/wsl/read-diag.py daily1
B=/mnt/e/DSH-Fuxi/logs/twrp-daily1.bin; O=/root/fuxi/log-daily1
rm -rf "$O"; python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -1 | cut -c1-150
L=$(ls -d $O/*/ | head -1)
grep -a -E '^\[(coherence|gpu clients|metal askers)\]|^G commit|^PR ' "$L/latest.txt" | cut -c1-240
echo "== ips"
python3 - <<'EOF'
import json
from pathlib import Path
p=Path('/root/fuxi/diag-daily1/latest.ips')
if p.exists():
    t=p.read_text(errors='replace'); parts=t.split('\n',1)
    print(parts[0][:500])
    if len(parts)>1:
        try:
            j=json.loads(parts[1])
            for k in ('procName','procPath','exception','termination','asi','faultingThread','lastExceptionBacktrace','legacyInfo'):
                if k in j: print(k, str(j[k])[:500])
            ft=j.get('faultingThread')
            th=j.get('threads') or []
            if isinstance(ft,int) and ft<len(th):
                imgs=j.get('usedImages',[])
                for f in th[ft].get('frames',[])[:16]:
                    im=imgs[f['imageIndex']] if f.get('imageIndex',-1)<len(imgs) else {}
                    print(' ',im.get('name','?'),f.get('symbol','?'),hex(f.get('imageOffset',0)))
        except Exception as e:
            print('not json',e); print(parts[1][:1500])
EOF
echo "== msgbuf: crash-ish"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -E '.{0,70}(Poster|Preferences|Wallpaper).{0,100}' | grep -a -v 'caching container' | cut -c1-170 | head -16
