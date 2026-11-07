#!/bin/bash
# Why did the last macOS build runs of yigezhong011-ops/unixnu-ci fail: inputs, failed steps, tail of the failed job log.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
R=yigezhong011-ops/unixnu-ci
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$R/$1"; }
api 'actions/workflows/macos.yml/runs?per_page=4' > /root/fuxi/runs.json
python3 - <<'EOF'
import json
for r in json.load(open('/root/fuxi/runs.json'))['workflow_runs']:
    print(r['id'], r['created_at'][:16], r['conclusion'], r['head_sha'][:9], r['display_title'][:80])
EOF
for id in $(python3 -c 'import json; [print(r["id"]) for r in json.load(open("/root/fuxi/runs.json"))["workflow_runs"][:2]]'); do
  echo "########## run $id"
  api "actions/runs/$id/jobs" > /root/fuxi/jobs.json
  python3 - <<'EOF'
import json
for j in json.load(open('/root/fuxi/jobs.json'))['jobs']:
    print('job', j['id'], j['conclusion'])
    for s in j['steps']:
        if s['conclusion'] not in ('success', 'skipped'):
            print('   step', s['number'], s['name'], s['conclusion'])
open('/root/fuxi/jobid', 'w').write(str(json.load(open('/root/fuxi/jobs.json'))['jobs'][0]['id']))
EOF
  curl -fsSL -H "Authorization: Bearer $TOKEN" "https://api.github.com/repos/$R/actions/jobs/$(cat /root/fuxi/jobid)/logs" -o /root/fuxi/job.log
  grep -nE '##\[error\]|Error|error:|Traceback|FAIL' /root/fuxi/job.log | grep -v 'Werror' | tail -15 | cut -c1-260
done
echo "### ci repo head vs upstream"
api 'commits?per_page=1' | python3 -c 'import json,sys; c=json.load(sys.stdin)[0]; print(c["sha"][:9], c["commit"]["committer"]["date"], c["commit"]["message"].splitlines()[0])'
