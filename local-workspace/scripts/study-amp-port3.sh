#!/bin/bash
# Read-only: step results of CI runs, tail of the last kernel failure, V2's clean-CI display commits. Token never printed.
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt); A=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
api() { curl -fsSL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' "$@"; }
for r in 41941266963 41773883659 41747200375 41737636080 41652901111 41645221755 41608354328; do
  echo "=== run $r"
  api $A/actions/runs/$r/jobs > /tmp/j.json
  python3 -I - <<'PY'
import json
j=json.load(open('/tmp/j.json'))['jobs'][0]
print(j['id'],j['conclusion'])
for s in j['steps']:
    if s['conclusion'] in ('failure',) or 'kernel' in s['name'].lower() or 'addon' in s['name'].lower():
        print(' ',s['name'][:50],s['conclusion'],(s['started_at'] or '')[11:16],(s['completed_at'] or '')[11:16])
PY
done
echo "=== kernel artifacts"
api "$A/actions/artifacts?per_page=30" | python3 -I -c "
import json,sys
for a in json.load(sys.stdin)['artifacts']: print(a['created_at'][:16],a['name'],a['size_in_bytes']//1048576,'MiB','expired' if a['expired'] else '',a['workflow_run']['id'])"
echo "=== last kernel fail log: 41652901111"
J=$(api $A/actions/runs/41652901111/jobs | python3 -I -c "import json,sys; print(json.load(sys.stdin)['jobs'][0]['id'])")
api $A/actions/jobs/$J/logs 2>/dev/null | sed -E 's/^[0-9T:.Z-]+ //' | grep -nE 'error:|fatal error|Error [0-9]|failed|Traceback' | tail -14 | cut -c1-200
cd /root/fuxi/ref-fuxi-v2
echo "=== V2 clean-CI commits"
for c in f9c7972 738c0ec 8fb9709 72277eb; do git show --stat --format='%h %s' $c | cut -c1-110 | head -14; done
echo "=== are they in old?"
for c in f9c7972 738c0ec 72277eb; do git branch -r --contains $c | tr '\n' ' '; echo " <- $c"; done
git log origin/old --format='%s' | grep -nE 'Legacy|legacy' | head -6 | cut -c1-100
