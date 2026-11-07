#!/bin/bash
# Read-only: where the AMP scheduler and cpufreq work lives, what the t50 kernel was built from, what its boot args are.
cd /root/fuxi || exit 1
echo "=== trees"; ls -d */ | tr '\n' ' '; echo
echo "=== zzyf patch and cluster-type"
find . -maxdepth 5 -name '*amp*.patch' 2>/dev/null | head
for t in unixnu-fuxi uni-oddly-fuxi unixnu-pin; do
  [ -d "$t" ] || continue
  echo "--- $t: $(git -C "$t" log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-90) branch=$(git -C "$t" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  grep -rlIE 'cluster-type' "$t" --include='*.c' --include='*.cpp' --include='*.patch' --include='*.h' 2>/dev/null | head -5
  grep -rlIE 'sheng-cpufreq-boost-ms|sheng-cpufreq-min' "$t" --include='*.c' --include='*.cpp' --include='*.patch' 2>/dev/null | head -5
done
echo "=== t50"
ls -la t50 | head -20
strings -a t50/kernel.macho | grep -m3 -E 'Darwin Kernel Version|unixnu|UniXNU' | cut -c1-140
echo "=== docs: platform clusters"
D=unixnu-pin/docs/zh/porting
grep -nEi 'cluster|簇|amp|edge' $D/platform.md | cut -c1-220 | head -14
echo "=== docs: power"
grep -nEi 'cpufreq|调频|boost|sheng-gpu-dcvs' $D/power.md | cut -c1-240 | head -18
echo "=== daily and test args"
strings -a /mnt/e/DSH-Fuxi/t50-auto-120clock-p.img | grep -m2 -E 'sheng-autoreset' | cut -c1-500
