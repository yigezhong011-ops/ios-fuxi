#!/bin/bash
# Read-only: where the ios-fuxi clone is, its state and how earlier syncs looked.
for d in /root/fuxi/ios-fuxi /root/ios-fuxi /mnt/e/DSH-Fuxi/ios-fuxi /mnt/e/DSH-Fuxi/repo-ios-fuxi; do [ -d "$d/.git" ] && echo "clone: $d"; done
find /root /mnt/e/DSH-Fuxi -maxdepth 3 -type d -name .git 2>/dev/null | grep -v -E 'unixnu-build/|/src-|/ref-|hakios' | head -12
for d in $(find /root /mnt/e/DSH-Fuxi -maxdepth 3 -type d -name .git 2>/dev/null | grep -v -E 'unixnu-build/|/src-|/ref-|hakios'); do
  r=${d%/.git}; u=$(git -C "$r" remote get-url origin 2>/dev/null | sed -E 's#//[^@/]+@#//#')
  case "$u" in *ios-fuxi*) echo "== $r $u"; git -C "$r" status -sb | head -6; git -C "$r" log -6 --format='%h %ad %s' --date=short | cut -c1-100; git -C "$r" ls-files | head -40; cat "$r/.gitignore" 2>/dev/null | head -30;; esac
done
grep -l -r -E 'ios-fuxi' /mnt/e/DSH-Fuxi/dump/wsl/*.sh 2>/dev/null | head
