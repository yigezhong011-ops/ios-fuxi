#!/bin/bash
# Re-run the failed jobs of a run (same commit, same inputs).
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
RUN=${1:?需要 run id}
curl -fsSL -X POST \
  -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$RUN/rerun-failed-jobs" \
  | head -c 300
echo
sleep 12
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?per_page=2" \
  | python3 -c 'import json,sys
for r in json.load(sys.stdin)["workflow_runs"]:
    print(r["id"], r["status"], r["conclusion"], r["created_at"])'
