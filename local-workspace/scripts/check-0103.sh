#!/bin/bash
set -uo pipefail
echo "=== 0103 里 fuxi_touch.c 是按整文件添加的吗 ==="
grep -n 'fuxi_touch.c\|^+.*FUXI TOUCH: starting' /root/ios-fuxi/xnu/patches/0103-fuxi-kernel-h1.patch | head -5
echo
echo "=== 后续有没有补丁改 fuxi_touch.c 的 ft_thread 区域 ==="
for p in $(grep -l 'fuxi_touch.c' /root/ios-fuxi/xnu/patches/*.patch | sort); do
  n=$(grep -c 'fuxi_touch.c' "$p")
  echo "$(basename $p): $n 处提及"
done
echo
echo "=== 仓库文件里的关键锚点 ==="
grep -n 'starting in %u s' /root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c
