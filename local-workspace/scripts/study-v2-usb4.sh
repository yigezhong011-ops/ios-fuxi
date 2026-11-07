#!/bin/bash
# Read-only: v2 refs in fuxi-related repos, and USB text in UniXNU main docs compared with our 10-31 pin.
cd /root/fuxi/up-latest || exit 1
M=origin/main; P=$(git -C /root/fuxi/unixnu-pin rev-parse HEAD)
echo "=== fuxi records"
for f in fuxi fuxi-oddlylabs fuxi-mouse233; do echo "--- $f"; git show $M:docs/.vitepress/device-records/$f.toml | grep -iE 'repo|url|usb|github' | cut -c1-200 | head -12; done
echo "=== refs in related repos"
for r in ljhhkx529/unixnu-fuxi SadNutWall/unixnu-fuxi OddlyLabs/UniXNU-fuxi Star-mailaz/fuxi-ios16-unixnu Kerfand/UniXNU-fuxi-wifi UniXNU/UniXNU-sheng UniXNU/uefi-sheng UniXNU/.github; do
  echo "--- $r"; GIT_TERMINAL_PROMPT=0 timeout 40 git ls-remote --heads https://github.com/$r.git 2>/dev/null | cut -c42- | head -20 | tr '\n' ' '; echo
done
echo "=== non-record docs mentioning usb on main"
git grep -ilE '\busb\b' $M -- docs ':!docs/.vitepress/device-records' | sed 's#origin/main:##' | grep -v '/en/' | head -50
echo "=== have pin commit? $P"; git cat-file -e $P 2>/dev/null && echo yes || echo no
echo "=== usb doc diff pin..main"
git diff $P $M -- docs ':!docs/.vitepress/device-records' 2>/dev/null | grep -E '^(\+\+\+|[+-].*\b[Uu][Ss][Bb]\b)' | grep -B1 -E '^[+-][^+-]' | grep -v '^--$' | cut -c1-260 | head -50
echo "=== commits on main with usb text in docs since pin"
git log $P..$M --date=short --format='%h %ad %s' -G'[Uu][Ss][Bb]' -- docs ':!docs/.vitepress/device-records' 2>/dev/null | cut -c1-110 | head -20
