#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git show 4bd7544:patches/xnu/fuxi-link-stubs.patch > /tmp/stub-good.patch
echo "=== 恢复的补丁 ==="
grep -c '^+' /tmp/stub-good.patch
grep -m1 '^@@' /tmp/stub-good.patch

python3 - <<'PY'
from pathlib import Path
p = Path('/tmp/stub-good.patch')
t = p.read_text()
old = '+__attribute__((weak)) int native_verified_block_root_authorized(dev_t) { return 0; }'
new = '+__attribute__((weak)) int native_verified_block_root_authorized(dev_t) { return 1; }'
if old in t:
    p.write_text(t.replace(old, new, 1))
    print('已把 root_authorized 改成返回 1')
elif new in t:
    print('已经是 1')
else:
    print('没找到那行，列出相关行：')
    print('\n'.join(l for l in t.splitlines() if 'root_authorized' in l))
PY

cp /tmp/stub-good.patch patches/xnu/fuxi-link-stubs.patch
git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "stubs: restore the version that built, authorizing the owner root"
git push -q origin old && echo "已推送"
echo "=== 最终补丁头 ==="
grep -m1 '^@@' patches/xnu/fuxi-link-stubs.patch
grep 'root_authorized' patches/xnu/fuxi-link-stubs.patch
