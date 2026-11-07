#!/usr/bin/env python3
"""Make the weak stub authorize the root: with XNU_OWNER_ROOT_TRUST=y the kernel
assigns owner_authorized from this answer instead of panicking."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
patch = DEV / 'patches/xnu/fuxi-link-stubs.patch'
text = patch.read_text()

old = '+__attribute__((weak)) int native_verified_block_root_authorized(dev_t) { return 0; }'
new = '+__attribute__((weak)) int native_verified_block_root_authorized(dev_t) { return 1; }'
if old in text:
    patch.write_text(text.replace(old, new, 1))
    print('已改为 return 1')
elif new in text:
    print('已经是 return 1')
else:
    for line in text.splitlines():
        if 'root_authorized' in line:
            print('实际行:', line[:160])
    raise SystemExit('没找到那行')

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'stubs: authorize the owner root'], check=False)
r = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:200])
print(subprocess.run(['git', '-C', str(DEV), 'log', '--oneline', '-1'],
                     capture_output=True, text=True).stdout.strip()[:100])
