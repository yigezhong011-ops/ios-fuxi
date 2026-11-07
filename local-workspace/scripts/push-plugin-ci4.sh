#!/bin/bash
# Fourth try: fix the list edit in the workflow, proved first against the pinned build script. Normal push; token in a header only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi
TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
a = """          last = "'" + names[-1] + "',"\n          assert t.count(last) == 1, last\n          s.write_text(t.replace(last, last + ' ' + ' '.join("'" + n + "'," for n in extra)))\n"""
b = """          last = "'" + names[-1] + "'"\n          assert t.count(last) == 1, last\n          s.write_text(t.replace(last, last + ''.join(", '" + n + "'" for n in extra)))\n"""
assert t.count(a) == 1
open(p, 'w', newline='').write(t.replace(a, b))
EOF
echo "== local proof on the pinned script"
python3 -I - <<'EOF'
import re, ast
t = open('/root/fuxi/unixnu-pin/scripts/build-adreno-metal-bridge.py').read()
names = re.findall(r"'(00[0-9]{2}-[^']+[.]patch)'", t)
extra = ['0025-specialized-links-shared-constants-and-allocation-size.patch']
last = "'" + names[-1] + "'"
assert t.count(last) == 1, last
n = t.replace(last, last + ''.join(", '" + x + "'" for x in extra))
ast.parse(n)
i = n.find(last); print(n[i - 2:i + 150].replace('\n', ' | '))
print('names now', len(re.findall(r"'(00[0-9]{2}-[^']+[.]patch)'", n)))
EOF
python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/fuxi-gpu.yml')); print('yaml ok')"
git add -A; git diff --cached --stat | tail -1 | cut -c1-90
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: the last patch name in the bridge's list has no comma after it"
git -c http.extraheader="$AUTH" push -q origin HEAD:main
curl -fsSL -X POST "${H[@]}" https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/dispatches -d '{"ref":"main","inputs":{"unixnu_ref":"793d6bddf7ea90678e3a61e2b2bd4350e5fdce16","build_kernel":"false","plugin_patch":"adrenometal-poster-7e0d3d2.patch"}}' && echo dispatched
sleep 12
curl -fsSL "${H[@]}" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/runs?per_page=1' | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])'
