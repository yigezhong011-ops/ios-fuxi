#!/usr/bin/env python3
"""Build the original static+system trust bundle from the two IM4P modules we
already extracted, verifying them against the hashes pinned in board.toml.

Bundle layout (from unixnu/scripts/build-original-system-trust.py):
    <u32 magic=2><u32 12><u32 12+len(static)> + static + system
"""
import hashlib
import json
import struct
from pathlib import Path

IPSW = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/ipsw/21H461')
OUT = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/build/original-static-system-trust')
STATIC = IPSW / '044-76040-038.dmg.trustcache'
SYSTEM = IPSW / '044-76034-038.dmg.trustcache'

PINNED_STATIC = '7416ca4f8377146626bb284e2133c76bee6cb4e3ee0af5d648b186235a7323a7'
PINNED_SYSTEM = '8900d6a93d7a59ce1a872a5c081e559f4240a218f97e12d44d22dda46644d68f'


def im4p_payload(data: bytes) -> bytes:
    """Return the payload of the IM4P container inside the file."""
    at = data.find(b'IM4P')
    if at < 0:
        raise SystemExit('no IM4P magic')
    length = struct.unpack_from('>I', data, at + 4)[0]
    kind = data[at + 8:at + 12]
    body = data[at + 12:at + 12 + length]
    if len(body) != length:
        raise SystemExit('truncated IM4P (%s)' % kind)
    print('  IM4P type=%s payload=%d B' % (kind.decode(errors='replace'), length))
    return body


print('=== StaticTrustCache ===')
static = im4p_payload(STATIC.read_bytes())
print('  sha256', hashlib.sha256(static).hexdigest())

print('=== SystemTrustCache ===')
system = im4p_payload(SYSTEM.read_bytes())
print('  sha256', hashlib.sha256(system).hexdigest())

ok_static = hashlib.sha256(static).hexdigest() == PINNED_STATIC
ok_system = hashlib.sha256(system).hexdigest() == PINNED_SYSTEM
print('  与 board.toml pin 的静态缓存一致:', ok_static)
print('  与 board.toml pin 的系统缓存一致:', ok_system)
if not (ok_static and ok_system):
    raise SystemExit('哈希不匹配：这两个模块不是 board.toml 要求的原始版本')

# version-2 trust module sanity: <u32 version><u32 ...><u32 count>
count = struct.unpack_from('<I', static, 20)[0]
if struct.unpack_from('<I', static)[0] != 2 or len(static) != 24 + count * 24:
    raise SystemExit('static module is not a complete version-2 module')

bundle = struct.pack('<3I', 2, 12, 12 + len(static)) + static + system
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'original-static-system.bundle').write_bytes(bundle)
(OUT / 'inputs.json').write_text(json.dumps(dict(
    original_static_sha256=PINNED_STATIC,
    original_system_sha256=PINNED_SYSTEM,
    bundle_sha256=hashlib.sha256(bundle).hexdigest(),
    own_code_entries_added=False,
    original_modules_modified=False,
), indent=2) + '\n')
print()
print('bundle:', OUT / 'original-static-system.bundle')
print('  bytes', len(bundle), ' sha256', hashlib.sha256(bundle).hexdigest())
