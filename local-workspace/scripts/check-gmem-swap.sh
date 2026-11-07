#!/bin/bash
# Which boot wrote the pulled log, and is the GMEM colour-swap Mesa patch in the pinned build? Read-only.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
cd /tmp/ga
echo "== log text present in which plugin"
python3 - <<'EOF'
o = open('old/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal','rb').read()
n = open('new/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal','rb').read()
for s in (b'no device answer', b'supportsConditionalLoadStore', b'rows of', b'makes no linear', b'BinaryArchive', b'sheng-fb-bgra'):
    print(' ', s, 'old', o.count(s), 'new', n.count(s))
EOF
D=$(ls -d /root/fuxi/log-bgra/*/ | head -1)
grep -a -n -m5 -E 'NativeAdrenoMetal|plugin|build' "$D/slots.txt" | cut -c1-160
python3 - <<'EOF'
import json, urllib.request, sys, subprocess
tok = open('/mnt/e/DSH-Fuxi/token2.txt').read().strip()
def raw(path):
    r = urllib.request.Request('https://api.github.com/repos/UniXNU/UniXNU/' + path, headers={'Authorization': 'Bearer ' + tok, 'Accept': 'application/vnd.github.raw'})
    try:
        return urllib.request.urlopen(r, timeout=40).read().decode('utf-8', 'replace')
    except Exception as e:
        return 'ERR %s' % e
for tag, ref in (('793d', '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'), ('main', 'main')):
    pins = json.loads(raw(f'contents/scripts/data/adreno-compiler-inputs.json?ref={ref}'))
    print(tag, 'mesa', pins['mesa'].get('commit', '')[:12], 'patches:')
    for p in pins.get('patches', []):
        print('   ', p)
    print('  has gmem-swap patch file:', not raw(f'contents/patches/mesa/turnip-gmem-mutable-swap.patch?ref={ref}').startswith('ERR'))
EOF
echo "== where the patch lives upstream"
curl -s -H "Authorization: Bearer $TOKEN" 'https://api.github.com/repos/UniXNU/UniXNU/commits?path=patches/mesa/turnip-gmem-mutable-swap.patch&per_page=5' | python3 -c 'import json,sys; [print(c["sha"][:10], c["commit"]["committer"]["date"], c["commit"]["message"].splitlines()[0][:90]) for c in json.load(sys.stdin)]'
curl -s -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github.raw' 'https://api.github.com/repos/UniXNU/UniXNU/contents/patches/mesa/turnip-gmem-mutable-swap.patch' | sed -n 1,60p | cut -c1-140
cd /root/fuxi/src-adrenometal; PIN=7e0d3d2ebaecd736784de0baa09254b7f63bc150
echo "== mentions at pin"; git grep -n -i -E 'gmem.*swap|mutable-swap' $PIN | sed "s/^$PIN://" | cut -c1-170 | head
