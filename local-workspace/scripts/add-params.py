#!/usr/bin/env python3
"""Add TIMESTAMP and PP_PGTABLE to get_param, rebuild with winsys=fuxi."""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_drm_full.c')
src = f.read_text()

old = '''	case MSM_PARAM_FAULTS:     *value = 0; break;'''
new = '''	case MSM_PARAM_FAULTS:     *value = 0; break;
	case MSM_PARAM_TIMESTAMP: {
		struct NativeAdrenoAbiTimestamp ts = { 0 };
		if (abi_call(NativeAdrenoMethodGetTimestamp, NULL, 0, &ts, sizeof(ts)) != 0) {
			return -ENODEV;
		}
		*value = ts.ticks;
		break;
	}
	case MSM_PARAM_PP_PGTABLE: *value = 1; break;   /* our ABI maps per client */
	case MSM_PARAM_NR_RINGS:   *value = 1; break;   /* one queue per client */'''

if 'MSM_PARAM_TIMESTAMP' in src:
    print('already present')
else:
    assert old in src, 'anchor missing'
    src = src.replace(old, new, 1)
    f.write_text(src)
    print('added TIMESTAMP / PP_PGTABLE / NR_RINGS')

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
    'mesa-ios: answer TIMESTAMP, PP_PGTABLE and NR_RINGS from the ABI')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched with winsys=fuxi')
