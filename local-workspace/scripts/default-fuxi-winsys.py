#!/usr/bin/env python3
"""Default the winsys input to fuxi (the one that speaks our kernel ABI)."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

url = f'{API}/contents/.github/workflows/mesa-ios.yml'
cur = json.load(urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30))
text = base64.b64decode(cur['content']).decode()
text = text.replace('        default: redwood', '        default: fuxi')
body = {'message': 'mesa-ios: default to the fuxi winsys', 'content': base64.b64encode(text.encode()).decode(),
        'sha': cur['sha'], 'branch': 'main'}
req = urllib.request.Request(url, data=json.dumps(body).encode(),
                             headers={**H, 'Content-Type': 'application/json'}, method='PUT')
r = json.load(urllib.request.urlopen(req, timeout=60))
print('workflow default ->', r['commit']['sha'][:8])
print([l for l in text.splitlines() if 'default:' in l])
