#!/bin/bash
# The plugin's scanout copy: can it scale? Read-only.
A=/root/fuxi/src-adrenometal; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150
git -C $A show $P:GpuScanoutPresenter.h | wc -l
git -C $A show $P:GpuScanoutPresenter.h | sed -n 1,28p | cut -c1-210
git -C $A show $P:GpuScanoutPresenter.h | grep -n -E 'width|height|Blit|blit|CmdCopy|extent|stride|Extent' | cut -c1-170 | head -30
echo "== callers"; git -C $A grep -n -E 'GpuScanoutPresenter' $P -- '*.mm' '*.h' | sed "s/^$P://" | cut -c1-170 | head -10
echo "== source tree"; ls /mnt/e/DSH-Fuxi/unixnu-build /mnt/e/DSH-Fuxi/unixnu-build/* 2>/dev/null | head -30
echo "== kernel strings"; strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'validateSwap|verify_swap|NativeLegacyDisplay::' | cut -c1-140 | sort -u | head -20
sed -n 1,24p /mnt/e/DSH-Fuxi/dump/wsl/patch-canvas.py | cut -c1-170
