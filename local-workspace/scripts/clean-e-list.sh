#!/bin/bash
# Dry run: writes the delete candidates to /tmp/clean-e.txt and prints them. Deletes nothing.
cd /mnt/e/DSH-Fuxi
KEEP='^(t50-daily-gpu7|t50-auto-gpu7tap|t50-auto-g7plug|t50-auto-gpu7|t50-mine|t50-mine-gpu-fix|t50-subtype2556-nodiag|t50-daily-wall17|t50-auto-wall17|t36-bl2|t36-bl2-gpu-fix|t36-setup0|t36-phone-cache-miss|t32-bl-daily|t32-gpu6)\.img$'
echo '--- images used as inputs by scripts'
grep -h -o -E '\$E/[A-Za-z0-9._-]+\.img' dump/wsl/*.sh 2>/dev/null | sort | uniq -c | sort -rn | head -14
: > /tmp/clean-e.txt
ls -1 | grep -E '\.img$' | grep -v -E "$KEEP" >> /tmp/clean-e.txt
ls -1d 待删除/* >> /tmp/clean-e.txt 2>/dev/null
find logs -maxdepth 1 -type f \( -name 'twrp-*.bin' -o -name 'l-*.bin' -o -name 'fuxi-log-*.bin' \) ! -newermt 2026-11-06 >> /tmp/clean-e.txt
echo logs/carve-iphonex-first >> /tmp/clean-e.txt
echo '--- kept images'; ls -1 | grep -E '\.img$' | grep -E "$KEEP" | tr '\n' ' '; echo
echo '--- candidates'
n=0; t=0
while IFS= read -r f; do s=$(du -sb -- "$f" | cut -f1); t=$((t+s)); n=$((n+1)); printf '%6dM %s\n' $((s/1048576)) "$f"; done < /tmp/clean-e.txt
echo "TOTAL $n items $((t/1048576)) MiB"
echo '--- data-raw and data-head'
ls -la --time-style=long-iso logs/data-raw.img logs/data-head-before-reset-* | cut -c24-
