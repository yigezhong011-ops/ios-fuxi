#!/bin/bash
# Add/update .github/workflows/fuxi-gpu.yml in yigezhong011-ops/unixnu-ci (a normal commit, no force) and dispatch it.
set -euo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
R=yigezhong011-ops/unixnu-ci
P=.github/workflows/fuxi-gpu.yml
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
SHA=$(curl -fsSL "${H[@]}" "https://api.github.com/repos/$R/contents/$P" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])' || true)
python3 - "$SHA" > /root/fuxi/put.json <<'EOF'
import base64, json, sys
body = {'message': 'ci: build the fuxi kernel and GPU addon from one UniXNU revision (encrypted outputs)',
        'content': base64.b64encode(open('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml', 'rb').read().replace(b'\r\n', b'\n')).decode()}
if sys.argv[1]:
    body['sha'] = sys.argv[1]
print(json.dumps(body))
EOF
curl -fsSL -X PUT "${H[@]}" "https://api.github.com/repos/$R/contents/$P" -d @/root/fuxi/put.json | python3 -c 'import json,sys; print("commit", json.load(sys.stdin)["commit"]["sha"][:9])'
sleep 5
curl -fsSL -X POST "${H[@]}" "https://api.github.com/repos/$R/actions/workflows/fuxi-gpu.yml/dispatches" -d '{"ref":"main"}' && echo dispatched
sleep 10
curl -fsSL "${H[@]}" "https://api.github.com/repos/$R/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["html_url"])'
