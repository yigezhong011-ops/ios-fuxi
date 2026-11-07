#!/usr/bin/env python3
"""Compare our generated ADT with the one from the working zip payload, looking
for the img4 / mix-n-match / csr properties the kernel asks about."""
import struct
import subprocess
from pathlib import Path

OURS = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/stage/EFI/UniXNU/Payloads/kernel.macho.adt')
THEIRS = Path('/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/kernel/kernel.macho.adt')


def fdt_strings(path: Path):
    """Return (property names, all string values) from an FDT blob."""
    data = path.read_bytes()
    if data[:4] != b'\xd0\x0d\xfe\xed':
        raise SystemExit('%s is not an FDT' % path)
    total = struct.unpack_from('>I', data, 4)[0]
    off_struct = struct.unpack_from('>I', data, 8)[0]
    off_strings = struct.unpack_from('>I', data, 12)[0]
    # walk the structure block
    at, names, values = off_struct, [], []
    depth = 0
    while at < off_strings - 4:
        token = struct.unpack_from('>I', data, at)[0]
        at += 4
        if token == 1:      # FDT_BEGIN_NODE
            end = data.index(b'\0', at)
            at = (end + 4) & ~3
            depth += 1
        elif token == 2:    # FDT_END_NODE
            depth -= 1
        elif token == 3:    # FDT_PROP
            length, nameoff = struct.unpack_from('>II', data, at)
            at += 8
            name_end = data.index(b'\0', off_strings + nameoff)
            name = data[off_strings + nameoff:name_end].decode(errors='replace')
            value = data[at:at + length]
            at = (at + length + 3) & ~3
            names.append(name)
            values.append(value)
        elif token == 4:    # FDT_NOP
            continue
        elif token == 9:    # FDT_END
            break
        else:
            break
    return names, values


print('=== 两个 ADT ===')
for label, path in (('ours  ', OURS), ('theirs', THEIRS)):
    if not path.is_file():
        print('%s %s （不存在）' % (label, path))
        continue
    names, _ = fdt_strings(path)
    print('%s %s  %d 字节  %d 个属性' % (label, path.name, path.stat().st_size, len(names)))

if OURl := (OURS.is_file(), THEIRS.is_file()):
    pass

if OURS.is_file() and THEIRS.is_file():
    ours, _ = fdt_strings(OURS)
    theirs, _ = fdt_strings(THEIRS)
    so, st = set(ours), set(theirs)
    print()
    print('=== 只在 ours 里的属性 (%d) ===' % len(so - st))
    for n in sorted(so - st)[:25]:
        print('  +', n)
    print()
    print('=== 只在 theirs 里的属性 (%d) ===' % len(st - so))
    for n in sorted(st - so)[:25]:
        print('  -', n)
    print()
    hits = sorted(n for n in so | st if any(k in n.lower() for k in ('img4', 'mix', 'trust', 'csr', 'secur', 'amfi')))
    print('=== 与信任/签名相关的属性 ===')
    for n in hits:
        where = 'ours' if n in so else ''
        where += ('+' if n in so and n in st else '')
        where = ('both' if n in so and n in st else ('ours' if n in so else 'theirs'))
        print('  %-40s %s' % (n, where))
