#!/bin/bash
# Local dry run: 0001-0020 from our pin on the translator, then 0025 with and without 0021-0024. Nothing is pushed.
set -uo pipefail
A=/root/fuxi/src-adrenometal; M=/root/fuxi/m2v-try; U=/root/fuxi/unixnu-pin
git -C $M fetch -q --depth=1 https://github.com/steelbrain/metal2vulkan 624bab3918de5b978e1101517abca2b4fa426565 && git -C $M checkout -q --detach FETCH_HEAD
git -C $M log -1 --format='m2v %h'
sed -n 60,82p $U/scripts/build-adreno-metal-bridge.py | cut -c1-140
P=/root/fuxi/m2v-patches; rm -rf $P; mkdir -p $P
for n in $(git -C $A ls-tree --name-only de4c1ee bridge/patches/ | xargs -n1 basename); do git -C $A show de4c1ee:bridge/patches/$n > $P/$n; done
ls $P | wc -l
cd $M
for f in $P/00{01..20}-*; do git apply "$f" 2>/tmp/err || { echo "FAIL $(basename $f)"; head -3 /tmp/err; }; done
git add -A; git -c user.name=x -c user.email=x@x commit -q -m base20; echo "base20 $(git rev-parse --short HEAD)"
echo "== 0025 alone"; git apply --check $P/0025-* 2>&1 | head -12 | cut -c1-110; echo "rc=${PIPESTATUS[0]}"
echo "== with 0021-0024"
for f in $P/002{1..4}-*; do git apply "$f" 2>/tmp/err && echo "ok $(basename $f)" || { echo "FAIL $(basename $f)"; head -3 /tmp/err | cut -c1-110; }; done
git apply --check $P/0025-* 2>&1 | head -12 | cut -c1-110; echo "rc=${PIPESTATUS[0]}"
git reset -q --hard; git clean -qfd
echo "== stat 0021-0024"; for f in $P/002{1..4}-*; do echo "$(basename $f) $(grep -c '' $f) lines, $(grep -c '^diff --git' $f) files"; done
echo "== other commits touching the frontend ABI"; git -C $A diff --stat 7e0d3d2 de4c1ee -- bridge/NativeMetalObjects.rs bridge/NativeMetalObjects.h | tail -3 | cut -c1-100
