#!/bin/bash
# Read-only: the AMP patch, old's patch series, where the t50 kernel can be rebuilt from.
cd /root/fuxi/ref-fuxi-v2 || exit 1
V=origin/V2; O=origin/old
echo "=== patch stat"; git show $V:patches/xnu/zzyf-sheng-amp.patch | grep -E '^(diff|\+\+\+)' | grep '^+++' | cut -c1-100
git show $V:patches/xnu/zzyf-sheng-amp.patch | wc -l
echo "=== patch"; git show $V:patches/xnu/zzyf-sheng-amp.patch | cut -c1-130 | head -230
echo "=== V2 series"; git show $V:patches/xnu/series | cut -c1-110
echo "=== old: how patches are listed"
git ls-tree --name-only $O: | head -40 | tr '\n' ' '; echo
git ls-tree --name-only $O patches/xnu/ | wc -l
git ls-tree --name-only $O patches/xnu/ | grep -iE 'series|sched|amp|cluster|topolog' | head
git grep -nE 'patches/xnu|xnu_patches|fuxi-kernel-baseline' $O -- board.toml configs scripts/run-fuxi-usb-kernel.py | sed "s#$O:##" | cut -c1-150 | head -12
echo "=== old touches same files"
for f in $(git show $V:patches/xnu/zzyf-sheng-amp.patch | grep '^+++ ' | sed -E 's#^\+\+\+ [ab]/##'); do
  echo "--- $f: $(git grep -l -F "$f" $O -- 'patches/xnu/*' 2>/dev/null | wc -l) old patches"
  git grep -l -F "$f" $O -- 'patches/xnu/*' 2>/dev/null | sed "s#$O:patches/xnu/##" | head -6
done
echo "=== CI"
sed -n 1,60p /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | cut -c1-130
grep -nE 'unixnu build|build kernel|legacy-abi|workflow_dispatch|kernel_|inputs:|patch' /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | cut -c1-130 | head -40
echo "=== abi json present?"
find /root/fuxi /mnt/e/DSH-Fuxi/ci /mnt/e/DSH-Fuxi/unixnu-build -maxdepth 5 -name 'mobile-graphics-legacy-abi*' 2>/dev/null | head
echo "=== t50 provenance"; cat /root/fuxi/t50/args.txt | cut -c1-120; ls /mnt/e/DSH-Fuxi/share-for-author 2>/dev/null | head
