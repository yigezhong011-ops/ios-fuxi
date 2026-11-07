#!/bin/bash
# The board runs with owner root auth skipped, so the verified-root probe archive
# is not needed; requiring it forces an archive chain the port does not carry.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git fetch -q origin old && git reset -q --hard origin/old

python3 - <<'PY'
from pathlib import Path
p = Path('configs/fuxi_gpu_defconfig')
t = p.read_text()
before = t
t = t.replace('CONFIG_XNU_VERIFIED_ROOT_PROBE=y', 'CONFIG_XNU_VERIFIED_ROOT_PROBE=n')
t = '\n'.join(l for l in t.splitlines()
              if not l.startswith('CONFIG_XNU_VERIFIED_ROOT_ARCHIVE'))
p.write_text(t if t.endswith('\n') else t + '\n')
print('已关闭 VERIFIED_ROOT_PROBE；变化:', before != t)
PY

tail -3 configs/fuxi_gpu_defconfig
grep -n 'VERIFIED_ROOT' configs/fuxi_gpu_defconfig || echo "  已无 VERIFIED_ROOT 行"

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "configs: build without the verified-root probe (the board skips owner root auth)"
git push origin old && echo "已推送"
