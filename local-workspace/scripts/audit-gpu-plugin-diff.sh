#!/bin/bash
# Compare the resident plugin and the CI plugin, and read the pinned upstream sources. Read-only.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
H=(-H "Authorization: Bearer $TOKEN")
cd /tmp/ga
O=old/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal; N=new/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal
strings -a -n 8 $O | sort -u > o.txt; strings -a -n 8 $N | sort -u > n.txt
echo "== counts old $(wc -l < o.txt) new $(wc -l < n.txt) only-old $(comm -23 o.txt n.txt | wc -l) only-new $(comm -13 o.txt n.txt | wc -l)"
echo "== only old (source paths, tagged, words)"; comm -23 o.txt n.txt | grep -E '^[A-Za-z].* .* |\.rs|\.c$|clients|prime|linear|buffer|texture' | grep -v -E '_ZN|^_|\$' | cut -c1-150 | head -70
echo "== only new"; comm -13 o.txt n.txt | grep -E '^[A-Za-z].* .* |\.rs|\.c$|clients|prime|linear|buffer|texture' | grep -v -E '_ZN|^_|\$' | cut -c1-150 | head -50
echo "== around clients in old"; grep -n -E 'clients|client ' o.txt | cut -c1-150 | head -30
echo "== client words in new"; grep -n -E 'clients|client |backboardd|SpringBoard|WidgetRenderer|mediaserverd' n.txt | cut -c1-150 | head -30
echo "== old also"; grep -n -E 'backboardd|SpringBoard|WidgetRenderer|mediaserverd' o.txt | cut -c1-150 | head
echo "== build ids"; for f in o.txt n.txt; do grep -E 'rustc [0-9]|clang version|^[0-9a-f]{40}$|Mesa [0-9]' $f | cut -c1-120 | head -8; done
python3 - "$TOKEN" <<'EOF'
import json, sys, urllib.request
tok = sys.argv[1]
def get(path, raw=False):
    r = urllib.request.Request('https://api.github.com' + path, headers={'Authorization': 'Bearer ' + tok, 'Accept': 'application/vnd.github.raw' if raw else 'application/vnd.github+json'})
    try:
        d = urllib.request.urlopen(r, timeout=40).read()
    except Exception as e:
        return None if raw else {'error': str(e)}
    return d.decode('utf-8', 'replace') if raw else json.loads(d)
U = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
src = get(f'/repos/UniXNU/UniXNU/contents/scripts/make-gpu-addon.py?ref={U}', True)
print('== make-gpu-addon.py at 793d lines mentioning clients/prime')
for i, l in enumerate((src or '').splitlines(), 1):
    if any(w in l.lower() for w in ('client', 'prime')):
        print(i, l[:150])
m = get(f'/repos/UniXNU/UniXNU/contents/.gitmodules?ref={U}', True) or ''
print('\n'.join(l.strip() for l in m.splitlines() if 'AdrenoMetal' in l))
EOF
