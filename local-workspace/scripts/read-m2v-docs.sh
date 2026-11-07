#!/bin/bash
# Read only. Writes to E: so the documents can be read whole.
U=/root/fuxi/up-latest; A=/root/fuxi/src-adrenometal; O=/mnt/e/DSH-Fuxi/logs/m2v-read; mkdir -p $O
B=origin/feat/metal2vulkan-963f0e64
git -C $U show $B:docs/zh/drivers/adreno-metal.md > $O/adreno-metal.zh.md
git -C $U show $B:docs/drivers/adreno-metal.md > $O/adreno-metal.en.md
git -C $U diff origin/main...$B -- docs/drivers/adreno-metal.md components.toml scripts/data/gpu-metal-vulkan-inputs.json > $O/unixnu-diff.txt
git -C $A log --format='--- %h %ad%n%B' --date=short origin/main..$B > $O/adrenometal-commits.txt
git -C $A show $B:README.md > $O/adrenometal-readme.md
git -C $A diff origin/main...$B -- README.md AGENTS.md > $O/adrenometal-doc-diff.txt
git -C $A diff origin/main...$B -- bridge/NativeMetalObjects.rs > $O/objects-diff.txt
wc -l $O/*
echo; echo '== cluster, placement, core, governor in docs and platform (main of UniXNU)'
git -C $U grep -n -iE 'cluster|work placement|recommended.?cores|cpu-type|e-?core|p-?core|perflevel' origin/main -- docs/drivers docs/power docs/porting docs/zh/drivers/adreno-metal.md 'docs/*.md' 2>/dev/null | grep -v device-records | cut -c1-200 | head -40
echo; echo '== the cluster commit on branches'
git -C $U log --all --format='%h %ad %s' --date=short -i --grep='cluster' | cut -c1-120 | head -20
echo; echo '== fuxi dts cluster and our tree'
grep -rnIiE 'cluster-type|cluster_type|apple,(sawtooth|everest|blizzard|avalanche)|capacity-dmips' /mnt/e/DSH-Fuxi/unixnu-build/fuxi --include='*.dts*' --include='*.toml' --include='*.py' 2>/dev/null | cut -c1-160 | head -12
git -C /mnt/e/DSH-Fuxi/unixnu-build/unixnu grep -n -iE 'cluster-type|cluster_type' HEAD -- scripts tools patches 2>/dev/null | cut -c1-160 | head -12
