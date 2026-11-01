#!/usr/bin/env python3
"""Run / watch / fetch the OddlyLabs image job on our fork (yigezhong011-ops/fuxi-touch, branch image-ours).
Usage: oddly-image-ci.py status | dispatch | download <run-id> <dir> [owner/repo]
       oddly-image-ci.py joblog <run-id> <owner/repo> [grep-word]   (log of the failed job; error lines)"""
import io
import json
import pathlib
import sys
import urllib.error
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch'
BRANCH = 'image-ours'
API = f'https://api.github.com/repos/{REPO}'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None, raw=False):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'}, method=method,
                                 data=json.dumps(data).encode() if data is not None else None)
    with urllib.request.urlopen(req, timeout=300) as r:
        body = r.read()
        if raw:
            return body
        return json.loads(body) if body.strip() else {}


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def fetch_artifact(url):
    """The archive URL answers 302 to blob storage, which rejects our GitHub Authorization header."""
    req = urllib.request.Request(url, headers=H)
    try:
        urllib.request.build_opener(_NoRedirect).open(req, timeout=300)
        raise SystemExit('expected a redirect for ' + url)
    except urllib.error.HTTPError as e:
        if e.code not in (301, 302, 303, 307, 308):
            raise
        location = e.headers['Location']
    with urllib.request.urlopen(urllib.request.Request(location, headers={'User-Agent': 'dsh'}), timeout=600) as r:
        return r.read()


def workflow_id():
    wfs = call(f'{API}/actions/workflows')['workflows']
    return next(w for w in wfs if w['path'].endswith('/build.yml'))


cmd = sys.argv[1] if len(sys.argv) > 1 else 'status'
if cmd == 'status':
    perms = call(f'{API}/actions/permissions')
    print('actions enabled:', perms.get('enabled'))
    runs = call(f'{API}/actions/runs?branch={BRANCH}&per_page=5')['workflow_runs']
    for r in runs:
        print(r['id'], r['name'], r['event'], r['status'], r['conclusion'], r['created_at'], r['html_url'])
        for j in call(f"{API}/actions/runs/{r['id']}/jobs")['jobs']:
            step = next((s['name'] for s in j['steps'] if s['status'] == 'in_progress'), '')
            failed = [s['name'] for s in j['steps'] if s['conclusion'] == 'failure']
            print('   ', j['name'], j['status'], j['conclusion'], step, failed or '')
elif cmd == 'dispatch':
    wf = workflow_id()
    print('workflow', wf['id'], wf['state'])
    try:
        call(f"{API}/actions/workflows/{wf['id']}/dispatches", 'POST', {'ref': BRANCH})
        print('dispatched on', BRANCH)
    except urllib.error.HTTPError as e:
        print('failed', e.code, e.read().decode()[:300])
elif cmd == 'joblog':
    run_id, api = sys.argv[2], f'https://api.github.com/repos/{sys.argv[3]}'
    word = sys.argv[4] if len(sys.argv) > 4 else None
    for j in call(f'{api}/actions/runs/{run_id}/jobs')['jobs']:
        if j['conclusion'] != 'failure':
            continue
        text = fetch_artifact(f"{api}/actions/jobs/{j['id']}/logs").decode(errors='replace')
        pathlib.Path(f'/mnt/e/DSH-Fuxi/read/ci-{run_id}-{j["id"]}.log').write_text(text)
        lines = text.splitlines()
        hits = [l for l in lines if (word and word in l) or 'error' in l.lower()]
        print(f"== {j['name']}: {len(lines)} lines, saved to read/ci-{run_id}-{j['id']}.log")
        print('\n'.join(hits[-60:]))
elif cmd == 'download':
    run_id, out = sys.argv[2], pathlib.Path(sys.argv[3])
    if len(sys.argv) > 4:
        API = f'https://api.github.com/repos/{sys.argv[4]}'
    out.mkdir(parents=True, exist_ok=True)
    for a in call(f'{API}/actions/runs/{run_id}/artifacts')['artifacts']:
        data = fetch_artifact(a['archive_download_url'])
        target = out / a['name']
        zipfile.ZipFile(io.BytesIO(data)).extractall(target)
        print('downloaded', a['name'], '->', target, sorted(p.name for p in target.iterdir()))
