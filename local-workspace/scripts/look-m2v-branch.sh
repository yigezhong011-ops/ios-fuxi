#!/bin/bash
# Public read only: UniXNU org repos and every branch and recent push, to find metal2vulkan and the docs.
A='-H Accept:application/vnd.github+json -A fuxi-read'
curl -fsS $A 'https://api.github.com/orgs/UniXNU/repos?per_page=100&sort=pushed' -o /tmp/ux-repos.json || echo 'api failed'
python3 -I - <<'P'
import json
for r in json.load(open('/tmp/ux-repos.json')):
    print(r['pushed_at'], r['name'], r['default_branch'], (r['description'] or '')[:70])
P
for r in UniXNU AdrenoMetal Adreno740 docs Docs documentation unixnu-docs UniXNU-docs website metal2vulkan Metal2Vulkan; do
  o=$(git ls-remote --heads https://github.com/UniXNU/$r.git 2>/dev/null) || { echo "== $r: none"; continue; }
  echo "== $r: $(echo "$o" | wc -l) branches"
  echo "$o" | sed 's#refs/heads/##' | cut -c1-8,41- | grep -iE 'metal|vulkan|m2v|moltenvk|gpu|adreno|main|master' | head -30
done
ls -la /root/fuxi/m2v-try 2>/dev/null | head -20
git -C /root/fuxi/m2v-try log --oneline -3 2>/dev/null
