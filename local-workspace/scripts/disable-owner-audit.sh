#!/bin/bash
# The owner-root audit requires the verified-root probe; this port skips owner
# root auth entirely, so neither is enabled.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git fetch -q origin old && git reset -q --hard origin/old

grep -n 'OWNER_ROOT' configs/fuxi_gpu_defconfig || echo "  （defconfig 里没有 OWNER_ROOT 行）"

python3 - <<'PY'
from pathlib import Path
p = Path('configs/fuxi_gpu_defconfig')
t = p.read_text()
if 'CONFIG_XNU_OWNER_ROOT_AUDIT' in t:
    t = t.replace('CONFIG_XNU_OWNER_ROOT_AUDIT=y', 'CONFIG_XNU_OWNER_ROOT_AUDIT=n')
else:
    t = t.rstrip('\n') + '\nCONFIG_XNU_OWNER_ROOT_AUDIT=n\n'
p.write_text(t)
print('已设置 OWNER_ROOT_AUDIT=n')
PY

grep -n 'OWNER_ROOT\|VERIFIED_ROOT' configs/fuxi_gpu_defconfig

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "configs: skip the owner-root audit together with the verified-root probe"
git push origin old && echo "已推送"
