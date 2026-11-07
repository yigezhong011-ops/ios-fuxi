#!/usr/bin/env python3
"""Point the payload patch script at the device copy of the UEFI font."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
TREE = Path('/root/ux3/fuxi/tree')
target = DEV / 'scripts/patch-xnu-entry-probe.py'

subprocess.run(['git', '-C', str(DEV), 'fetch', '-q', 'origin', 'old'], check=False)
subprocess.run(['git', '-C', str(DEV), 'reset', '-q', '--hard', 'origin/old'], check=False)

text = (TREE / 'scripts/patch-xnu-entry-probe.py').read_text()
head = ('import os as _os\n'
        'from pathlib import Path as _Path\n'
        '# The payload step needs the UEFI frame-buffer font; the tree is rebuilt before\n'
        '# this runs, so keep it in the device repository.\n'
        '_os.environ.setdefault("UNIXNU_UEFI", str(_Path(__file__).resolve().parents[1] / "uefi-fonts"))\n')
target.write_text(head + text)
print('写入 %d 字节，含 setdefault: %s' % (target.stat().st_size, 'setdefault' in target.read_text()))

subprocess.run(['git', '-C', str(DEV), 'add', '-f', 'scripts/patch-xnu-entry-probe.py'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'scripts: point the payload patch at the device font copy'], check=False)
r = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:150])
print(subprocess.run(['git', '-C', str(DEV), 'log', '--oneline', '-1'],
                     capture_output=True, text=True).stdout.strip())
