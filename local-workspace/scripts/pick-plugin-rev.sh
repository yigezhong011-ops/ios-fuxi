#!/bin/bash
# For a plugin-only build that matches the t36 kernel (built 2026-10-31 12:22 CST = 04:22 UTC): AdrenoMetal commits around then
# (is the host-page texture fix 0020 in?), and the UniXNU commits whose pins could be used.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
echo "### AdrenoMetal 10-30 .. 10-31 12:00Z"
api 'UniXNU/AdrenoMetal/commits?since=2026-10-30T00:00:00Z&until=2026-10-31T12:00:00Z&per_page=60' | python3 -c '
import json, sys
for c in json.load(sys.stdin):
    print(" ", c["sha"][:10], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:90])'
echo "### Adreno740 10-30 .. 10-31 12:00Z"
api 'UniXNU/Adreno740/commits?since=2026-10-30T00:00:00Z&until=2026-10-31T12:00:00Z&per_page=60' | python3 -c '
import json, sys
for c in json.load(sys.stdin):
    print(" ", c["sha"][:10], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:90])'
echo "### UniXNU 10-30 .. 10-31 12:00Z"
api 'UniXNU/UniXNU/commits?sha=main&since=2026-10-30T12:00:00Z&until=2026-10-31T12:00:00Z&per_page=60' | python3 -c '
import json, sys
for c in json.load(sys.stdin):
    print(" ", c["sha"][:10], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:90])'
