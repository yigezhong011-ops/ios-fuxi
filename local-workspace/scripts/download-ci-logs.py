#!/usr/bin/env python3
"""Download the build's log artifact and show the bootstrap link failure."""
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        return r.read()


runs = json.loads(call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1'))['workflow_runs']
run = runs[0]
print('run', run['id'], run['conclusion'])
arts = json.loads(call(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/artifacts'))
for a in arts['artifacts']:
    print('  artifact:', a['name'], a['size_in_bytes'], 'bytes')

target = next((a for a in arts['artifacts'] if 'log' in a['name'].lower()), None)
if not target:
    raise SystemExit('没有日志产物')

data = call(target['archive_download_url'])
out = pathlib.Path('/root/ci-logs.zip')
out.write_bytes(data)
print('已下载', len(data), '字节')

with zipfile.ZipFile(out) as z:
    names = z.namelist()
    print('压缩包内文件:', names[:6])
    boot = next((n for n in names if 'bootstrap' in n), None)
    if boot:
        text = z.read(boot).decode('utf-8', 'replace')
        lines = text.splitlines()
        print('=== bootstrap 日志 %d 行，尾部 ===' % len(lines))
        for line in lines[-30:]:
            print('   ', line[:170])
