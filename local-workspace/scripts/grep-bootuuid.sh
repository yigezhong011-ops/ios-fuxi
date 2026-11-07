#!/bin/bash
set -uo pipefail
echo "=== kernel 里 boot-uuid / bootsessionuuid 的实现 ==="
grep -rn 'boot-uuid\|boot_uuid\|bootsessionuuid\|bootsession' /root/ios-fuxi/xnu /root/ios-fuxi/shim 2>/dev/null | head -12
echo
echo "=== loader 里有没有写 boot-uuid ==="
grep -rn 'uuid' /root/ios-fuxi/shim/fuxi-loader/*.c /root/ios-fuxi/shim/fuxi-probe/*.c 2>/dev/null | head -10
echo
echo "=== ADT 里是否有 boot-uuid 属性 ==="
python3 - <<'PY'
import re
p='/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt'
data=open(p,'rb').read()
print('ADT 大小:', len(data))
for key in (b'boot-uuid', b'boot-uuid-string', b'iommu', b'chosen'):
    print(key.decode(), '出现次数:', data.count(key))
PY
