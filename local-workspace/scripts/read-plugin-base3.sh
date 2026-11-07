#!/bin/bash
# Read only: the CI workflow's inputs and steps, and where the daily plugin came from.
W=/root/fuxi/unixnu-ci-push; cd $W; git log --oneline -6 | cut -c1-90; ls .github/workflows patches 2>/dev/null
f=$(grep -l display_state .github/workflows/* | head -1); echo "== $f"; sed -n 1,70p "$f" | cut -c1-140
grep -n -E 'display_state|size_opt|adreno_ref|ref:|gpu-build|NativeAdrenoMetal\.bundle|artifact' "$f" | cut -c1-140 | head -30
echo '== daily'; ls /root/fuxi/gpu-plugin-1105 | head; ls -la /root/fuxi/gpu-plugin-m2v-small /root/fuxi/gpu-plugin-m2v 2>/dev/null | head -12
grep -rlE 'plugin-try|gpu-plugin-1105|t50-priv-plugin' /mnt/e/DSH-Fuxi/dump/wsl/*.sh 2>/dev/null | head -8
grep -h -n -E 'plugin' /mnt/e/DSH-Fuxi/dump/wsl/make-t50-gpu7.sh 2>/dev/null | cut -c1-150 | head -10
strings -n 6 /root/fuxi/t50-priv-plugin/*/* 2>/dev/null | grep -E '^[0-9a-f]{7,10}$' | head -3
