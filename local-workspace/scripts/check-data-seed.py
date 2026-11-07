#!/bin/bash
# The GPU plugin has to be staged into the Data seed (scratch-data.img): without
# the publish/clients files no Metal device reaches backboardd.
set -uo pipefail
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
W=/root/fuxi/seed
M=$W/m
rm -rf "$W"; mkdir -p "$M"

echo "=== expert scratch-data.img 内容 ==="
python3 - <<'PY'
import struct
from pathlib import Path
p = Path('/root/fuxi/pl')  # 上一次挂载的 payload，取 scratch 镜像副本
src = Path('/root/fuxi/expert-scratch.img')
if not src.exists():
    print('先提取 scratch-data.img')
PY

# 从专家 payload 卷里取 scratch-data.img
mount -t vfat -o loop,ro /root/fuxi/expert-payload-vol.img "$M"
cp "$M/EFI/UniXNU/Payloads/scratch-data.img" /root/fuxi/expert-scratch.img
umount "$M"
echo "scratch-data.img: $(stat -c%s /root/fuxi/expert-scratch.img) 字节"

echo "=== 里面有没有 GPU 插件的 publish/clients 文件 ==="
python3 - <<'PY'
from pathlib import Path
data = Path('/root/fuxi/expert-scratch.img').read_bytes()
for name in (b'NativeAdrenoMetal.publish', b'NativeAdrenoMetal.clients',
             b'NativeAdrenoMetal', b'AdrenoMetal', b'metal2vulkan', b'Turnip', b'turnip'):
    print('  %-28s %s' % (name.decode(), '有' if name in data else '没有'))
print()
print('  前 32 字节:', data[:32].hex())
print('  大小:', len(data))
PY
