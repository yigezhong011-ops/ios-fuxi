#!/bin/bash
set -uo pipefail
echo "=== 老树 make-gpu-addon.py 支持 --wallpaper 吗 ==="
grep -n 'wallpaper' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/make-gpu-addon.py 2>/dev/null | head -8 | cut -c1-140
echo
echo "=== 老树的 unixnu 版本 ==="
git -C /mnt/e/DSH-Fuxi/unixnu-build/unixnu log --oneline -1 2>/dev/null | cut -c1-90
echo
echo "=== 设备仓库 board.toml 关键行 ==="
grep -nE '^(os_profile|"os_profile")|defconfig|unique_chip|schema' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/board.toml 2>/dev/null | head -8 | cut -c1-120
echo
echo "=== 设备仓库 configs ==="
ls /mnt/e/DSH-Fuxi/unixnu-build/fuxi/configs 2>/dev/null | head -8
echo
echo "=== t32 载荷里的文件（用于对照）==="
mtype -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null | head -5
mdir -i /root/fuxi/t32/vol.img -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -8
