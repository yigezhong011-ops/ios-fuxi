#!/bin/bash
# Which repository is "unixnu_fuxi", and what a force push would replace. Read-only: fetches nothing into working trees, pushes nothing.
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt)
clean() { sed -E 's#https://[^@/]*@#https://#'; }
for d in $E/unixnu-build/fuxi /root/fuxi/ref-unixnu-fuxi-bare /root/fuxi/ref-fuxi-v2 /root/fuxi/uni-oddly-fuxi /root/fuxi/fuxi-ours; do
  [ -e "$d" ] || continue
  git -C "$d" rev-parse --git-dir >/dev/null 2>&1 || { echo "== $d: not git"; continue; }
  echo "== $d"
  git -C "$d" remote -v | clean | head -4
  git -C "$d" branch -a --format='%(refname:short) %(objectname:short) %(committerdate:short)' | head -12
  git -C "$d" status -sb 2>/dev/null | head -8 | cut -c1-90
  git -C "$d" log -3 --format='%h %ad %an %s' --date=short | cut -c1-96
done
echo '--- repositories of the account with fuxi in the name'
curl -fsSL -H "Authorization: Bearer $T" 'https://api.github.com/user/repos?per_page=100&affiliation=owner,collaborator' | python3 -I -c '
import json,sys
for r in json.load(sys.stdin):
    if "fuxi" in r["full_name"].lower() or "unixnu" in r["full_name"].lower():
        print(r["full_name"], "default", r["default_branch"], "pushed", r["pushed_at"], "fork" if r["fork"] else "", "private" if r["private"] else "public", "push" if r["permissions"]["push"] else "readonly")'
