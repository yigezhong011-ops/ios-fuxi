#!/usr/bin/env python3
"""The GOP on this board reports a stride that does not match the panel; the kernel
console must use width*4 or every glyph is drawn at the wrong offset."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
subprocess.run(['git', '-C', str(DEV), 'fetch', '-q', 'origin', 'old'], check=False)
subprocess.run(['git', '-C', str(DEV), 'reset', '-q', '--hard', 'origin/old'], check=False)

p = DEV / 'package/BootProgress.c'
text = p.read_text()
old = 'display.frame=base;display.width=w;display.height=h;display.stride=rb;display.scale=w>=2160 && h>=1400?3:1;'
if old not in text:
    # print the actual line for diagnosis
    for line in text.splitlines():
        if 'display.stride' in line:
            print('实际行:', line.strip()[:200])
    raise SystemExit('找不到那条赋值')

new = ('display.frame=base;display.width=w;display.height=h;\n'
       '    /* The firmware GOP on this board reports a scanline shorter than the\n'
       '     * panel: use the real 4-byte pixel stride or every glyph lands at the\n'
       '     * wrong offset. */\n'
       '    display.stride=(uint64_t)w*4;\n'
       '    display.scale=w>=2160 && h>=1400?3:1;')
p.write_text(text.replace(old, new, 1))
print('已改 display.stride = w*4')

subprocess.run(['git', '-C', str(DEV), 'add', '-f', 'package/BootProgress.c'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'package: use the real pixel stride for the kernel console'], check=False)
r = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:150])
