#!/bin/bash
# Steps and inputs of the job saved by ci-last-failure.sh.
python3 - <<'EOF'
import json
for s in json.load(open('/root/fuxi/jobs.json'))['jobs'][0]['steps']:
    print(s['number'], s['name'], s['conclusion'], (s['started_at'] or '')[11:19], (s['completed_at'] or '')[11:19])
EOF
grep -nE 'DEFCONFIG:|STEPS:|UNIXNU_DEVICE:|repository: |ref: ' /root/fuxi/job.log | head -12 | cut -c1-200
echo "--- lines before the crash"
grep -n 'exit code 134' /root/fuxi/job.log | head -1
L=$(grep -n 'exit code 134' /root/fuxi/job.log | head -1 | cut -d: -f1)
sed -n "$((L-45)),$((L-25))p" /root/fuxi/job.log | cut -c1-200
