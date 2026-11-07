#!/bin/bash
# Overnight: dispatch the plugin-only GPU CI (UniXNU 793d6bddf7). A run that no runner picked up (cancelled with no
# steps) is dispatched again, up to 5 tries. On success build t50-mine-gpu-fix.img and t36-bl2-gpu-fix.img.
# Nothing is flashed. Log: /root/fuxi/overnight-gpu.log
exec >>/root/fuxi/overnight-gpu.log 2>&1
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
API=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
for try in 1 2 3 4 5; do
  echo "=== $(date) try $try"
  RUN=$(bash /root/fuxi/dcr.sh 793d6bddf7 false | awk '/^[0-9]+ /{print $1}')
  echo "run $RUN"
  [ -n "$RUN" ] || { sleep 300; continue; }
  bash /mnt/e/DSH-Fuxi/dump/wsl/ci-wait.sh "$RUN"
  C=$(curl -fsSL -H "Authorization: Bearer $TOKEN" "$API/actions/runs/$RUN/jobs" | python3 -c '
import json,sys
j=json.load(sys.stdin)["jobs"][0]
print(j["conclusion"], len([s for s in j["steps"] if s["conclusion"] not in (None,"skipped")]))')
  echo "result: $C"
  case "$C" in
    success*) bash /mnt/e/DSH-Fuxi/dump/wsl/install-gpu-addon.sh "$RUN" t50-mine; echo "t50 exit $?"
              bash /mnt/e/DSH-Fuxi/dump/wsl/install-gpu-addon.sh "$RUN" t36-bl2; echo "t36 exit $?"
              ls -l /mnt/e/DSH-Fuxi/*-gpu-fix.img; echo "=== done"; exit 0;;
    "cancelled 0") echo "no runner, retry in 10 min"; sleep 600;;
    *) echo "real failure, stop"; bash /root/fuxi/cfe.sh "$RUN" | tail -40; exit 1;;
  esac
done
echo "=== gave up after 5 tries"
