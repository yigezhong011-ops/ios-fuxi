#!/usr/bin/env python3
"""Read kClientWindows out of the t32 kernel binary: how many windows, how big."""
import struct
from pathlib import Path

K = Path('/root/fuxi/t32/kernel.macho')
data = K.read_bytes()
magic = struct.unpack_from('<I', data, 0)[0]
print('文件 %d 字节, magic %#x' % (len(data), magic))
if magic != 0xfeedfacf:
    raise SystemExit('不是 64 位 Mach-O')

cputype, cpusub, filetype, ncmds, sizeofcmds, flags = struct.unpack_from('<iiIIII', data, 4)
print('ncmds %d, sizeofcmds %d' % (ncmds, sizeofcmds))

off = 32
sections = []
symtab = None
for _ in range(ncmds):
    cmd, cmdsize = struct.unpack_from('<II', data, off)
    if cmd == 0x19:      # LC_SEGMENT_64
        segname = data[off + 8:off + 24].rstrip(b'\0').decode()
        nsects = struct.unpack_from('<I', data, off + 64)[0]
        s = off + 72
        for _ in range(nsects):
            sectname = data[s:s + 16].rstrip(b'\0').decode()
            addr, size = struct.unpack_from('<QQ', data, s + 32)
            offset = struct.unpack_from('<I', data, s + 48)[0]
            sections.append((segname, sectname, addr, size, offset))
            s += 80
    elif cmd == 0x2:     # LC_SYMTAB
        symtab = struct.unpack_from('<IIII', data, off + 8)
    off += cmdsize

print('段/节 %d 个' % len(sections))
if not symtab:
    raise SystemExit('没有符号表')
symoff, nsyms, stroff, strsize = symtab
print('符号 %d 个, symoff %d' % (nsyms, symoff))

target = None
strtab = data[stroff:stroff + strsize]
for i in range(nsyms):
    s = symoff + i * 16
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', data, s)
    name = strtab[strx:strtab.find(b'\0', strx)].decode('utf-8', 'replace')
    if 'kClientWindows' in name:
        print('符号 %s = %#x (sect %d)' % (name, value, nsect))
        target = (name, value, nsect)

if not target:
    print('没找到 kClientWindows 符号（可能已被 strip）')
else:
    name, addr, nsect = target
    idx = nsect - 1
    if 0 <= idx < len(sections):
        seg, sect, saddr, ssize, soff = sections[idx]
        print('所在节 %s,%s addr %#x size %#x' % (seg, sect, saddr, ssize))
        fileoff = soff + (addr - saddr)
        print('从文件偏移 %#x 读 4 个窗口（每个 16 字节）:' % fileoff)
        for i in range(4):
            start, nbytes = struct.unpack_from('<QQ', data, fileoff + i * 16)
            if start == 0 and nbytes == 0:
                print('  窗口 %d: 空（数组到此为止）' % i)
                break
            print('  窗口 %d: start %#x  bytes %#x  (%.0f MiB)'
                  % (i, start, nbytes, nbytes / (1 << 20)))
