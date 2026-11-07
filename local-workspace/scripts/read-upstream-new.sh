#!/bin/bash
# Fetches the reference clones (remote-tracking refs only) and lists commits and doc files newer than what is checked out.
for d in /root/fuxi/ref-* /mnt/e/DSH-Fuxi/unixnu-build/unixnu /mnt/e/DSH-Fuxi/unixnu-build/fuxi /root/fuxi/ios-fuxi; do
  [ -e "$d/.git" ] || continue
  git config --global --add safe.directory "$d" 2>/dev/null
  url=$(git -C "$d" remote get-url origin 2>/dev/null | sed -E 's#//[^@/]+@#//#')
  [ -n "$url" ] || continue
  head=$(git -C "$d" rev-parse --short HEAD); br=$(git -C "$d" branch --show-current)
  old=$(git -C "$d" for-each-ref --format='%(refname) %(objectname)' refs/remotes | sort)
  if ! timeout 60 git -C "$d" fetch -q --all 2>/dev/null; then echo "== $d  fetch FAILED ($url)"; continue; fi
  new=$(git -C "$d" for-each-ref --format='%(refname) %(objectname)' refs/remotes | sort)
  echo "== $d  $url  $br@$head"
  if [ "$old" = "$new" ]; then echo '   no new commits since the last fetch'; fi
  git -C "$d" log --remotes --not HEAD --since='2026-11-05' --format='   %h %ad %an %s' --date=format:'%m-%d %H:%M' 2>/dev/null | cut -c1-120 | head -14
  git -C "$d" log --remotes --not HEAD --since='2026-11-05' --name-only --format='' 2>/dev/null | grep -E '\.md$|^docs/' | sort -u | sed 's/^/   doc: /' | head -14
done
