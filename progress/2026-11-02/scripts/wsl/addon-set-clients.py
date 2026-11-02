#!/usr/bin/env python3
"""Copy an NGPUADD2 GPU addon with addons/NativeAdrenoMetal.clients replaced (layout: UniXNU scripts/make-gpu-addon.py).
Every other entry keeps its original compressed bytes. Optional extra files: --add PATH_IN_ADDON=LOCAL_FILE (mode 644).
Usage: addon-set-clients.py <in> <out> <name,name,...> [--add path=file ...]"""
import struct
import sys
import zlib
from pathlib import Path

CLIENTS = 'addons/NativeAdrenoMetal.clients'


def pad(b):
    return b + bytes(-len(b) % 8)


src, dst, names = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
adds = [a.split('=', 1) for a in sys.argv[5::2]] if '--add' in sys.argv else []
clients = [n for n in names.split(',') if n]
if not clients or any('/' in n or ' ' in n for n in clients):
    sys.exit('bad client names')
data = src.read_bytes()
if data[:8] != b'NGPUADD2':
    sys.exit('not an NGPUADD2 addon')
count, _, total = struct.unpack_from('<IIQ', data, 8)
if total != len(data):
    sys.exit(f'header total {total} != file size {len(data)}')
off, entries = 24, []
for _ in range(count):
    name_len, mode, size, csize = struct.unpack_from('<IIQQ', data, off)
    off += 24
    name = data[off:off + name_len - 1].decode()
    off += name_len + (-name_len % 8)
    entries.append([name, mode, size, data[off:off + csize]])
    off += csize + (-csize % 8)
text = ('\n'.join(clients) + '\n').encode()
hit = [e for e in entries if e[0] == CLIENTS]
if len(hit) != 1:
    sys.exit('no single clients entry')
hit[0][2:] = [len(text), zlib.compress(text, 9)]
for path, local in adds:
    if '..' in path.split('/') or path.startswith('/') or any(e[0] == path for e in entries):
        sys.exit('bad or duplicate path ' + path)
    raw = Path(local).read_bytes()
    entries.append([path, 0o644, len(raw), zlib.compress(raw, 9)])


def build(entries):
    out = b''
    for name, mode, size, packed in entries:
        encoded = name.encode() + b'\0'
        out += struct.pack('<IIQQ', len(encoded), mode, size, len(packed)) + pad(encoded) + pad(packed)
    return b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(out)) + out


# --same-size: the payload FAT keeps the Data seed in its free clusters, so the addon must be rewritten over its own clusters at
# exactly its old size. The bluetoothd launchd override goes (sheng-disable-jobs already stops bluetoothd), and the client list
# gets one filler name, sized until the whole addon is byte for byte as long as before.
if '--same-size' in sys.argv:
    entries = [e for e in entries if e[0] != 'daemons/com.apple.bluetoothd.plist']
    import hashlib
    for n in range(0, 4000):
        filler = hashlib.sha256(str(n).encode()).hexdigest() * 40
        for cut in range(1, len(filler)):
            text = ('\n'.join(clients) + '\nzz-filler-' + filler[:cut] + '\n').encode()
            hit = [e for e in entries if e[0] == CLIENTS][0]
            hit[2:] = [len(text), zlib.compress(text, 9)]
            size = len(build(entries))
            if size == len(data):
                break
            if size > len(data):
                break
        if size == len(data):
            break
    else:
        sys.exit('could not match the old size')
body = b''
for name, mode, size, packed in entries:
    encoded = name.encode() + b'\0'
    if len(encoded) > 160:
        sys.exit('path too long ' + name)
    body += struct.pack('<IIQQ', len(encoded), mode, size, len(packed)) + pad(encoded) + pad(packed)
blob = b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(body)) + body
dst.write_bytes(blob)
print(f'{dst}: {len(entries)} files, {len(blob)} bytes (was {len(data)}); clients: {" ".join(clients)}')
