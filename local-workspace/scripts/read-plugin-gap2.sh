#!/bin/bash
# Upstream plugin and driver commits since our pins. Fetch only.
cd /root/fuxi
cat gpu-plugin-1105/revisions.txt; echo
for r in src-adrenometal src-adreno740; do
  timeout 60 git -C $r fetch -q origin 2>&1 | tail -1
  B=$(git -C $r symbolic-ref -q --short refs/remotes/origin/HEAD || echo origin/main)
  echo "== $r $B $(git -C $r log -1 --format='%h %ad' --date=short $B); commits since 2026-11-04: $(git -C $r rev-list --count --since=2026-11-04 $B)"
  git -C $r log --since=2026-11-04 --date=short --format='%h %ad %s' $B | cut -c1-100 | head -45
done
