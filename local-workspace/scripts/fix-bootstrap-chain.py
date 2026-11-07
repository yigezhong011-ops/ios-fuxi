#!/usr/bin/env python3
"""Fix the bootstrap path chain: the stub archive must live in the build tree
(where CONFIG_XNU_EXTRA_LD_ARCHIVES points) and the source archives that only
the full chain produces must be off."""
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
"""Build a link-only stub archive for the symbols whose real providers are
archives that need a prelink candidate to build (a chicken-and-egg the bootstrap
configuration has to break). The kernel built with these stubs is only used to
produce the prelink candidate; the stubs never run.
"""
import argparse
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--out', type=Path, default=None,
                    help='output directory (default: <repo>/build/fuxi-link-stubs)')
args = parser.parse_args()

ROOT = Path(__file__).resolve().parents[1]
OUT = args.out or (ROOT / 'build/fuxi-link-stubs')
OUT = OUT if OUT.is_absolute() else (Path.cwd() / OUT)
OUT.mkdir(parents=True, exist_ok=True)

STUBS = """
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

DEFCONFIG = """# Bootstrap configuration: link with stubs only and prelink, purely to produce
# build/native-prelink/*-candidate.macho for the full build. The source archives
# are off because only the archive chain produces them, and the chain is what
# this configuration has to bootstrap.
CONFIG_XNU_BUILD_ARCHIVES=n
CONFIG_XNU_BOOT_PROGRESS=n
CONFIG_XNU_SOURCE_CORECRYPTO14=n
CONFIG_XNU_SOURCE_PTHREAD=n
CONFIG_XNU_ARM_DT_PLATFORM=n
CONFIG_XNU_ARMCPU=n
CONFIG_XNU_NATIVE_AES=n
CONFIG_XNU_TRUST_CACHE_RUNTIME=y
CONFIG_XNU_DT_PANIC_REGION=y
CONFIG_XNU_NATIVE_ARCH_TIMER=y
CONFIG_XNU_NATIVE_PAN=y
CONFIG_XNU_NATIVE_UFS=n
CONFIG_XNU_CRYPTO_BOOTSTRAP="prelinked"
CONFIG_XNU_EXTRA_LD_ARCHIVES="{tree}/build/fuxi-link-stubs/libFuxiLinkStubs.a"
"""

print('更新:')
put('scripts/build-fuxi-link-stubs.py', BUILDER,
    'scripts: let the link-stub builder target the build tree')
put('configs/fuxi_bootstrap_defconfig', DEFCONFIG,
    'configs: bootstrap links with stubs only, no source archives')
