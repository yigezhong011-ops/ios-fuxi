#!/bin/bash
# Deletes the reviewed list from clean-e-list.sh, minus three items kept after review. Only paths inside DSH-Fuxi.
set -u
cd /mnt/e/DSH-Fuxi || exit 1
before=$(df -m --output=avail /mnt/e | tail -1)
n=0; fail=0
grep -v -E '^(peer-boot1|t50-auto-marker2|t50-auto-marker5)\.img$' /tmp/clean-e.txt > /tmp/clean-e-final.txt
while IFS= read -r f; do
  case "$f" in
    *..*|/*|'') echo "skip $f"; fail=$((fail+1)); continue;;
    t50-*.img|待删除/*|logs/*) ;;
    *) echo "skip $f"; fail=$((fail+1)); continue;;
  esac
  if rm -rf -- "$f"; then n=$((n+1)); else echo "failed $f"; fail=$((fail+1)); fi
done < /tmp/clean-e-final.txt
after=$(df -m --output=avail /mnt/e | tail -1)
echo "deleted $n, problems $fail, free ${before}M -> ${after}M"
for k in t50-daily-gpu7 t50-auto-gpu7tap t50-auto-g7plug t50-mine t50-mine-gpu-fix t50-auto-marker2; do [ -f $k.img ] && echo "kept $k" || echo "MISSING $k"; done
ls -d keys token2.txt logs/boot_b-before-gpu7-001515.img logs/data-raw.img logs/carve-iphonex-second | tr '\n' ' '; echo
