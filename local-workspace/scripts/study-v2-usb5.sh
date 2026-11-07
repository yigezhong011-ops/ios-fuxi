#!/bin/bash
# Read-only study: clone the author's repo into a new directory, build nothing, run nothing from it.
W=/root/fuxi/ref-fuxi-v2
[ -d "$W/.git" ] || timeout 280 git clone -q --no-recurse-submodules https://github.com/ljhhkx529/unixnu-fuxi.git "$W" 2>&1 | tail -2
cd "$W" || exit 1
timeout 100 git fetch -q origin 2>&1 | tail -1
V=origin/V2; O=origin/old
echo "=== heads"; git for-each-ref --format='%(committerdate:iso) %(refname:short) %(subject)' refs/remotes/origin | cut -c1-120
echo "=== V2 vs old: merge-base $(git merge-base $V $O | cut -c1-10), ahead $(git rev-list --count $O..$V), behind $(git rev-list --count $V..$O)"
echo "=== V2 log"; git log $V -25 --date=iso --format='%h %ad %s' | cut -c1-120
echo "=== all docs on V2"; git ls-tree -r --long $V | grep -iE '\.(md|txt|rst|pdf)$|docs/|AGENTS|README' | awk '{print $4, $5}' | head -60
echo "=== usb commits on V2"; git log $V --date=short --format='%h %ad %s' -i --grep=usb | cut -c1-120 | head -20
echo "=== usb paths on V2"; git ls-tree -r --name-only $V | grep -i usb | head -30
echo "=== files with usb text on V2"; git grep -il usb $V | sed "s#$V:##" | head -40
echo "=== usb lines in md files"; git grep -inE '\busb\b' $V -- '*.md' | sed "s#$V:##" | cut -c1-240 | head -50
echo "=== boot args"; git grep -inE 'qcom-usb|usb-debug|usb-ctl|serial=' $V | sed "s#$V:##" | cut -c1-200 | head -20
