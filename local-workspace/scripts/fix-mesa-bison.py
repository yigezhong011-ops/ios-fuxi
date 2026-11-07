#!/usr/bin/env python3
"""Install a modern bison/flex on the runner, then re-dispatch."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
REPO = 'pyhs5g27vr-hue/ios-fuxi'
API = f'https://api.github.com/repos/{REPO}'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh')
src = p.read_text()
if 'brew install bison' not in src:
    src = src.replace(
        'mkdir -p "$B"\ncd "$B"\n',
        '''# macOS ships bison 2.3, which cannot parse Mesa's %code directives
if ! bison --version 2>/dev/null | head -1 | grep -qE '3\\.|4\\.|5\\.'; then
  echo "=== installing bison/flex from Homebrew ==="
  brew install bison flex >/dev/null 2>&1 || true
  export PATH="$(brew --prefix bison)/bin:$(brew --prefix flex)/bin:$PATH"
fi
bison --version | head -1

mkdir -p "$B"
cd "$B"
''', 1)
    p.write_text(src)
    print('added bison/flex bootstrap')
else:
    print('already present')


def put(path, data: bytes, message):
    url = f'{API}/contents/{path}'
    body = {'message': message, 'content': base64.b64encode(data).decode(), 'branch': 'main'}
    try:
        req = urllib.request.Request(url, headers=H)
        cur = json.load(urllib.request.urlopen(req, timeout=30))
        body['sha'] = cur['sha']
    except Exception:
        pass
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={**H, 'Content-Type': 'application/json'}, method='PUT')
    r = json.load(urllib.request.urlopen(req, timeout=60))
    print(f'  pushed {path} -> {r["commit"]["sha"][:8]}')


put('tools/mesa-ios/build.sh', p.read_bytes(), 'mesa-ios: install bison 3+ (macOS ships 2.3)')
disp = json.dumps({'ref': 'main'}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched')
