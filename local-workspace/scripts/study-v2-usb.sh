#!/bin/bash
# Read-only on the working trees: find a v2 branch in the local UniXNU clones' remotes and list its USB docs.
cd /root/fuxi || exit 1
for t in unixnu unixnu-pin up-latest uni-star star-unixnu src-unixnu; do
  [ -d "$t/.git" ] || continue
  for r in $(git -C "$t" remote); do
    echo "=== $t remote $r $(git -C "$t" remote get-url "$r" | sed -E 's#//[^/@]*@#//#')"
    timeout 60 git -C "$t" ls-remote --heads "$r" 2>/dev/null | grep -iE 'refs/heads/.*v2|refs/heads/main$|docs' | cut -c1-110 | head -12
  done
done
