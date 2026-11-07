#!/bin/bash
# Read only: official docs on CPU clusters and governors, against what our kernel actually has.
U=/root/fuxi/up-latest; O=/mnt/e/DSH-Fuxi/logs/m2v-read; mkdir -p $O
git -C $U ls-tree -r --name-only origin/main docs | grep -E '^docs/(porting|power|drivers/(arm|cpu)|porting/.*(cpu|platform|gpu))' | grep -v device-records | head -50
git -C $U show origin/main:docs/power.md > $O/power.md 2>/dev/null
git -C $U show origin/main:docs/porting/platform.md > $O/platform.md 2>/dev/null
git -C $U show origin/main:docs/porting/gpu.md > $O/porting-gpu.md 2>/dev/null
git -C $U show origin/main:docs/porting/gpu-diagnostics.md > $O/gpu-diagnostics.md 2>/dev/null
git -C $U show origin/main:docs/devices/fuxi.md > $O/device-fuxi.md 2>/dev/null
wc -l $O/*.md
echo; echo '== sections on clusters'
grep -n -iE 'cluster|edge|recommended|governor|cpufreq' $O/platform.md $O/power.md | cut -c1-230 | head -40
echo; echo '== fuxi device page'
grep -n -iE 'cluster|edge|cpufreq|governor|core|metal' $O/device-fuxi.md | cut -c1-230 | head -30
echo; echo '== our build tree'
F=/mnt/e/DSH-Fuxi/unixnu-build/fuxi; X=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
git -C $F log -1 --format='fuxi %h %ad %s' --date=short; git -C $X log -1 --format='unixnu %h %ad %s' --date=short
grep -nE 'sheng-smp|cpufreq|cpu0-park|sheng-cpu|sched|armcpu' $F/board.toml | cut -c1-140
ls $F/patches 2>/dev/null | head; find $F $X -iname '*type-cluster*' -o -iname '*edge*sched*' -o -iname '*cpu-idle*' -o -iname '*cpuidle*' 2>/dev/null | grep -v '/.git/' | cut -c1-140 | head
grep -rlI 'MAX_CPU_CLUSTERS' $F $X --include='*.patch' 2>/dev/null | cut -c1-140 | head
echo; echo '== the running kernel (gpu7 base)'
K=/root/fuxi/grant-t50-auto-g7grant/kernel.macho; ls -la $K
llvm-nm --defined-only $K 2>/dev/null | grep -iE ' _?(sched_edge_|sched_amp|sched_clutch_edge|pset_cluster|cluster_type|ml_get_cluster|sched_perfcontrol_update_recommended_cores|cpufreq|sheng_cpu)' | cut -d' ' -f3 | sed -E 's/_[0-9a-f]+$//' | sort -u | head -30
echo "edge symbols: $(llvm-nm --defined-only $K 2>/dev/null | grep -ciE 'sched_edge')"
strings -a $K | grep -E 'cluster-type|sheng-cpufreq|sheng-cpu0-park|sched_edge|sched_amp_|enable_skstb|^MAX_CPU' | sort -u | cut -c1-100 | head -20
echo; echo '== how plugins were built'
sed -n 1,40p /mnt/e/DSH-Fuxi/dump/wsl/push-plugin-ci2.sh | cut -c1-140
