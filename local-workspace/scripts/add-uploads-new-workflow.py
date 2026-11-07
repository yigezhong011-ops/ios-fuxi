#!/usr/bin/env python3
"""Add kernel and payload upload steps to the freshly synced workflow."""
import subprocess
from pathlib import Path

W = Path('/root/fuxi/uni-fork')
p = W / '.github/workflows/macos.yml'
t = p.read_text()

anchor = '      - name: Upload the build logs'
if 'Upload the built kernel' in t:
    print('已经加过')
else:
    insert = '''      - name: Upload the built kernel
        if: always() && steps.kernel.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-${{ steps.check.outputs.board }}-kernel
          path: |
            out/*/kernel/kernel.macho
            out/*/kernel/kernel.json
          if-no-files-found: warn
          retention-days: 7

      - name: Upload the built payload
        if: always() && steps.payload.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-${{ steps.check.outputs.board }}-payload
          path: |
            out/*/payload/payload.img
          if-no-files-found: warn
          retention-days: 7

'''
    if anchor not in t:
        raise SystemExit('找不到日志上传那一步')
    t = t.replace(anchor, insert + anchor, 1)
    p.write_text(t)
    print('已加入内核与 payload 上传')

subprocess.run(['git', '-C', str(W), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(W), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'ci: upload the built kernel and payload'], check=False)
r = subprocess.run(['git', '-C', str(W), 'push', '-q', '-f', 'origin', 'main'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:150])
print(subprocess.run(['git', '-C', str(W), 'log', '--oneline', '-1'],
                     capture_output=True, text=True).stdout.strip()[:100])
