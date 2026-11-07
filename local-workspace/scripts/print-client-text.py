#!/usr/bin/env python3
"""Print the client's diagnostic text on the kernel console.

The GPU client (FuxiMetal) writes its problems into a BO's metadata (ABI method
SetMetadata); the kernel stored it but never printed it, so the FUXI MTL lines
were invisible on the screen console. This prints them as they arrive.
"""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

path = 'xnu/fuxi-adreno/FuxiAdrenoUserClient.cpp'
cur = json.load(urllib.request.urlopen(
    urllib.request.Request(f'{API}/contents/{path}', headers=H), timeout=60))
txt = base64.b64decode(cur['content']).decode()

old = ('   if (method==NativeAdrenoMethodSetMetadata) { bcopy(r.text,b->metadata,r.bytes); b->metadataBytes=r.bytes; }\n')
new = ('   if (method==NativeAdrenoMethodSetMetadata) {\n'
       '    bcopy(r.text,b->metadata,r.bytes); b->metadataBytes=r.bytes;\n'
       '    /* the client\'s own diagnosis, on the console: this is the only channel\n'
       '     * a userland GPU client has when it refuses a command */\n'
       '    if (r.bytes) printf("FUXI CLIENT: %.*s\\n", (int)r.bytes, r.text);\n'
       '   }\n')
assert old in txt, 'anchor missing'
assert 'FUXI CLIENT:' not in txt, 'already patched'
txt = txt.replace(old, new, 1)

body = {'message': 'gpu: print the client diagnostic text on the console',
        'content': base64.b64encode(txt.encode()).decode(), 'sha': cur['sha'], 'branch': 'main'}
req = urllib.request.Request(f'{API}/contents/{path}', data=json.dumps(body).encode(),
                             headers={**H, 'Content-Type': 'application/json'}, method='PUT')
r = json.load(urllib.request.urlopen(req, timeout=60))
print('pushed', r['commit']['sha'][:8])
