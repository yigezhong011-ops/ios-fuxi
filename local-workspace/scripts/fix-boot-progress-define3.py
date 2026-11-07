#!/usr/bin/env python3
"""The compile record already defines XNU_BOOT_PROGRESS=0, which selects the stub
macros. Undefine it before defining it to 1 so there is no redefinition."""
from pathlib import Path

p = Path('/root/fuxi/fork-device/scripts/build-boot-progress.py')
t = p.read_text()
old = "'-DXNU_BOOT_PROGRESS=1',"
new = "'-UXNU_BOOT_PROGRESS', '-DXNU_BOOT_PROGRESS=1',"
if '-UXNU_BOOT_PROGRESS' in t:
    print('已经改过')
else:
    n = t.count(old)
    t = t.replace(old, new)
    p.write_text(t)
    print('替换处数:', n)

import subprocess
subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'add', '-A'], check=False)
subprocess.run(['git', '-C', '/root/fuxi/fork-device', '-c', 'user.name=dsh',
                '-c', 'user.email=dsh@local', 'commit', '-qm',
                'scripts: undefine the zero XNU_BOOT_PROGRESS before setting it'], check=False)
r = subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:100])
