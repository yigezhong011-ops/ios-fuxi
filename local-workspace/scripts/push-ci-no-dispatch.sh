#!/bin/bash
# Update .github/workflows/fuxi-gpu.yml in yigezhong011-ops/unixnu-ci without dispatching,
# then start a GPU-only run.
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
R=yigezhong011-ops/unixnu-ci
P=.github/workflows/fuxi-gpu.yml
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' -H 'Content-Type: application/json')

SHA=$(curl -fsSL "${H[@]}" "https://api.github.com/repos/$R/contents/$P" 2>/dev/null \
      | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])' || true)

python3 - "$SHA" <<'PY' > /root/fuxi/put2.json
import base64, json, sys
body = {'message': 'ci: install Vulkan headers for the host Turnip smoke test',
        'content': base64.b64encode(open('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml', 'rb').read()
                                    .replace(b'\r\n', b'\n')).decode(),
        'branch': 'main'}
if sys.argv[1]:
    body['sha'] = sys.argv[1]
print(json.dumps(body))
PY

echo "=== 推送 ==="
curl -fsSL -X PUT "${H[@]}" --data @/root/fuxi/put2.json \
  "https://api.github.com/repos/$R/contents/$P" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print("commit", d["commit"]["sha"][:8])' || { echo "推送失败"; exit 1; }

sleep 10
echo "=== 触发（只编插件） ==="
bash /root/fuxi/dcr.sh 793d6bddf7 false 2>&1 | tail -3
