#!/bin/bash
# Second try: the plugin patch now also carries translator patch 0025, and the workflow adds it to the build script's list. Normal push; token in a header only.
set -uo pipefail
E=/mnt/e/DSH-Fuxi
cd /root/fuxi/plugin-try
A=/root/fuxi/src-adrenometal; N=0025-specialized-links-shared-constants-and-allocation-size.patch
git log -1 --format='%h %s' | cut -c1-70
if [ ! -f bridge/patches/$N ]; then
  git -C $A show de4c1ee:bridge/patches/$N > bridge/patches/$N
  git add bridge/patches/$N
  git -c user.name=fuxi -c user.email=fuxi@example.invalid commit -q -m "bridge: translator patch 0025 from de4c1ee"
fi
git diff 7e0d3d2 HEAD > /root/fuxi/plugin-poster.patch; wc -l /root/fuxi/plugin-poster.patch
echo "== every nmb_ the frontend calls is declared and defined"
grep -o -h -E '\bnmb_[a-z0-9_]+' NativeBridgeMetalFrontend.mm | sort -u > /tmp/used
grep -o -h -E '\bnmb_[a-z0-9_]+' bridge/NativeMetalObjects.h bridge/*.h 2>/dev/null | sort -u > /tmp/decl
grep -o -h -E 'fn nmb_[a-z0-9_]+' bridge/*.rs | sed 's/fn //' | sort -u > /tmp/def
wc -l < /tmp/used; echo "used not declared: $(comm -23 /tmp/used /tmp/decl | tr '\n' ' ')"; echo "used not defined: $(comm -23 /tmp/used /tmp/def | tr '\n' ' ')"
echo "== new names in the frontend diff that nothing at the pin defines"
git diff 7e0d3d2 HEAD -- NativeBridgeMetalFrontend.mm CacheExport.h | grep -E '^\+' | grep -o -E '\b[a-zA-Z_][a-zA-Z0-9_]{5,}\(' | tr -d '(' | sort -u > /tmp/calls
for s in $(cat /tmp/calls); do n=$(git grep -c -w -- "$s" HEAD -- '*.mm' '*.h' '*.m' | awk -F: '{s+=$NF} END {print s+0}'); [ "$n" -le 1 ] && echo "  once only: $s"; done | head -20
set -e
python3 -I - <<EOF
t = open('/root/fuxi/unixnu-pin/scripts/build-adreno-metal-bridge.py').read()
import re
names = re.findall(r"'(00[0-9]{2}-[^']+\.patch)'", t)
print('list', len(names), names[-1])
EOF
TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
cp /root/fuxi/plugin-poster.patch ci/patches/adrenometal-poster-7e0d3d2.patch
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
old = "        run: git -C UniXNU/drivers/AdrenoMetal apply --whitespace=nowarn \"$GITHUB_WORKSPACE/ci-self/ci/patches/${{ inputs.plugin_patch }}\"\n"
assert t.count(old) == 1
new = "        run: |\n          git -C UniXNU/drivers/AdrenoMetal apply --whitespace=nowarn \"$GITHUB_WORKSPACE/ci-self/ci/patches/${{ inputs.plugin_patch }}\"\n          # Translator patches the plugin patch added go on the end of the bridge's recorded list.\n          python3 - <<'PY'\n          import pathlib, re\n          s = pathlib.Path('UniXNU/scripts/build-adreno-metal-bridge.py')\n          t = s.read_text()\n          names = re.findall(r\"'(00[0-9]{2}-[^']+[.]patch)'\", t)\n          have = sorted(p.name for p in pathlib.Path('UniXNU/drivers/AdrenoMetal/bridge/patches').glob('00*.patch'))\n          extra = [n for n in have if n not in names]\n          assert extra, 'no new translator patch'\n          last = \"'\" + names[-1] + \"',\"\n          assert t.count(last) == 1, last\n          s.write_text(t.replace(last, last + ' ' + ' '.join(\"'\" + n + \"',\" for n in extra)))\n          print('added', extra)\n          PY\n"
t = t.replace(old, new)
open(p, 'w', newline='').write(t)
EOF
if grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' ci/patches/adrenometal-poster-7e0d3d2.patch .github/workflows/fuxi-gpu.yml; then echo secret; exit 1; fi
sed -n '/name: plugin patch/,/name: GPU addon/p' .github/workflows/fuxi-gpu.yml | cut -c1-100 | head -24
python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/fuxi-gpu.yml')); print('yaml ok')" 2>&1 | tail -1
git add -A; git diff --cached --stat | tail -3 | cut -c1-90
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: plugin patch carries translator patch 0025

8c1ea13 calls two translator methods that upstream added in de4c1ee's 0025. 0025 applies on our 0001-0020 without 0021-0024."
git -c http.extraheader="$AUTH" push -q origin HEAD:main
git log --oneline -1 | cut -c1-80
curl -fsSL -X POST "${H[@]}" https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/dispatches -d '{"ref":"main","inputs":{"unixnu_ref":"793d6bddf7ea90678e3a61e2b2bd4350e5fdce16","build_kernel":"false","plugin_patch":"adrenometal-poster-7e0d3d2.patch"}}' && echo dispatched
sleep 10
curl -fsSL "${H[@]}" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/runs?per_page=1' | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])'
