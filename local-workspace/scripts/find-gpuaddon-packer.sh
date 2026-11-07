#!/bin/bash
set -uo pipefail
echo "=== 设备仓库里和 gpuaddon 有关 ==="
grep -rn 'gpuaddon' /root/fuxi/fork-device --include='*.py' --include='*.toml' --include='*.sh' 2>/dev/null | head -10 | cut -c1-160
echo
echo "=== 上游树里的 gpuaddon 打包工具 ==="
grep -rln 'gpuaddon' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts /mnt/e/DSH-Fuxi/unixnu-build/unixnu/kits 2>/dev/null | head -8
echo
echo "=== 我们 payload 里旧 addon 的头 16 字节 ==="
xxd -l 16 /root/fuxi/pkg4/mnt/EFI/UniXNU/Payloads/kernel.macho.gpuaddon 2>/dev/null || \
  python3 -c "
d=open('/root/fuxi/pkg4/kernel.macho.gpuaddon','rb').read(32) if __import__('os').path.exists('/root/fuxi/pkg4/kernel.macho.gpuaddon') else b''
print(d.hex() if d else '文件不在')
"
