#!/bin/bash
# Build auto-return images, then read-only: how the two upstream plugin fixes apply to our pin, and the CI state.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t50-auto.sh > /tmp/a.sh
bash /tmp/a.sh base 200 t50-auto200
bash /tmp/a.sh /root/fuxi/t50-mine-gpu-clock 240 t50-auto-clock
bash /tmp/a.sh /root/fuxi/t50-mine-gpu-120 240 t50-auto-120
bash /tmp/a.sh /root/fuxi/t50-mine-gpu-120clock 300 t50-auto-120clock
R=/root/fuxi/src-adrenometal; cd $R
git status -s | head -5; git log -1 --format='%h %s' | cut -c1-80
git cat-file -e 7e0d3d2 && echo has-7e0d3d2
for c in 8c1ea13 5a50581 722b9c1; do git log -1 --format='%h %ad %s' --date=short $c | cut -c1-120; git show --stat --format= $c | tail -6 | cut -c1-90; done
W=/root/fuxi/plugin-try; rm -rf $W; git worktree prune; git worktree add -q --detach $W 7e0d3d2 && cd $W
for c in 722b9c1 8c1ea13 5a50581; do
  if git -c user.name=x -c user.email=x@x cherry-pick -x $c >/dev/null 2>&1; then echo "$c applied"; else echo "$c conflicts:"; git diff --name-only --diff-filter=U | head; git diff --stat | tail -1; git diff | grep -c '^[ +-]*<<<<<<<'; git cherry-pick --abort; fi
done
git log --oneline -4 | cut -c1-90
echo "== ci"; TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt); curl -fsSL -H "Authorization: Bearer $TOKEN" "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?per_page=6" | python3 -I -c "
import json,sys
for r in json.load(sys.stdin)['workflow_runs']: print(r['id'], r['name'][:20], r['status'], r['conclusion'], r['created_at'], r['updated_at'][11:19], r['head_sha'][:7])"
grep -n -E 'unixnu_ref|adrenometal|AdrenoMetal|plugin_ref|sed -i|pin' /root/fuxi/ci/macos.yml | cut -c1-130 | head -16
