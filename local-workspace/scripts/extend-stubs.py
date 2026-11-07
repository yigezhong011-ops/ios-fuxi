#!/usr/bin/env python3
"""Extend the link-only stubs to every symbol the bootstrap kernel references."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = 'scripts/build-fuxi-link-stubs.py'

STUBS = '''
/* Link-only stubs. Every symbol here is normally provided by an archive whose
 * build needs the prelink candidate this kernel exists to produce, so the
 * bootstrap configuration answers them locally instead. The stubs never run:
 * the kernel is only prelinked to become that candidate. */
void native_legacy_display_probe(void) {}
void boot_log_tick(void) {}
void fuxi_usb_append(void) {}
void fuxi_usb_debug_start(void) {}
void sheng_pmgr_run(void) {}
void native_mobile_graphics_client_probe(void) {}
void native_gpu_addon_prepare(void) {}
void native_owner_publish_boot_manifest(void) {}
void native_verified_block_root_authorized(void) {}
void native_verified_root_probe(void) {}
void native_verified_block_volume_device(void) {}
unsigned char native_ram_block_gpu_addon[16];
unsigned char native_ram_block_volume_seed[16];
unsigned char native_verified_block_manifest_sha384[48];
'''


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref=old')
text = base64.b64decode(cur['content']).decode()

start = text.find('STUBS = """')
end = text.find('"""', start + len('STUBS = """')) + 3
if start < 0 or end < 3:
    raise SystemExit('找不到 STUBS 块')

text = text[:start] + 'STUBS = """' + STUBS + '"""' + text[end:]
body = {'message': 'stubs: answer every symbol the bootstrap kernel references',
        'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': 'old'}
r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
print('已提交', r['commit']['sha'][:8])
for line in text.splitlines():
    if line.startswith('void ') or line.startswith('unsigned char'):
        print('  ', line[:80])
