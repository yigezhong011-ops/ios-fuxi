#!/bin/bash
# Fetches only into remote-tracking refs of the local up-latest clone; no worktree or branch changes, nothing pushed.
cd /root/fuxi/up-latest || exit 1
timeout 240 git fetch -q origin '+refs/heads/*:refs/remotes/origin/*' 2>&1 | tail -2
M=origin/main
echo "=== main $(git log -1 --format='%h %ad %s' --date=iso $M | cut -c1-110)"
echo "=== all heads, newest first"
git for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname:short) %(subject)' refs/remotes/origin | cut -c1-110
echo "=== branches whose diff from main touches usb in a path or doc text"
for b in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin | grep -v -E 'origin/(main|HEAD)$|^origin$'); do
  mb=$(git merge-base $M $b 2>/dev/null) || continue
  n=$(git diff --name-only $mb $b | grep -ic usb)
  d=$(git diff $mb $b -- docs '*.md' | grep -E '^[+-]' | grep -ic usb)
  a=$(git rev-list --count $mb..$b)
  [ "$n" != 0 -o "$d" != 0 ] && echo "$b ahead=$a usbfiles=$n docusblines=$d"
done
echo "=== main docs mentioning usb"
git grep -ilE '\busb\b' $M -- docs | sed 's#origin/main:##' | head -40
echo "=== main commits touching usb docs, last 14 days"
git log $M --since=2026-10-22 --date=short --format='%h %ad %s' -i --grep=usb | cut -c1-110 | head -30
