#!/usr/bin/env python3
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def put(path, data, msg):
    url = f'{API}/contents/{path}'
    body = {'message': msg, 'content': base64.b64encode(data).decode(), 'branch': 'main'}
    try:
        req = urllib.request.Request(url, headers=H)
        cur = json.load(urllib.request.urlopen(req, timeout=30))
        body['sha'] = cur['sha']
    except Exception:
        pass
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={**H, 'Content-Type': 'application/json'}, method='PUT')
    r = json.load(urllib.request.urlopen(req, timeout=60))
    print(f'  {path} -> {r["commit"]["sha"][:8]}')


put('tools/mesa-ios/experimental/fuxi_drm.c',
    pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_drm_full.c').read_bytes(),
    'mesa-ios: draft winsys mapping libdrm msm requests onto the NativeAdreno ABI')
put('tools/mesa-ios/experimental/NativeAdrenoABI.h',
    pathlib.Path('/mnt/e/DSH-Fuxi/mesa-ios/vendor/redwood-drm/NativeAdrenoABI.h').read_bytes(),
    'mesa-ios: the kernel wire ABI the draft winsys speaks')
