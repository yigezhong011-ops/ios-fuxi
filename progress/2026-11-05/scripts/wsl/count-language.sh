#!/bin/bash
# How often does the reaping run, and is there any state file that would stop it?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== 关键事件计数 ==="
for k in 'for reasons: language change' 'Data store migration initiated' 'Data store migration not needed' \
         'Reaped snapshot' 'Data store could not be created' 'com.apple.migration.plist' \
         'AppleLanguages' 'LanguageChange' 'preferredLanguages'; do
  printf '  %-40s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== 语言相关行（去重，前 12）==="
grep -a -iE 'language|preferredLanguages' "$L" | sed 's/^[^ ]* //' | sort -u | head -12 | cut -c1-200
