#!/bin/bash
# Does the plugin pin carry the oslog export, and does the probe daemon reach it? Read-only.
M=/root/fuxi/src-adrenometal
echo "== oslog at our pin"
git -C $M cat-file -e 7e0d3d2:NativeOsLogExport.mm && echo present || echo absent
git -C $M log --format='%h %ad %s' --date=short -3 -- NativeOsLogExport.mm | cut -c1-110
echo "tree at $(git -C $M rev-parse --short HEAD)"
echo "== is 7e0d3d2 an ancestor of the first oslog commit"
F=$(git -C $M log --format=%h --diff-filter=A -- NativeOsLogExport.mm | tail -1); echo "added in $F"
git -C $M merge-base --is-ancestor "$F" 7e0d3d2 && echo "in our pin" || echo "NOT in our pin"
echo "== daemon at our pin"
git -C $M show 7e0d3d2:NativeAdrenoProbeDaemon.cpp | head -40 | cut -c1-150
