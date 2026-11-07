#!/usr/bin/env python3
"""Add an LC_LOAD_DYLIB to a Mach-O binary by growing into the header padding.

    insert-dylib.py <binary> <dylib-path> [--out OUT]

Why: a platform binary like backboardd ignores DYLD_INSERT_LIBRARIES, so the only
way to get our EAGL bridge into the window server without a kernel-side exec hook is
to make the binary itself ask for it.

How: iOS binaries leave the space between the end of the load commands and the first
section's file data unused (the first section normally starts on a 16 KiB boundary).
The new load command is written into that gap, `ncmds` and `sizeofcmds` grow, and
**no byte of the file moves**, so every existing offset stays valid. If the gap is
too small the tool refuses rather than corrupting the binary.

Anything that checks the original signature will reject the result; fuxi's XNU does
not enforce one (no AMFI), which is what makes this usable here.
"""
import struct
import sys
import pathlib

LC_SEGMENT_64 = 0x19
LC_LOAD_DYLIB = 0xC
MH_MAGIC_64 = 0xFEEDFACF


def align8(n):
    return (n + 7) & ~7


def load_commands(data):
    magic, cputype, cpusub, filetype, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', data[:32])
    if magic != MH_MAGIC_64:
        raise ValueError('not a 64-bit Mach-O (magic %#x)' % magic)
    out = []
    off = 32
    for _ in range(ncmds):
        cmd, size = struct.unpack_from('<II', data, off)
        out.append((cmd, size, off))
        if size < 8:
            raise ValueError('bad cmdsize at %#x' % off)
        off += size
    if off != 32 + sizeofcmds:
        raise ValueError('sizeofcmds does not match the commands (%#x vs %#x)' % (off, 32 + sizeofcmds))
    return (ncmds, sizeofcmds, out)


def first_section_offset(data, cmds):
    """The file offset of the first real payload byte (the end of the padding)."""
    best = None
    for cmd, size, off in cmds:
        if cmd != LC_SEGMENT_64:
            continue
        nsects = struct.unpack_from('<I', data, off + 64)[0]
        sect_off = off + 72
        for _ in range(nsects):
            # struct section_64: sectname[16] segname[16] addr(8) size(8) offset(4) ...
            offset = struct.unpack_from('<I', data, sect_off + 48)[0]
            if offset and (best is None or offset < best):
                best = offset
            sect_off += 80
    return best


def add(data: bytes, path: str) -> bytes:
    ncmds, sizeofcmds, cmds = load_commands(data)
    limit = first_section_offset(data, cmds)
    if limit is None:
        raise ValueError('no section offset found; cannot locate the padding')
    gap_start = 32 + sizeofcmds
    gap = limit - gap_start

    name = path.encode() + b'\0'
    cmd_size = align8(24 + len(name))
    if gap < cmd_size:
        raise ValueError('padding too small: need %d bytes at %#x, have %d' % (cmd_size, gap_start, gap))

    new_cmd = struct.pack('<II', LC_LOAD_DYLIB, cmd_size)
    new_cmd += struct.pack('<I', 24)             # name offset
    new_cmd += struct.pack('<II', 2, 0x10000)    # timestamp, current_version
    new_cmd += struct.pack('<I', 0x10000)        # compatibility_version (24 bytes in all)
    new_cmd += name
    new_cmd += b'\0' * (cmd_size - len(new_cmd))

    out = bytearray(data)
    struct.pack_into('<I', out, 16, ncmds + 1)
    struct.pack_into('<I', out, 20, sizeofcmds + cmd_size)
    out[gap_start:gap_start + cmd_size] = new_cmd
    return bytes(out)


def verify(data: bytes, expect_path: str) -> bool:
    ncmds, sizeofcmds, cmds = load_commands(data)
    found = False
    for cmd, size, off in cmds:
        if cmd == LC_LOAD_DYLIB:
            name_off = struct.unpack_from('<I', data, off + 8)[0]
            end = data.index(b'\0', off + name_off)
            name = data[off + name_off:end].decode()
            if name == expect_path:
                found = True
    return found


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    src = pathlib.Path(sys.argv[1])
    path = sys.argv[2]
    out = pathlib.Path(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[3] == '--out' else src.with_name(src.name + '.patched')
    data = src.read_bytes()
    patched = add(data, path)
    out.write_bytes(patched)
    ok = verify(patched, path)
    print('%s: %d -> %d bytes, load command present: %s' % (out, len(data), len(patched), ok))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
