#!/usr/bin/env python3
"""Find the data store's build and init code in the PosterBoard framework by the selectors it calls. Read-only. Usage: read-dsc-build.py <dsc dir>"""
import importlib.util
import re
import struct
import sys
spec = importlib.util.spec_from_file_location('c', '/mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
sec, rd, stub, dump, cstr = c.sec, c.rd, c.stub, c.dump, c.cstr
tx, txs = sec['__text']
text = rd(tx, txs)
names = {}
sites = []
for off in range(0, txs, 4):
    ins = struct.unpack_from('<I', text, off)[0]
    if ins & 0xfc000000 != 0x94000000:
        continue
    imm = ins & 0x3ffffff
    if imm & (1 << 25):
        imm -= 1 << 26
    va = tx + off
    t = va + imm * 4
    if t not in names:
        names[t] = stub(t)
    if names[t]:
        sites.append((va, names[t]))
print('named call sites', len(sites))


def start_of(va):
    """Walk back to the likely function start: pacibsp, or stp with x29 after a return."""
    a = va
    while a > tx and va - a < 0x4000:
        i = struct.unpack_from('<I', text, a - tx)[0]
        if i == 0xd503237f:
            return a
        a -= 4
    return None


rx = re.compile(r'wasMigrationJustPerformed|runtimeAssertionProvider|applicationStateMonitor|initWithURL|buildDataStore|dataStoreURL|_lock_setupDataStore|setupDataStore|loadDataStore')
seen = {}
for va, n in sites:
    if rx.search(n):
        f = start_of(va)
        seen.setdefault(f, []).append((va, n))
for f, rows in sorted(seen.items(), key=lambda x: x[0] or 0):
    print(f'-- func {f and hex(f)}')
    for va, n in rows:
        print(f'   {va:#x} {n[:110]}')
print('== strings about stores and failures')
for name in ('__oslogstring', '__cstring'):
    a, n = sec[name]
    d = rd(a, n)
    at = 0
    for s in d.split(b'\0'):
        v = a + at
        at += len(s) + 1
        t = s.decode('latin1')
        if re.search(r'(?i)(data ?store|schema|version|migrat|sandbox|container|shared resources|URLForDirectory|unable|could not|failed).*', t) and re.search(r'(?i)store|container|directory|schema', t) and len(t) > 12:
            print(f'{v:#x} {t[:130]}')
