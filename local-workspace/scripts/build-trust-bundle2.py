#!/usr/bin/env python3
"""Build the original static+system trust bundle from the two trust-cache
modules, verifying them against the hashes pinned in the device board.toml.

The modules are DER-wrapped IM4P: SEQUENCE { IA5 "IM4P", IA5 type, IA5 desc,
OCTET STRING payload }.
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


def der(data, at):
    tag, size = data[at], data[at + 1]
    at += 2
    if size & 0x80:
        count = size & 0x7F
        size = int.from_bytes(data[at:at + count], 'big')
        at += count
    return tag, data[at:at + size], at + size


def payload_of(path: Path) -> bytes:
    data = path.read_bytes()
    tag, sequence, end = der(data, 0)
    fields, cursor = [], 0
    while cursor < len(sequence):
        kind, body, cursor = der(sequence, cursor)
        fields.append((kind, body))
    kinds = [k for k, _ in fields]
    print('  DER: tag=%#x fields=%s end=%d/%d' % (tag, [hex(k) for k in kinds], end, len(data)))
    if tag != 0x30 or kinds != [0x16, 0x16, 0x16, 0x04] or fields[0][1] != b'IM4P':
        raise SystemExit('unexpected container layout in %s' % path.name)
    print('  IM4P type=%s' % fields[1][1].decode(errors='replace'))
    return fields[3][1]


print('=== StaticTrustCache ===')
static = payload_of(STATIC)
print('  sha256', hashlib.sha256(static).hexdigest())

print('=== SystemTrustCache ===')
system = payload_of(SYSTEM)
print('  sha256', hashlib.sha256(system).hexdigest())

ok_static = hashlib.sha256(static).hexdigest() == PINNED_STATIC
ok_system = hashlib.sha256(system).hexdigest() == PINNED_SYSTEM
print('  与 pin 的静态缓存一致:', ok_static)
print('  与 pin 的系统缓存一致:', ok_system)

count = struct.unpack_from('<I', static, 20)[0]
version = struct.unpack_from('<I', static)[0]
print('  static: version=%d count=%d expected_len=%d actual=%d'
      % (version, count, 24 + count * 24, len(static)))
if not (ok_static and ok_system):
    raise SystemExit('哈希不匹配')
if version != 2 or len(static) != 24 + count * 24:
    raise SystemExit('static 模块结构不对')

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
print('bundle bytes:', len(bundle))
print('bundle sha256:', hashlib.sha256(bundle).hexdigest())
print('written:', OUT / 'original-static-system.bundle')
