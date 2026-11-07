#!/bin/bash
# Read-only: where the "S zap" and "Z7/4" progress marks come from, and the writer's reset rule that returns a stuck boot at about 125 s.
K=/root/fuxi/t50/kernel.macho
ls -d /root/fuxi/src-* /root/fuxi/ref-* 2>/dev/null | tr '\n' ' '; echo
for r in /root/fuxi/src-unixnu /root/fuxi/src-adrenometal /root/fuxi/src-adreno740 /root/fuxi/ref-gopfb /root/fuxi/ref-fuxi-v2; do
  [ -d $r ] || continue
  echo "== $r"
  git -C $r grep -n -I -E 'S zap|"zap"|Z%u|Z%d|zap_|ZapShader|loadZap|zap-shader' HEAD 2>/dev/null | cut -c1-150 | head -14
done
echo "== kernel strings"
strings -a -t x $K | grep -E '\bzap\b|\bZ%|S zap|boot_stage|autoreset|panic-reason|reset reason|writer' | cut -c1-110 | head -24
llvm-nm $K | grep -iE 'zap|gmu_|native_gpu_(progress|stage|boot)|boot_progress' | cut -c1-90 | head -30
echo "== logs with the mark"
grep -rl -a --include='*.txt' -E 'S zap' /mnt/e/DSH-Fuxi/logs /root/fuxi/cad-ab /root/fuxi/wall1 2>/dev/null | head
for f in $(ls -t /mnt/e/DSH-Fuxi/dump/wsl/*coh* /mnt/e/DSH-Fuxi/dump/wsl/*hang* /mnt/e/DSH-Fuxi/dump/wsl/*stuck* 2>/dev/null | head -8); do echo $f; done
