#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
run() {
  local out=$1
  timeout 150 python3 tools/fuxi-xnu-monitor.py \
    --kernel /mnt/e/DSH-Fuxi/ci/kernel-diag/kernel.development.fuxi \
    --payload /root/fuxi/payload-diag.bin --out "$out" --seconds 20 \
    --reset-minutes 40 2>&1 | tail -1
}
echo "=== 第一次采样 ==="
run /root/fuxi/s1
sleep 240
echo "=== 第二次采样（4 分钟后）==="
run /root/fuxi/s2
echo
for d in /root/fuxi/s1 /root/fuxi/s2; do
  [ -f "$d/boot.log" ] || { echo "$d: 无日志"; continue; }
  printf '%s: exec=%s SpringBoard=%s swaps=%s\n' "$d" \
    "$(tr -d '\000' < "$d/boot.log" | grep -a -c '^exec ')" \
    "$(tr -d '\000' < "$d/boot.log" | grep -a -c 'exec SpringBoard')" \
    "$(tr -d '\000' < "$d/boot.log" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -1 | awk '{print $3}')"
done
