#!/usr/bin/env python3
"""Why can the same-size rewrite not match? Print the arithmetic."""
import struct
import zlib
from pathlib import Path

CLIENTS = 'addons/NativeAdrenoMetal.clients'
data = Path('/root/fuxi/t32/kernel.macho.gpuaddon').read_bytes()
count, _, total = struct.unpack_from('<IIQ', data, 8)
off, entries = 24, []
for _ in range(count):
    name_len, mode, size, csize = struct.unpack_from('<IIQQ', data, off)
    off += 24
    name = data[off:off + name_len - 1].decode()
    off += name_len + (-name_len % 8)
    entries.append([name, mode, size, data[off:off + csize]])
    off += csize + (-csize % 8)

print('原总长', len(data))
for e in entries:
    print('  %-52s csize=%8d pad8=%8d entry=%8d' % (
        e[0][:52], len(e[3]), len(e[3]) + (-len(e[3]) % 8),
        24 + (lambda n: n + (-n % 8))(len(e[0].encode()) + 1) + len(e[3]) + (-len(e[3]) % 8)))

bt = [e for e in entries if 'bluetoothd' in e[0]][0]
bt_entry = 24 + (lambda n: n + (-n % 8))(len(bt[0].encode()) + 1) + len(bt[3]) + (-len(bt[3]) % 8)
print('\n删掉 bluetoothd 腾出', bt_entry, '字节')

cl = [e for e in entries if e[0] == CLIENTS][0]
cl_name_pad = (lambda n: n + (-n % 8))(len(cl[0].encode()) + 1)
print('clients 条目名占', 24 + cl_name_pad, '字节（固定）')

# base = total minus the two entries
base = len(data) - bt_entry - (24 + cl_name_pad + (lambda n: n + (-n % 8))(len(cl[3])))
print('其余条目的固定部分 + 头 =', base)
need_total = len(data)
need_clients_csize_pad = need_total - base - 24 - cl_name_pad
print('因此 clients 的 pad8(csize) 必须等于', need_clients_csize_pad, '→ csize 落在',
      need_clients_csize_pad - 7, '..', need_clients_csize_pad)

names = 'SpringBoard,WidgetRenderer_Default,iconservicesagent,Preferences'
text = ('\n'.join(names.split(',')) + '\n').encode()
print('\n新名单文本', len(text), '字节，压缩后', len(zlib.compress(text, 9)))
print('不加填充时的 pad8 =', (lambda n: n + (-n % 8))(len(zlib.compress(text, 9))))

import hashlib
best = None
for cut in range(0, 40000, 1):
    filler = (hashlib.sha256(b'0').hexdigest() * 2000)[:cut]
    cand = ('\n'.join(names.split(',')) + '\nzz-filler-' + filler + '\n').encode()
    pad = (lambda n: n + (-n % 8))(len(zlib.compress(cand, 9)))
    if best is None or pad < need_clients_csize_pad:
        best = (cut, len(cand), pad)
    if pad >= need_clients_csize_pad:
        print('\n找到：填充 %d 字节 → 文本 %d、压缩 %d、pad8 %d（需要 %d）' %
              (cut, len(cand), len(zlib.compress(cand, 9)), pad, need_clients_csize_pad))
        break
else:
    print('\n40000 内没达到，最好:', best)
