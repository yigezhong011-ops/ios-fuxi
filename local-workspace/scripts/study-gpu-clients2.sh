#!/bin/bash
# Read-only: the GPU client state in the last boot, full t50 args, and CI scripts.
cd /root/fuxi/wall1/log/untagged-2c15ceb80
mtype -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a 'args =' | head -1 | cut -c1-1100
for r in '\[gpu clients\]' '\[metal askers\]' '\[gpu methods\]' '\[mfb clients\]' '\[metal table\]' '\[bo pool\]'; do
  echo "== $r"; grep -a -A5 -E "^$r" latest.txt | cut -c1-260 | head -7
done
echo "== plugin rows"; grep -a -n -i -E 'refus|device refused|Vulkan\(|OutOfMemory|NeedsInput' latest.txt | cut -c1-200 | head -12
L=/mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt
echo "== refused"; LC_ALL=C grep -a -E 'device refused|Vulkan\(-' /root/fuxi/wall1/new.txt | cut -c1-140 | sed -E 's/\[[0-9]+\]//; s/[0-9a-f]{8,}/H/g' | sort | uniq -c | sort -rn | head -14
echo "== poster shaders"; LC_ALL=C grep -a -E 'NeedsInput|FunctionConstant|EntryNotFound|InvalidFile|computeFunction must' /root/fuxi/wall1/new.txt | cut -c1-170 | sort | uniq -c | sort -rn | head -14
echo "== ci"; cat /root/fuxi/dcr.sh 2>/dev/null | cut -c1-220 | head -24; cat /root/fuxi/crst.sh 2>/dev/null | cut -c1-160 | head -8
git -C /root/fuxi/src-adrenometal log --oneline -2; git -C /root/fuxi/src-adrenometal remote -v | head -1
timeout 30 git ls-remote "$(git -C /root/fuxi/src-adrenometal remote get-url origin)" HEAD | cut -c1-12
