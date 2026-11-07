#!/bin/bash
# Read only: exports the AMP patch from the V2 branch of the author's device repo and from UniXNU-sheng, and how the patches apply to our kernel source.
O=/mnt/e/DSH-Fuxi/logs/m2v-read; R=/root/fuxi/ref-fuxi-v2
git -C $R show origin/V2:patches/xnu/zzyf-sheng-amp.patch > $O/zzyf-sheng-amp-fuxi-v2.patch
git -C $R log -3 --format='%h %ad %s' --date=short origin/V2 -- patches/xnu/zzyf-sheng-amp.patch | cut -c1-110
git -C $R show origin/V2:patches/xnu/zzye-sheng-cpu-idle.patch > $O/zzye-sheng-cpu-idle-fuxi-v2.patch 2>/dev/null
wc -l $O/zzy*
grep -E '^(diff --git|\+\+\+ )' $O/zzyf-sheng-amp-fuxi-v2.patch | grep '^+++' | cut -c1-90
echo; echo '== kernel source used by our t50 build'
ls -d /root/fuxi/*xnu* /root/fuxi/*/xnu* /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/*/xnu* 2>/dev/null | head
grep -nE 'CONFIG_SCHED_EDGE|sched_edge|SCHED_EDGE|MAX_CPU_CLUSTERS' $O/zzyf-sheng-amp-fuxi-v2.patch | cut -c1-120 | head -20
echo; echo '== t50 build recipe mentions'
grep -lE 'patches/xnu|build-kernel|kernel\.macho.*build|make.*xnu' /mnt/e/DSH-Fuxi/dump/wsl/*.sh 2>/dev/null | head -12
which clang ld64.lld 2>/dev/null
