#!/usr/bin/env python3
"""Fix the two compile errors in the draft winsys and re-dispatch."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_drm_full.c')
src = f.read_text()

# 1) IOConnectMapMemory64 takes mach_vm_size_t *
src = src.replace(
    '\tuint64_t addr = 0;\n\tsize_t size = (size_t)b->bytes;\n',
    '\tuint64_t addr = 0;\n\tmach_vm_size_t size = (mach_vm_size_t)b->bytes;\n')

# 2) give drmCloseBufferHandle a prototype so -Wmissing-prototypes is satisfied
if 'int drmCloseBufferHandle(int fd, uint32_t handle);' not in src:
    src = src.replace(
        '/* MSM\'s GEM_CLOSE has no MSM ioctl on this path: freedreno calls close() on the handle. */\nint drmCloseBufferHandle',
        '/* MSM\'s GEM_CLOSE has no MSM ioctl on this path: freedreno calls close() on the handle. */\nint drmCloseBufferHandle(int fd, uint32_t handle);\nint drmCloseBufferHandle', 1)

f.write_text(src)
print('patched:', 'mach_vm_size_t' in src, 'prototype' if 'int drmCloseBufferHandle(int fd, uint32_t handle);' in src else 'no proto')

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


put('tools/mesa-ios/experimental/fuxi_drm.c', f.read_bytes(),
    'mesa-ios: fix mach_vm_size_t and the missing prototype in the winsys draft')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched with winsys=fuxi')
