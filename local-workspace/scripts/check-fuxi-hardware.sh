#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== 可用驱动 ==="
ls drivers/ 2>/dev/null
echo
echo "=== 每个子系统的驱动文件 ==="
for d in gpu storage input touch display wifi; do
  [ -d "drivers/$d" ] && echo "--- $d: $(ls drivers/$d | head -6 | tr '\n' ' ')"
done
echo
echo "=== fuxi 的触控控制器 ==="
grep -n -A3 'touchscreen\|focaltech\|goodix\|ft3\|nt36' /root/fuxi/dtbcmp/final.dts 2>/dev/null | grep -i 'compatible\|focal\|goodix\|ft3\|nt36' | head -8 | cut -c1-150
echo
echo "=== fuxi 的 GPU / UFS 节点 ==="
grep -n -i 'compatible.*kgsl\|qcom,adreno\|ufshc\|qcom,ufs' /root/fuxi/dtbcmp/final.dts 2>/dev/null | head -6 | cut -c1-150
