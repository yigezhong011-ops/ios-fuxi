#!/bin/bash
# Has anyone fixed the fallback status bar since? Recent commits of the fuxi device repository and notes upstream. Read-only.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
curl -s "${H[@]}" 'https://api.github.com/repos/ljhhkx529/unixnu-fuxi/branches?per_page=20' | python3 -c 'import json,sys; print([b["name"] for b in json.load(sys.stdin)])'
for b in main old; do
  echo "== $b"
  curl -s "${H[@]}" "https://api.github.com/repos/ljhhkx529/unixnu-fuxi/commits?sha=$b&per_page=12" | python3 -c '
import json,sys
d=json.load(sys.stdin)
for c in d if isinstance(d,list) else []:
    print(c["sha"][:8], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:100])'
done
U=/root/fuxi/src-unixnu; git -C $U fetch -q origin
echo "== UniXNU mentions"
git -C $U log origin/main --format='%h %cI %s' -i --grep='status bar\|statusbar\|fallback item\|45025538\|canvas\|logical size\|virtual display\|scale to the panel\|1179\|2556' | cut -c1-130 | head -15
echo "== CI"; bash /root/fuxi/crst.sh 41773883659 | sed -n 1p
