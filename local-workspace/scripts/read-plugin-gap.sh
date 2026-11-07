#!/bin/bash
# How far our AdrenoMetal plugin and driver are behind upstream. Fetch only; nothing is checked out or merged.
cd /root/fuxi
for r in src-adrenometal upstream-am src-adreno740 src-mesa-pin src-unixnu unixnu-pin; do
  [ -d "$r/.git" ] || continue
  echo "== $r: $(git -C "$r" remote get-url origin 2>/dev/null | sed -E 's#https://[^@]*@#https://#')  HEAD $(git -C "$r" log -1 --format='%h %ad %s' --date=short | cut -c1-80)"
done
echo "--- plugin-p leftovers"
ls -la /root/fuxi/auto-t50-auto-plugin-p /root/fuxi/gpu-plugin-1105 2>/dev/null | cut -c1-100 | head -24
find /mnt/e/DSH-Fuxi -maxdepth 3 -iname '*plugin-p*' 2>/dev/null | head
echo "--- current base addon"
grep -a -n -E 'gpu-new|addon|ADDON' /mnt/e/DSH-Fuxi/dump/wsl/make-t50-gpu7.sh | cut -c1-120 | head -12
A=/root/fuxi/upstream-am
if [ -d "$A/.git" ]; then
  timeout 60 git -C "$A" fetch -q origin 2>&1 | tail -1
  B=$(git -C "$A" symbolic-ref -q --short refs/remotes/origin/HEAD || echo origin/main)
  echo "--- upstream $B: $(git -C "$A" log -1 --format='%h %ad' --date=short "$B")"
  echo "commits after 7e0d3d2: $(git -C "$A" rev-list --count 7e0d3d2.."$B" 2>/dev/null)"
  git -C "$A" log --since=2026-11-01 --date=short --format='%h %ad %s' "$B" | cut -c1-96 | grep -i -E 'function.?const|poster|sample|msaa|fence|timeout|stall|perf|lag|cache|texture|linear|heap|pipeline|argument|indirect|compute|mesh|blit' | head -40
fi
