#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon30/boot.log
echo "=== mobileactivationd 活动 ==="
tr -d '\000' < "$L" | grep -a -i 'mobileactivation' | tail -6
echo
echo "=== 是否有 'boot task' / 'check-in' 停滞 ==="
tr -d '\000' < "$L" | grep -a 'boot task\|Boot task\|check-in' | tail -8
echo
echo "=== 与 mon27（能到 SpringBoard 的那次）对比：exec 总数 ==="
for f in /root/fuxi/mon27/boot.log /root/fuxi/mon28/boot.log /root/fuxi/mon30/boot.log; do
  [ -f "$f" ] && printf '%s: exec=%s springboard=%s\n' "$(basename $(dirname $f))" \
    "$(tr -d '\000' < "$f" | grep -a -c '^exec ')" \
    "$(tr -d '\000' < "$f" | grep -a -c 'exec SpringBoard')"
done
