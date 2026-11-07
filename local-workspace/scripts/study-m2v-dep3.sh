#!/bin/bash
# Read-only for upstream: what lies between our pin and the fix; the patch series at each.
cd /root/fuxi/src-adrenometal
git merge-base --is-ancestor 7e0d3d2 8c1ea13 && echo "7e0d3d2 is an ancestor of 8c1ea13" || echo "not an ancestor"
echo "== commits 7e0d3d2..8c1ea13"; git log --reverse --format='%h %ad %s' --date=short 7e0d3d2..8c1ea13 | cut -c1-110
git log --reverse --format='%h %s' 7e0d3d2..de4c1ee | wc -l
echo "== merge-base"; git merge-base 7e0d3d2 8c1ea13 | cut -c1-8; git merge-base 7e0d3d2 de4c1ee | cut -c1-8
echo "== series"; git ls-tree --name-only 7e0d3d2 bridge/patches/ | tail -6; echo ...; git ls-tree --name-only de4c1ee bridge/patches/ | tail -6
git show --stat --format='%h %s' de4c1ee | cut -c1-100
echo "== tools"; which rustc cargo; rustc --version 2>/dev/null; ls ~/.cargo/bin 2>/dev/null | head -4
echo "== build order"; grep -n -E 'bridge/patches|patches/' /root/fuxi/up-latest/scripts/build-adreno-metal-bridge.py | cut -c1-150 | head -10
