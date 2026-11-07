#!/usr/bin/env python3
"""Append the libdrm stubs the freedreno link needs, then rebuild."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_drm_full.c')
src = f.read_text()

stubs = r'''
/* ---- what fuxi has no equivalent for ---------------------------------
 *
 * dmabufs and drm_syncobj timelines. The reference shim (redwood_drm.c) returns
 * -1 from the same calls and freedreno falls back to implicit fences, so these
 * keep that behaviour; the IOSurface import (BoImport in our ABI) is Turnip's
 * path and belongs to a winsys with surfaces, not to GL.
 */
#define UNUSED __attribute__((unused))

int drmPrimeHandleToFD(UNUSED int fd, UNUSED uint32_t handle, UNUSED uint32_t flags, UNUSED int *prime_fd)
{
	return -ENOSYS;
}

int drmSyncobjCreate(UNUSED int fd, UNUSED uint32_t flags, UNUSED uint32_t *handle)
{
	return -ENOSYS;
}

int drmSyncobjDestroy(UNUSED int fd, UNUSED uint32_t handle)
{
	return -ENOSYS;
}

int drmSyncobjReset(UNUSED int fd, UNUSED const uint32_t *handles, UNUSED uint32_t count)
{
	return -ENOSYS;
}

int drmSyncobjFDToHandle(UNUSED int fd, UNUSED int obj_fd, UNUSED uint32_t *handle)
{
	return -ENOSYS;
}

int drmSyncobjHandleToFD(UNUSED int fd, UNUSED uint32_t handle, UNUSED int *obj_fd)
{
	return -ENOSYS;
}

int drmSyncobjImportSyncFile(UNUSED int fd, UNUSED uint32_t handle, UNUSED int sync_file_fd)
{
	return -ENOSYS;
}

int drmSyncobjExportSyncFile(UNUSED int fd, UNUSED uint32_t handle, UNUSED int *sync_file_fd)
{
	return -ENOSYS;
}

int drmSyncobjWait(UNUSED int fd, UNUSED uint32_t *handles, UNUSED unsigned num_handles,
                   UNUSED int64_t timeout_nsec, UNUSED unsigned flags, UNUSED uint32_t *first_signaled)
{
	return -ENOSYS;
}

int drmSyncobjSignal(UNUSED int fd, UNUSED const uint32_t *handles, UNUSED uint32_t handle_count)
{
	return -ENOSYS;
}

int drmSyncobjTimelineSignal(UNUSED int fd, UNUSED const uint32_t *handles, UNUSED uint64_t *points,
                             UNUSED uint32_t handle_count)
{
	return -ENOSYS;
}

int drmSyncobjTimelineWait(UNUSED int fd, UNUSED uint32_t *handles, UNUSED uint64_t *points,
                           UNUSED unsigned num_handles, UNUSED int64_t timeout_nsec, UNUSED unsigned flags,
                           UNUSED uint32_t *first_signaled)
{
	return -ENOSYS;
}

int drmSyncobjQuery(UNUSED int fd, UNUSED uint32_t *handles, UNUSED uint64_t *points, UNUSED uint32_t handle_count)
{
	return -ENOSYS;
}

int drmSyncobjQuery2(UNUSED int fd, UNUSED uint32_t *handles, UNUSED uint64_t *points,
                     UNUSED uint32_t handle_count, UNUSED uint32_t flags)
{
	return -ENOSYS;
}

int drmSyncobjTransfer(UNUSED int fd, UNUSED uint32_t dst_handle, UNUSED uint64_t dst_point,
                       UNUSED uint32_t src_handle, UNUSED uint64_t src_point, UNUSED uint32_t flags)
{
	return -ENOSYS;
}

/* struct redwood_drm_surface is declared by the vendored xf86drm.h */
int redwood_drm_surface(UNUSED int fd, UNUSED struct redwood_drm_surface *surface)
{
	return -ENOSYS;
}
'''

if 'drmSyncobjQuery2' not in src:
    src = src.rstrip() + '\n' + stubs
    f.write_text(src)
    print('stubs appended')
else:
    print('stubs already present')

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


put('tools/mesa-ios/experimental/fuxi_drm.c', f.read_bytes(), 'mesa-ios: stubs for what fuxi has no equivalent for')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched with winsys=fuxi')
