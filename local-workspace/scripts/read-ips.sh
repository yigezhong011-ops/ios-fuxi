#!/bin/bash
# Read-only: list the Settings crash reports on the copied Data and print the newest ones' reason and crashing thread. Writes only under /root/fuxi/ips.
E=/mnt/e/DSH-Fuxi; A="python3 -I $E/dump/wsl/apfs-read.py $E/logs/data-raw.img"; O=/root/fuxi/ips; mkdir -p $O
sed -n 240,265p $E/dump/wsl/apfs-read.py | cut -c1-110
for d in mobile/Library/Logs/CrashReporter mobile/Library/Logs/CrashReporter/Retired; do echo "== $d"; $A ls 0 "$d" 2>&1 | grep -a -E 'Preferences|PosterBoard' | tail -12 | cut -c1-120; done
$A ls 0 mobile/Library/Logs/CrashReporter 2>&1 | grep -a -o -E 'Preferences-2026[-0-9.]*\.ips' | sort -u | tail -3 > $O/list.txt
cat $O/list.txt
while read -r n; do
  $A get 0 "mobile/Library/Logs/CrashReporter/$n" "$O/$n" 2>&1 | tail -1 | cut -c1-100
done < $O/list.txt
ls -la $O | cut -c24- | head
O=$O python3 -I - <<'PY'
import glob, json, os
for p in sorted(glob.glob(os.environ['O'] + '/Preferences-*.ips')):
    t = open(p, errors='replace').read()
    print('=====', os.path.basename(p), len(t))
    try:
        h, b = t.split('\n', 1); d = json.loads(b)
    except Exception as e:
        print('not json', e); print(t[:1500]); continue
    print('exception', d.get('exception')); print('termination', d.get('termination')); print('asi', str(d.get('asi'))[:800])
    print('lastExceptionBacktrace', bool(d.get('lastExceptionBacktrace')))
    imgs = d.get('usedImages', [])
    th = d.get('threads', [])
    ft = d.get('faultingThread', 0)
    print('faulting', ft)
    for f in th[ft].get('frames', [])[:26] if th else []:
        im = imgs[f['imageIndex']] if f.get('imageIndex', 0) < len(imgs) else {}
        print('  ', im.get('name', '?'), f.get('symbol', ''), hex(f.get('imageOffset', 0)), f.get('symbolLocation', ''))
PY
