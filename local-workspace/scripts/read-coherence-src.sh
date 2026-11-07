#!/bin/bash
# Where is the coherence probe? Read-only.
A=/root/fuxi/src-adreno740; P=759d646; U=/root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
git -C $A show $P:NativeAdrenoSmmuMemory.cpp | sed -n 1,14p | cut -c1-420
git -C $A grep -n -E 'GpuPowerProbe' $P | sed "s/^$P://" | cut -c1-170 | head -8
git -C $U ls-tree -r --name-only $R > /root/fuxi/u-tree.txt
wc -l /root/fuxi/u-tree.txt
grep -i -E 'GpuPower|PowerProbe|GpuProbe|adreno|native-gpu|nativegpu' /root/fuxi/u-tree.txt | grep -v -E '^(docs|patches/mesa)' | cut -c1-110 | head -30
git -C $U ls-tree -r --name-only $R | grep -i -E 'kernel.*(probe|gpu)' | cut -c1-110 | head -20
git -C $U log origin/main --format='%h %cI %s' -i --grep='coherence probe\|coherenceProbe\|GpuPowerProbe\|io_coherent\|snooped' | cut -c1-130 | head
ls /mnt/e/DSH-Fuxi/share-for-author 2>/dev/null | head -5
find /root/fuxi /mnt/e/DSH-Fuxi/unixnu-build -maxdepth 4 -type f -name '*PowerProbe*' 2>/dev/null | head -5
