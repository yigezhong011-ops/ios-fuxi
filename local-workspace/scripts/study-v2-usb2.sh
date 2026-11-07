#!/bin/bash
# Read-only: all refs named like v2, the UniXNU org's repos, and references to a v2 docs site in the local main checkout.
cd /root/fuxi/up-latest || exit 1
echo "=== refs with v2"; timeout 60 git ls-remote origin 2>/dev/null | grep -iE 'v2' | cut -c1-110 | head -20
echo "=== heads count"; timeout 60 git ls-remote --heads origin 2>/dev/null | wc -l
echo "=== org repos"
curl -fsS -A fuxi-study 'https://api.github.com/orgs/UniXNU/repos?per_page=100&sort=pushed' | python3 -I -c "
import json,sys
for r in json.load(sys.stdin): print(r['pushed_at'][:16], r['name'], r['default_branch'], (r['description'] or '')[:70])"
echo "=== docs repos: v2 refs"
for r in UniXNU/docs UniXNU/UniXNU-docs UniXNU/UniXNU.github.io; do
  echo "--- $r"; timeout 40 git ls-remote --heads https://github.com/$r.git 2>/dev/null | cut -c42-110 | head -15
done
echo "=== v2 mentions in docs config"
grep -rnIE '\bv2\b' docs/.vitepress 2>/dev/null | cut -c1-140 | head
