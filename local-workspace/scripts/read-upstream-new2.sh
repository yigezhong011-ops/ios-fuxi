#!/bin/bash
# Read-only: the new upstream commits in ref-fuxi-v2, which branches hold them, and how they relate to what t50 and our scripts do.
d=/root/fuxi/ref-fuxi-v2; cd "$d"
echo '== branches'; git for-each-ref --format='%(refname:short) %(objectname:short) %(committerdate:format:%m-%d %H:%M)' refs/remotes | cut -c1-70
for c in 64c8c7d 2988fa8 8a8f13d a92aed5 673ce1c e3c7f01 4e39610; do
  echo "== $c on: $(git branch -r --contains $c 2>/dev/null | tr -d ' ' | tr '\n' ' ')"
  git show --stat --format='%an %ad%n%s%n%b' --date=format:'%m-%d %H:%M' $c | cut -c1-110 | head -22
done
echo '== 8a8f13d diff'; git show --format= 8a8f13d | cut -c1-110 | head -60
echo '== a92aed5 diff'; git show --format= a92aed5 | cut -c1-110 | head -40
echo '== 2988fa8 diff'; git show --format= 2988fa8 | grep -E '^[-+]' | cut -c1-110 | head -30
echo '== manual README'; T=$(git log --remotes -1 --format=%h -- patches/manual/README.md); git show $T:patches/manual/README.md | cut -c1-130 | head -24
echo '== mentions of touch, wallpaper, gpu, poster in all new commit messages'
git log --remotes --not HEAD --since=2026-11-05 --format='%h %s%n%b' | grep -i -E 'touch|wallpaper|poster|gpu|logo|hang' | cut -c1-110 | head
