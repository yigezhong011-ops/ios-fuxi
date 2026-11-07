#!/bin/bash
# Read only: the latest CI runs of the fork, with the inputs that say whether a kernel was built.
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=$(git -C /root/fuxi/unixnu-ci-push remote get-url origin | sed -E 's#.*github.com[:/]##; s#\.git$##')
echo "repo $R"
curl -s -H "Authorization: Bearer $T" "https://api.github.com/repos/$R/actions/runs?per_page=10" > /tmp/ci-runs.json
python3 -I - <<'EOF'
import json
for r in json.load(open('/tmp/ci-runs.json')).get('workflow_runs', []):
    print(r['id'], r['name'][:22], r['status'], r['conclusion'], r['created_at'], r['head_sha'][:7])
EOF
curl -s -H "Authorization: Bearer $T" "https://api.github.com/repos/$R/actions/runs?status=in_progress&per_page=5" | python3 -I -c 'import json,sys; print("in progress", json.load(sys.stdin).get("total_count"))'
curl -s -H "Authorization: Bearer $T" "https://api.github.com/repos/$R/actions/runs?status=queued&per_page=5" | python3 -I -c 'import json,sys; print("queued", json.load(sys.stdin).get("total_count"))'
pgrep -a make | cut -c1-100 | head -5; pgrep -a clang | wc -l
