#!/bin/bash
# Read-only: Kerfand's fuxi repos and whether their CI built a kernel; how old's patches are ordered; UniXNU pin of old.
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' "$@"; }
echo "=== Kerfand repos"
api 'https://api.github.com/users/Kerfand/repos?per_page=100&sort=pushed' | python3 -I -c "
import json,sys
for r in json.load(sys.stdin)[:14]: print(r['pushed_at'][:16], r['name'], r['default_branch'], 'fork' if r['fork'] else '', (r['description'] or '')[:60])"
for r in Kerfand/unixnu-fuxi; do
  echo "--- $r heads"; GIT_TERMINAL_PROMPT=0 timeout 40 git ls-remote --heads https://github.com/$r.git | cut -c42- | tr '\n' ' '; echo
  echo "--- commit 36d9f09"; api https://api.github.com/repos/$r/commits/36d9f09 2>/dev/null | python3 -I -c "
import json,sys
c=json.load(sys.stdin); print(c['sha'][:10],c['commit']['committer']['date'],c['commit']['message'][:90])" || echo none
  echo "--- runs"; api "https://api.github.com/repos/$r/actions/runs?per_page=12" 2>/dev/null | python3 -I -c "
import json,sys
for x in json.load(sys.stdin)['workflow_runs']: print(x['id'],x['created_at'][:16],x['head_branch'],x['conclusion'],x['name'][:40])" || echo noruns
done
cd /root/fuxi/ref-fuxi-v2; O=origin/old
echo "=== old lock"; git show $O:unixnu.lock | cut -c1-120 | head -14
echo "=== old patches/xnu"; git ls-tree --name-only $O patches/xnu/ | sed 's#patches/xnu/##' | tr '\n' ' ' | cut -c1-1500; echo
echo "=== board patches"; git show $O:board.toml | grep -nE 'patch' | cut -c1-140 | head -10; git show $O:configs/fuxi_full_defconfig | grep -nE 'PATCH|SERIES' | cut -c1-140 | head
grep -nE "patches/xnu|\.patch|sorted\(" /root/build/unixnu/scripts/build-xnu*.py /root/build/unixnu/unixnu 2>/dev/null | cut -c1-150 | head -12
git -C /root/fuxi/up-latest grep -nE "series|patches/xnu" origin/main -- docs/xnu/source-and-patches.md 2>/dev/null | sed 's#origin/main:##' | cut -c1-200 | head -10
