#!/usr/bin/env python3
"""Find the real failure in the finished run 41737636080."""
import json
import pathlib
import re
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/unixnu-ci'
RUN = '41737636080'


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


job = api(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs')['jobs'][0]
opener = urllib.request.build_opener(NoRedirect)
try:
    opener.open(urllib.request.Request(
        f'https://api.github.com/repos/{REPO}/actions/jobs/{job["id"]}/logs', headers=H), timeout=60)
except urllib.error.HTTPError as e:
    location = e.headers['Location']
with urllib.request.urlopen(location, timeout=300) as r:
    lines = r.read().decode('utf-8', 'replace').splitlines()

pathlib.Path('/root/fuxi/ci-job.log').write_text('\n'.join(lines))
print('日志 %d 行，已存 /root/fuxi/ci-job.log' % len(lines))

tb = [i for i, l in enumerate(lines) if 'Traceback (most recent call last)' in l]
print('Traceback 行号:', [t + 1 for t in tb][:6])
# the last error-ish lines before the final failure
cands = [i for i, l in enumerate(lines)
         if re.search(r'error:|Error:|fatal error|failed|FAIL|Aborting|cannot|No such', l, re.I)]
print('错误候选 %d 处，最后 14 处:' % len(cands))
for i in cands[-14:]:
    print('%5d| %s' % (i + 1, lines[i][:200]))
