"""Find what a binary-patched button source needs in the t32 kernel (extracted kernel.macho):
the kernel functions it calls, zero-filled runs inside __TEXT_EXEC (code caves), and the callers of native_buttons_set_sink.
Usage: python -I t32-cave.py <kernel.macho>"""
import struct
import sys
from pathlib import Path

k = Path(sys.argv[1]).read_bytes()
ncmds = struct.unpack_from('<I', k, 16)[0]
segs, sects, syms, off = [], [], {}, 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        name = k[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24)
        nsects = struct.unpack_from('<I', k, off + 64)[0]
        segs.append((name, vmaddr, vmsize, fileoff, filesize))
        for s in range(nsects):
            so = off + 72 + 80 * s
            sname = k[so:so + 16].split(b'\0')[0].decode()
            addr, ssize = struct.unpack_from('<QQ', k, so + 32)
            soff = struct.unpack_from('<I', k, so + 48)[0]
            sects.append((name, sname, addr, ssize, soff))
    elif cmd == 0x2:
        symoff, nsyms, stroff, _ = struct.unpack_from('<4I', k, off + 8)
        for i in range(nsyms):
            strx, ntype, _, _, value = struct.unpack_from('<IBBHQ', k, symoff + 16 * i)
            if ntype & 0x0e == 0x0e and value:
                end = k.index(b'\0', stroff + strx)
                syms[k[stroff + strx:end].decode(errors='replace')] = value
    off += size

print('== kernel functions')
for want in ('_ml_io_map', '_ml_io_map_wcomb', '_IOSleep', '_IODelay', '_kernel_thread_start', '_thread_deallocate',
             '_IOMalloc', '_IOMalloc_external', '_IOMallocZero_external', '_kalloc_data', '_kalloc_ext', '_thread_set_thread_name',
             '_current_thread', '_native_buttons_set_sink', '_PE_parse_boot_argn', '__ZN14NativeHidInput13buttonsNotifyEPvj',
             '__ZN14NativeHidInput5startEP9IOService', '_kprintf', '_IOLog'):
    v = syms.get(want)
    print(f'  {want:44} {v:#x}' if v else f'  {want:44} -')

print('\n== __TEXT_EXEC sections')
for seg, sname, addr, ssize, soff in sects:
    if seg == '__TEXT_EXEC':
        print(f'  {sname:16} {addr:#x} size {ssize:#x} fileoff {soff:#x}')

print('\n== zero runs >= 0x600 bytes inside __TEXT_EXEC (4-byte aligned)')
for name, vmaddr, vmsize, fileoff, filesize in segs:
    if name != '__TEXT_EXEC':
        continue
    code = k[fileoff:fileoff + filesize]
    i, n = 0, len(code)
    runs = []
    while i < n:
        if code[i:i + 4] == b'\0\0\0\0':
            j = i
            while j < n and code[j:j + 4] == b'\0\0\0\0':
                j += 4
            if j - i >= 0x600:
                runs.append((vmaddr + i, j - i))
            i = j
        else:
            i += 4
    for va, ln in runs[:20]:
        print(f'  {va:#x} len {ln:#x}')
    print(f'  ({len(runs)} runs)')

print('\n== callers of _native_buttons_set_sink (BL)')
tgt = syms.get('_native_buttons_set_sink')
by_addr = sorted((v, n) for n, v in syms.items())
import bisect
keys = [a for a, _ in by_addr]
for name, vmaddr, vmsize, fileoff, filesize in segs:
    if name != '__TEXT_EXEC' or not tgt:
        continue
    code = k[fileoff:fileoff + filesize]
    for i in range(0, len(code), 4):
        w = struct.unpack_from('<I', code, i)[0]
        if w >> 26 == 0b100101:
            d = w & 0x3ffffff
            d -= (1 << 26) if d & (1 << 25) else 0
            if vmaddr + i + 4 * d == tgt:
                pc = vmaddr + i
                print(f'  {pc:#x} in {by_addr[bisect.bisect_right(keys, pc) - 1][1]}')
