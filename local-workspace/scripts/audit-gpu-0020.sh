#!/bin/bash
# Which plugin really has bridge patch 0020, and when did .clients appear upstream? Read-only for the phone and images.
R=/root/fuxi/src-adrenometal
[ -d "$R/.git" ] || git clone -q --filter=blob:none https://github.com/UniXNU/AdrenoMetal.git "$R"
cd "$R"; git fetch -q origin
PIN=7e0d3d2ebaecd736784de0baa09254b7f63bc150
git log -1 --format='pin %h %cI %s' $PIN | cut -c1-110
echo "commits on main after the pin: $(git rev-list --count $PIN..origin/HEAD)"
echo "== patches at pin"; git ls-tree --name-only $PIN bridge/patches/ | cut -d/ -f3 | cut -c1-90
P=$(git ls-tree --name-only $PIN bridge/patches/ | grep '/0020'); echo "patch: $P"
echo "== first commit with 0020"; git log --format='%h %cI %s' --diff-filter=A -- "$P" | tail -1 | cut -c1-110
echo "== first commit reading .clients (-S)"; git log --reverse --format='%h %cI %s' -S'NativeAdrenoMetal.clients' origin/HEAD | head -2 | cut -c1-110
git log --format='%h %cI %s' -S'NativeAdrenoMetal.clients' origin/HEAD | head -3 | cut -c1-110
echo "pin mentions .clients: $(git grep -c 'NativeAdrenoMetal.clients' $PIN | head -3 | tr '\n' ' ')"
git show $PIN:"$P" > /tmp/ga/0020.patch; wc -l /tmp/ga/0020.patch; sed -n 1,30p /tmp/ga/0020.patch | cut -c1-140
cd /tmp/ga
O=old/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal; N=new/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal
python3 - <<'EOF'
import re
o = open('/tmp/ga/old/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal','rb').read()
n = open('/tmp/ga/new/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal','rb').read()
p = open('/tmp/ga/0020.patch', errors='replace').read().splitlines()
add, rem = set(), set()
for l in p:
    if l.startswith('+') and not l.startswith('+++'):
        add.update(s for s in re.findall(r'"((?:[^"\\]){14,})"', l))
    if l.startswith('-') and not l.startswith('---'):
        rem.update(s for s in re.findall(r'"((?:[^"\\]){14,})"', l))
print('patch string literals: added', len(add), 'removed', len(rem))
for tag, s_ in (('ADDED', add - rem), ('REMOVED', rem - add)):
    for s in sorted(s_)[:25]:
        b = s.encode()
        print(tag, 'old' if b in o else '---', 'new' if b in n else '---', s[:90])
EOF
echo "== translator pin"; TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
curl -s -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github.raw' 'https://api.github.com/repos/UniXNU/UniXNU/contents/scripts/data/gpu-metal-vulkan-inputs.json?ref=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16' | head -c 500; echo
strings -a $O | grep -E 'metal2vulkan-[a-z]+/src' | sed -E 's#.*(crates/metal2vulkan)#\1#' | sort -u | wc -l
