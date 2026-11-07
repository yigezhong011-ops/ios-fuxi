#!/usr/bin/env python3
"""Build the original static+system trust bundle (hashes as the official script
expects them), verifying the two modules and writing the bundle."""
import hashlib
import json
import struct
from pathlib import Path

IPSW = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/ipsw/21H461')
OUT = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/build/original-static-system-trust')
STATIC = IPSW / '044-76040-038.dmg.trustcache'
SYSTEM = IPSW / '044-76034-038.dmg.trustcache'

# the constants unixnu/scripts/build-original-system-trust.py requires
EXPECTED_STATIC = 'da88460e6e513438d5307e5c526f76497a74754476a24da29f239f0c90120fc2'
EXPECTED_SYSTEM = 'd121ba89167e03aafd00fa687c30cd8ebc4ccafd10c1408adb2ba3de12403651'


def der(data, at):
    tag, size = data[at], data[at + 1]
    at += 2
    if size & 0x80:
        count = size & 0x7F
        size = int.from_bytes(data[at:at + count], 'big')
        at += count
    return tag, data[at:at + size], at + size


def payload_of(path):
    data = path.read_bytes()
    tag, sequence, end = der(data, 0)
    fields, cursor = [], 0
    while cursor < len(sequence):
        kind, body, cursor = der(sequence, cursor)
        fields.append((kind, body))
    if tag != 0x30 or [k for k, _ in fields] != [0x16, 0x16, 0x16, 0x04] or fields[0][1] != b'IM4P':
        raise SystemExit('unexpected container layout in %s' % path.name)
    return fields[3][1]


static = payload_of(STATIC)
system = payload_of(SYSTEM)
for name, module, expected in (('static', static, EXPECTED_STATIC), ('system', system, EXPECTED_SYSTEM)):
    digest = hashlib.sha256(module).hexdigest()
    print('%-7s %d B  sha256 %s  %s' % (name, len(module), digest, 'OK' if digest == expected else 'MISMATCH'))
    if digest != expected:
        raise SystemExit('%s 与原版不一致' % name)

count = struct.unpack_from('<I', static, 20)[0]
version = struct.unpack_from('<I', static)[0]
if version != 2 or len(static) != 24 + count * 24:
    raise SystemExit('static 模块结构不对')
print('static: version=%d entries=%d' % (version, count))

bundle = struct.pack('<3I', 2, 12, 12 + len(static)) + static + system
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'original-static-system.bundle').write_bytes(bundle)
(OUT / 'inputs.json').write_text(json.dumps(dict(
    original_static_sha256=EXPECTED_STATIC,
    original_system_sha256=EXPECTED_SYSTEM,
    bundle_sha256=hashlib.sha256(bundle).hexdigest(),
    own_code_entries_added=False,
    original_modules_modified=False,
    apple_personalization_claimed=False,
), indent=2) + '\n')

print()
print('bundle    %d B' % len(bundle))
print('sha256    %s' % hashlib.sha256(bundle).hexdigest())
print('written   %s' % (OUT / 'original-static-system.bundle'))
