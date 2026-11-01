"""List files of a GitHub repository whose path matches any keyword, or download one file (read-only).
Usage: python -I gh-find.py owner/name ref kw1,kw2      | python -I gh-find.py owner/name ref --get path out"""
import json
import sys
import urllib.request
from pathlib import Path

TOKEN = Path(r'E:\DSH-Fuxi\token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
repo, ref = sys.argv[1], sys.argv[2]
if sys.argv[3] == '--get':
    req = urllib.request.Request(f'https://api.github.com/repos/{repo}/contents/{sys.argv[4]}?ref={ref}',
                                 headers={**H, 'Accept': 'application/vnd.github.raw'})
    data = urllib.request.urlopen(req, timeout=120).read()
    Path(sys.argv[5]).write_bytes(data)
    print(f'{sys.argv[4]}: {len(data)} bytes -> {sys.argv[5]}')
else:
    req = urllib.request.Request(f'https://api.github.com/repos/{repo}/git/trees/{ref}?recursive=1', headers=H)
    tree = json.loads(urllib.request.urlopen(req, timeout=120).read())['tree']
    kws = [k.lower() for k in sys.argv[3].split(',')]
    for t in tree:
        if any(k in t['path'].lower() for k in kws):
            print(t['type'], t.get('size', ''), t['path'])
