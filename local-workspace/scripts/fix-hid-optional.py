#!/usr/bin/env python3
"""The display archive records the NativeHidInput driver in its evidence list; a
board without that component has no such file, so list it only when present."""
import subprocess
from pathlib import Path

p = Path('/root/fuxi/fork-device/scripts/build-native-legacy-display.py')
t = p.read_text()
old = "         ROOT/'drivers/NativeHidInput/NativeHidInput.cpp',ROOT/'scripts/build-native-hid-input.py',"
new = ("         *([ROOT/'drivers/NativeHidInput/NativeHidInput.cpp']\n"
       "           if (ROOT/'drivers/NativeHidInput/NativeHidInput.cpp').exists() else []),\n"
       "         *([ROOT/'scripts/build-native-hid-input.py']\n"
       "           if (ROOT/'scripts/build-native-hid-input.py').exists() else []),")
if 'if (ROOT / ' in t or "if (ROOT/'drivers/NativeHidInput" in t:
    print('已经改过')
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print('已改为按存在性收录 HID 输入')
else:
    raise SystemExit('找不到该行')

subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'add', '-A'], check=False)
subprocess.run(['git', '-C', '/root/fuxi/fork-device', '-c', 'user.name=dsh',
                '-c', 'user.email=dsh@local', 'commit', '-qm',
                'scripts: list the HID input driver only when the board has it'], check=False)
r = subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:120])
