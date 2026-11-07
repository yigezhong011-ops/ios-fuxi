#!/bin/bash
# Read-only look at the V2 branch of ljhhkx529/unixnu-fuxi in a bare clone under /root/fuxi. Changes no working tree.
set -u
R=/root/fuxi/ref-unixnu-fuxi-bare
if [ -d "$R" ]; then git -C "$R" fetch -q origin '+refs/heads/*:refs/heads/*'; else git clone -q --bare https://github.com/ljhhkx529/unixnu-fuxi.git "$R"; fi
cd "$R" || exit 1
git for-each-ref --format='%(refname:short) %(objectname:short) %(committerdate:short) %(subject)' refs/heads | cut -c1-120
for b in V2 v2; do git rev-parse -q --verify "refs/heads/$b" >/dev/null && V=$b; done
echo "using ${V:-none}"; [ -n "${V:-}" ] || exit 2
echo '== log'; git log -25 --format='%h %ad %s' --date=short "$V" | cut -c1-130
echo '== merge base with old'; git merge-base "$V" old 2>/dev/null
echo '== diff stat old..V2'; git diff --stat old "$V" 2>/dev/null | tail -60
echo '== tree'; git ls-tree -r --name-only "$V" | head -120
echo '== README'; git show "$V:README.md" 2>/dev/null | head -80
echo '== keyword files'; git grep -l -i -E 'status.?bar|canvas|logical|display-scale|unit-scale|phone_identity|patch' "$V" 2>/dev/null | head -40
