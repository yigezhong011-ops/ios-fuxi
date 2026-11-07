#!/usr/bin/env python3
"""What does UniXNU's fix/gpu-scheduling-and-metal branch change?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
BRANCH = 'fix/gpu-scheduling-and-metal'
REPO = 'UniXNU/UniXNU'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


branches = api(f'https://api.github.com/repos/{REPO}/branches?per_page=100')
if isinstance(branches, list):
    names = [b['name'] for b in branches]
    print('分支总数', len(names))
    hits = [n for n in names if 'gpu' in n or 'metal' in n or 'fix' in n]
    print('相关内容:', hits[:12])

info = api(f'https://api.github.com/repos/{REPO}/branches/{BRANCH.replace("/", "%2F")}')
if 'commit' in info:
    print('\n分支', BRANCH, 'HEAD', info['commit']['sha'][:10])
    print('  提交:', info['commit']['commit']['message'].splitlines()[0][:120])
    print('  日期:', info['commit']['commit']['author']['date'])
else:
    print('\n分支查询:', info)

# compare with main
cmp = api(f'https://api.github.com/repos/{REPO}/compare/main...{BRANCH.replace("/", "%2F")}')
if 'commits' in cmp:
    print('\n领先 main %d 个提交，%d 个文件' % (cmp['ahead_by'], len(cmp.get('files', []))))
    for c in cmp['commits'][-12:]:
        print('  %s %s' % (c['sha'][:8], c['commit']['message'].splitlines()[0][:110]))
    for f in cmp.get('files', [])[:15]:
        print('  %-58s +%d/-%d' % (f['filename'][:58], f['additions'], f['deletions']))
else:
    print('\n比较:', cmp)
