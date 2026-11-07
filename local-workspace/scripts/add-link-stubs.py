#!/usr/bin/env python3
"""Add a link-stub builder and a bootstrap defconfig to the device fork: a kernel
that links without the archive chain, purely to produce the prelink candidate the
full build's audits compare against."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


def put(path, text, message, branch='old'):
    try:
        cur = call(f'https://api.github.com/repos/{REPO}/contents/{path}?ref={branch}')
        sha = cur['sha']
    except Exception:
        sha = None
    body = {'message': message, 'content': base64.b64encode(text.encode()).decode(), 'branch': branch}
    if sha:
        body['sha'] = sha
    r = call(f'https://api.github.com/repos/{REPO}/contents/{path}', method='PUT', data=body)
    print('  ', path, '->', r['commit']['sha'][:8])


BUILDER = '''#!/usr/bin/env python3
"""Build a stub archive for the symbols the bootstrap kernel references but whose
real providers are archives that need a prelink candidate (chicken and egg).

The kernel produced with these stubs is only used to generate the prelink
candidate: the stubs are never meant to run.
"""
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'build/fuxi-link-stubs'
OUT.mkdir(parents=True, exist_ok=True)

STUBS = """
/* Link-only stubs: one definition per symbol the bootstrap configuration
 * references while its real archives need a prelink candidate to build. */
void native_legacy_display_probe(void) {}
void boot_log_tick(void) {}
void fuxi_usb_append(void) {}
void fuxi_usb_debug_start(void) {}
void sheng_pmgr_run(void) {}
"""

(OUT / 'stubs.c').write_text(STUBS)
sdk = subprocess.check_output(['xcrun', '--sdk', 'iphoneos', '--show-sdk-path'], text=True).strip()
subprocess.run(['xcrun', 'clang', '-target', 'arm64-apple-ios17.0', '-isysroot', sdk,
                '-mkernel', '-O2', '-c', str(OUT / 'stubs.c'), '-o', str(OUT / 'stubs.o')], check=True)
archive = OUT / 'libFuxiLinkStubs.a'
archive.unlink(missing_ok=True)
subprocess.run(['xcrun', 'ar', 'rcs', str(archive), str(OUT / 'stubs.o')], check=True)
print('stub archive:', archive)
'''

DEFCONFIG = """# Bootstrap configuration: link without the archive chain and prelink, purely to
# produce build/native-prelink/*-candidate.macho for the full build.
CONFIG_XNU_BUILD_ARCHIVES=n
CONFIG_XNU_BOOT_PROGRESS=n
CONFIG_XNU_SOURCE_CORECRYPTO14=y
CONFIG_XNU_SOURCE_PTHREAD=y
CONFIG_XNU_ARM_DT_PLATFORM=y
CONFIG_XNU_ARMCPU=y
CONFIG_XNU_NATIVE_AES=y
CONFIG_XNU_TRUST_CACHE_RUNTIME=y
CONFIG_XNU_DT_PANIC_REGION=y
CONFIG_XNU_NATIVE_ARCH_TIMER=y
CONFIG_XNU_NATIVE_PAN=y
CONFIG_XNU_NATIVE_UFS=n
CONFIG_XNU_CRYPTO_BOOTSTRAP="prelinked"
CONFIG_XNU_EXTRA_LD_ARCHIVES="{tree}/build/fuxi-link-stubs/libFuxiLinkStubs.a"
"""

print('写入文件:')
put('scripts/build-fuxi-link-stubs.py', BUILDER,
    'scripts: build a link-only stub archive for the bootstrap kernel')
put('configs/fuxi_bootstrap_defconfig', DEFCONFIG,
    'configs: bootstrap defconfig that links with stubs only')
