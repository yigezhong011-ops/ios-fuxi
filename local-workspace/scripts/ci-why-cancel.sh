#!/bin/bash
# Why was a run cancelled: job steps, annotations, and the timeout-minutes values in the workflow on GitHub.
# Usage: ci-why-cancel.sh <run-id>
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
API=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
H=(-H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json")
curl -s "${H[@]}" "$API/actions/runs/$1" | python3 -c 'import json,sys; r=json.load(sys.stdin); print(r["status"], r["conclusion"], r["event"], r["head_sha"][:10], r["run_started_at"], r["updated_at"])'
curl -s "${H[@]}" "$API/actions/runs/$1/jobs" > /tmp/jobs.json
python3 - <<'EOF'
import json
for j in json.load(open('/tmp/jobs.json'))['jobs']:
    print('job', j['id'], j['name'], j['conclusion'], j['started_at'], j['completed_at'], j.get('runner_name'), j.get('labels'))
    for s in j['steps']:
        print('  ', s['number'], s['conclusion'], s.get('started_at'), s.get('completed_at'), s['name'])
EOF
for id in $(python3 -c 'import json; print(" ".join(str(j["id"]) for j in json.load(open("/tmp/jobs.json"))["jobs"]))'); do
  echo "== annotations $id"
  curl -s "${H[@]}" "$API/check-runs/$id/annotations" | python3 -c 'import json,sys; [print(a["annotation_level"], a["message"][:300]) for a in json.load(sys.stdin)]'
done
echo "== timeout-minutes in workflow on GitHub"
curl -s "${H[@]}" -H "Accept: application/vnd.github.raw" "$API/contents/.github/workflows/fuxi-gpu.yml" | grep -n -E 'timeout|concurrency|cancel-in-progress'
