#!/bin/bash
# Read-only: CI kernel build history, how old lists its patches, AMP-related config.
E=/mnt/e/DSH-Fuxi
echo "=== ci-run-status.sh"; cut -c1-140 $E/dump/wsl/ci-run-status.sh | sed 's/\(token\|TOKEN\)=.*/\1=<hidden>/' | head -20
echo "=== CI workflow 110-180"; sed -n 110,180p $E/ci/fuxi-gpu.yml | cut -c1-150
echo "=== recent runs"
curl -fsS -A fuxi-study 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs?per_page=30' | python3 -I -c "
import json,sys
for r in json.load(sys.stdin)['workflow_runs']:
    print(r['id'], r['created_at'][:16], r['status'], r['conclusion'], r['name'], (r.get('display_title') or '')[:40])" | head -30
cd /root/fuxi/ref-fuxi-v2 || exit 1
O=origin/old
echo "=== old defconfigs"; git ls-tree --name-only $O configs/
echo "=== old patch listing"
git grep -nE 'native-smp-secondary|native-arm-pan' $O -- . ':!patches/xnu/native-*' | sed "s#$O:##" | cut -c1-170 | head -10
git show $O:AGENTS.md | grep -nEi 'kernel|t50|legacy|abi|ci\b' | cut -c1-180 | head -20
echo "=== old AMP/EDGE config"
git grep -nE 'SCHED_EDGE|__ARM_AMP__|cluster.?type|MAX_CPU_CLUSTERS|armcpu-edge' $O | sed "s#$O:##" | cut -c1-170 | head -20
echo "=== kernel version of old build log"
git show $O:BUILD-PROGRESS.md | grep -nEi 'amp|edge|cluster|t50|subtype2556' | cut -c1-200 | head -12
git log $O -8 --date=iso --format='%h %ad %s' | cut -c1-110
echo "=== t50 kernel: edge symbols"
llvm-nm /root/fuxi/t50/kernel.macho | grep -cE 'sched_edge|sched_clutch'
llvm-nm /root/fuxi/t50/kernel.macho | grep -E '_sched_edge_(init|cluster_load_metric|thread_preferred)|_ml_get_topology_info$' | cut -c18- | head
