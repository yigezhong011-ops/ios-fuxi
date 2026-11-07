#!/bin/bash
# Commits since a time across the repos that matter for fuxi (read-only). Usage: recent-commits.sh [since-ISO]
SINCE=${1:-2026-11-02T15:00:00Z}
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
for r in UniXNU/UniXNU UniXNU/AdrenoMetal UniXNU/Adreno740 UniXNU/UniXNU-sheng ljhhkx529/unixnu-fuxi ljhhkx529/uefi-fuxi UniXNU/UniXNU-pong; do
  for b in main old; do
    out=$(curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
      "https://api.github.com/repos/$r/commits?sha=$b&since=$SINCE&per_page=50" 2>/dev/null) || continue
    n=$(echo "$out" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))')
    [ "$n" = 0 ] && continue
    echo "### $r@$b ($n)"
    echo "$out" | python3 -c 'import json,sys; [print(" ", c["sha"][:9], c["commit"]["committer"]["date"][5:16], c["commit"]["message"].splitlines()[0][:110]) for c in json.load(sys.stdin)]'
  done
done
