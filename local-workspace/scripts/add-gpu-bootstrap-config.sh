#!/bin/bash
# Pass 1 needs a kernel that links without the PMGR archive (no candidate yet);
# the real configuration runs once the candidate exists.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

python3 - <<'PY'
from pathlib import Path

base = Path('configs/fuxi_gpu_defconfig').read_text()
lines = []
for line in base.splitlines():
    if line.startswith('CONFIG_XNU_SHENG_PMGR'):
        lines.append('CONFIG_XNU_SHENG_PMGR=n')
    else:
        lines.append(line)
header = ('# Bootstrap pass for the *GPU* configuration: identical to\n'
          '# fuxi_gpu_defconfig except that the Sheng PMGR archive is off, because that\n'
          '# archive needs the prelink candidate this pass produces.\n')
Path('configs/fuxi_gpu_bootstrap_defconfig').write_text(header + '\n'.join(lines) + '\n')
print('已生成 configs/fuxi_gpu_bootstrap_defconfig')
PY

grep -n 'SHENG_PMGR' configs/fuxi_gpu_bootstrap_defconfig configs/fuxi_gpu_defconfig

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "configs: add a GPU bootstrap configuration without the PMGR archive"
git push -q origin old
echo "已推送"
