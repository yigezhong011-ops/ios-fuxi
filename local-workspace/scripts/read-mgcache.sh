#!/bin/bash
# Read-only on the copied Data: what the stored MobileGestalt cache holds, then build the iPhone X image that uses the stored Data (no flash, no boot).
E=/mnt/e/DSH-Fuxi; A="python3 -I $E/dump/wsl/apfs-read.py $E/logs/data-raw.img"; O=/root/fuxi/mg; mkdir -p $O
C=containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches
$A ls 0 "$C" 2>&1 | cut -c1-110 | tail -5
$A get 0 "$C/com.apple.MobileGestalt.plist" $O/mg.plist 2>&1 | tail -1 | cut -c1-110
O=$O python3 -I - <<'PY'
import os, plistlib
p = os.environ['O'] + '/mg.plist'
if not os.path.exists(p): raise SystemExit('no cache copy')
d = plistlib.load(open(p, 'rb'))
for k, v in d.items():
    if isinstance(v, dict):
        print(k, 'dict', len(v))
        for a, b in list(v.items())[:60]:
            print('  ', a, repr(b)[:70])
    else:
        print(k, repr(v)[:90] if not isinstance(v, bytes) else f'bytes {len(v)}')
raw = d.get('CacheData', b'')
for s in (b'iPhone15,2', b'iPhone 14 Pro', b'D72', b'iPad7,1'):
    print(s, 'in CacheData', s in raw)
print('2556 as u32 in CacheData', (2556).to_bytes(4, 'little') in raw)
PY
echo '== build'
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
S=$E/dump/wsl; W=/root/fuxi/t50-ipx2
rm -rf "$W"; mkdir -p "$W"; cp /root/fuxi/t50-ipx/vol.img "$W/vol.img"
# the same ADT as t50-auto-iphonex, boot arguments back to the candidate's (stored Data)
mcopy -n -i /root/fuxi/t50-wall17/vol.img ::/EFI/UniXNU/unixnu.toml "$W/toml"
python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" >/dev/null
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 300 t50-auto-iphonex2
mtype -i /root/fuxi/auto-t50-auto-iphonex2/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o 'sheng-data-persist=[0-9]'
