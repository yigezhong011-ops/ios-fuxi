#!/bin/bash
# Read only: finds zzyf-sheng-amp and zzye-sheng-cpu-idle in local clones and upstream repos, and whether our tree or boot args carry the governor.
for d in /root/fuxi/ref-fuxi-v2 /root/fuxi/fuxi-oddly /root/fuxi/ref-sad-fuxi /root/fuxi/fw/fuxi /root/fuxi/up-latest /root/fuxi/src-unixnu /root/fuxi/uni-oddly /mnt/e/DSH-Fuxi/unixnu-build/fuxi /mnt/e/DSH-Fuxi/unixnu-build/unixnu; do
  [ -d "$d/.git" ] || continue
  r=$(git -C "$d" for-each-ref --format='%(refname)' refs/remotes refs/heads | while read -r x; do git -C "$d" ls-tree -r --name-only "$x" 2>/dev/null | grep -E 'zzy[ef]-sheng-(amp|cpu-idle)' | sed "s#^#$x: #"; done | sort -u | head -4)
  echo "-- $d"; [ -n "$r" ] && echo "$r" | cut -c1-140
done
echo; for r in UniXNU-sheng UniXNU-sm8550-common Sm8550Platform; do
  rm -rf /tmp/peek-$r; git clone -q --filter=blob:none --no-checkout --depth 1 https://github.com/UniXNU/$r.git /tmp/peek-$r 2>/dev/null || { echo "$r: no clone"; continue; }
  echo "== $r"; git -C /tmp/peek-$r ls-tree -r --name-only HEAD | grep -iE 'zzy[ef]|amp\.patch|cpu-idle|type-cluster|coreduet' | head
done
echo; echo '== our boot args'
grep -oE 'sheng-(cpufreq|gpu-dcvs)[a-z-]*=[^ "]*' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/board.toml | sort -u
python3 -I - <<'P'
import re
d=open('/root/fuxi/tap-t50-auto-g7cpu/vol.img','rb').read()
for k in [b'sheng-cpufreq',b'sheng-gpu-dcvs']:
    print(k.decode(), sorted(set(m.group(0).decode() for m in re.finditer(k+rb'[a-z-]*=[0-9]+', d)))[:8])
P
llvm-nm --defined-only /root/fuxi/grant-t50-auto-g7grant/kernel.macho | grep -iE 'sheng_(cpu|gpu)|cpu_idle' | cut -d' ' -f3 | head -20
