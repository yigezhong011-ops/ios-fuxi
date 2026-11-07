#!/bin/bash
# Read only: fetches the GPU branches of the upstream repos and prints what each adds over main. Touches remote-tracking refs in scratch clones only.
show() {
  local d=$1; shift
  git -C "$d" fetch -q origin "+refs/heads/*:refs/remotes/origin/*" 2>&1 | tail -1
  for b in "$@"; do
    git -C "$d" rev-parse -q --verify "origin/$b" >/dev/null || continue
    echo "=== $(basename "$d") $b  ahead/behind main: $(git -C "$d" rev-list --left-right --count origin/main...origin/$b | awk '{print $2"/"$1}')  tip $(git -C "$d" log -1 --format='%h %ad' --date=short origin/$b)"
    git -C "$d" log --format='%h %ad %s' --date=short origin/main..origin/$b | cut -c1-120 | head -40
    git -C "$d" diff --shortstat origin/main...origin/$b
    git -C "$d" diff --stat=100 origin/main...origin/$b | sort -t'|' -k2 -rn | head -14
  done
}
B='feat/metal2vulkan-963f0e64 perf/gpu-smoothness feat/ipados27-gpu-parity fix/gpu-nobin feat/gpu-aperture-4g fix/gpu-scheduling-and-metal'
show /root/fuxi/src-adrenometal $B
show /root/fuxi/src-adreno740 $B
show /root/fuxi/up-latest $B chore/native-metal-nobin
echo; echo '=== our plugin pin'; git -C /root/fuxi/src-adrenometal log -1 --format='%h %ad %s' --date=short 7e0d3d2
for b in feat/metal2vulkan-963f0e64 perf/gpu-smoothness feat/ipados27-gpu-parity; do
  echo "7e0d3d2 ancestor of $b: $(git -C /root/fuxi/src-adrenometal merge-base --is-ancestor 7e0d3d2 origin/$b && echo yes || echo no)"
done
echo; echo '=== docs in the branch'
git -C /root/fuxi/up-latest ls-tree -r --name-only origin/feat/metal2vulkan-963f0e64 | grep -iE '(^|/)(docs?/|.*metal.*\.md|.*vulkan.*\.md|.*gpu.*\.md)' | head -30
git -C /root/fuxi/src-adrenometal ls-tree -r --name-only origin/feat/metal2vulkan-963f0e64 | grep -iE '\.md$' | head -30
