#!/usr/bin/env python3
"""Give the kernel a boot session UUID by writing it into the symbol's storage.

Why: FuxiMetal's backboardd gate refuses with "boot-uuid-unavailable" when
kern.bootsessionuuid is empty (BackboardGate.hpp: validBoot() needs 36 chars), and
neither the loader nor the ADT supplies a boot-uuid. The variable
bootsessionuuid_string is a static buffer; patching the kernel binary is enough and
needs no rebuild.

    patch-boot-uuid.py <kernel-in> <kernel-out> [uuid]
"""
import struct
import sys
import uuid

MH_MAGIC_64 = 0xFEEDFACF
LC_SEGMENT_64 = 0x19
LC_SYMTAB = 0x2

src, dst = sys.argv[1], sys.argv[2]
boot = sys.argv[3] if len(sys.argv) > 3 else 'FUXI0000-0000-4000-8000-0000B007B007'
assert len(boot) == 36, 'boot uuid must be 36 chars'

unstripped = open(src, 'rb').read()
magic, cputype, cpusub, filetype, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', unstripped[:32])
assert magic == MH_MAGIC_64, 'not a 64-bit Mach-O'

segments = []
symtab = None
off = 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', unstripped, off)
    if cmd == LC_SEGMENT_64:
        name = unstripped[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<QQQQ', unstripped, off + 24)
        segments.append((name, vmaddr, vmsize, fileoff, filesize))
    elif cmd == LC_SYMTAB:
        symtab = struct.unpack_from('<IIII', unstripped, off + 8)
    off += size

symoff, nsyms, stroff, strsize = symtab
target = None
for i in range(nsyms):
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', unstripped, symoff + i * 16)
    if strx == 0:
        continue
    end = unstripped.index(b'\0', stroff + strx)
    name = unstripped[stroff + strx:end].decode(errors='replace')
    if name in ('_bootsessionuuid_string', 'bootsessionuuid_string'):
        target = (name, value)
        break

assert target, 'bootsessionuuid_string not found in the symbol table'
name, vaddr = target
print('symbol %s at %#x' % (name, vaddr))

seg = next((s for s in segments if s[1] <= vaddr < s[1] + s[2]), None)
assert seg, 'no segment holds the symbol'
segname, vmaddr, vmsize, fileoff, filesize = seg
fo = fileoff + (vaddr - vmaddr)
print('segment %s fileoff %#x filesize %#x -> file offset %#x' % (segname, fileoff, filesize, fo))

stripped = bytearray(open(dst, 'rb').read())
print('old bytes:', bytes(stripped[fo:fo + 40]))
stripped[fo:fo + 37] = boot.encode() + b'\0'
open(dst, 'wb').write(stripped)
print('wrote %s at %#x; new bytes: %s' % (boot, fo, bytes(stripped[fo:fo + 37])))
