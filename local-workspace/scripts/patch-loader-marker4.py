#!/usr/bin/env python3
"""Copy a fuxi boot image that records how far the loader got, and reports the previous boot's number as a delay. Temp boot only.
Each of ten steps paints its band and stores 'FX'<<16 | step at SLOT in DRAM that neither UEFI nor the kernels use. At entry, before anything else, a valid old value
holds the CPU for step * SECS seconds, so the time back to fastboot reads out the previous boot's last step without any reader on the phone. The hold stays well below
the 60 s after which a hang resets. Usage: patch-loader-marker4.py <in.img> <out.img>"""
import gzip, os, struct, subprocess, sys, tempfile, zlib
src, dst = sys.argv[1:3]
SLOT = 0xA6100000     # 'DBI Dump' in the UEFI memory map: uncached there, no owner in a normal boot
SECS = int(os.environ.get('STEP_SECS', '4'))
TICKS = 19200000 * SECS
d = open(src, 'rb').read()
ksize = struct.unpack_from('<I', d, 8)[0]
dec = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = bytearray(dec.decompress(d[4096:4096 + ksize]))
dtb = dec.unused_data
CAVE = 0x2F0000
assert body[CAVE:CAVE + 0x800] == b'\xff' * 0x800, 'cave not erased'
assert body[0x3000c0 + 0x52:0x3000c0 + 0x5a].startswith(b'FAT32'), 'volume moved'
word = lambda at: struct.unpack_from('<I', body, at)[0]
RED, GREEN, BLUE, YELLOW, MAGENTA, CYAN, WHITE = 0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00, 0xFFFF00FF, 0xFF00FFFF, 0xFFFFFFFF
SITES = [
    (0x00004, 0x1400000F, RED,     False),  # 1 entry: b 0x40
    (0x000AC, 0xD61F00A0, GREEN,   False),  # 2 stub done: br x5 into the copy
    (0x000C0, 0x1401E400, BLUE,    False),  # 3 FD start, running from the copy: b 0x790c0
    (0x790D4, 0xAA1403E0, YELLOW,  False),  # 4 first set/way clean returned: mov x0, x20
    (0x79174, 0xAA1F03FD, MAGENTA, False),  # 5 stack cleared, about to call SecEntry: mov x29, xzr
    (0x02140, 0x940067E0, CYAN,    False),  # 6 second set/way clean returned: bl 0x1c0c0
    (0x02198, 0x9401BBCA, WHITE,   False),  # 7 vector table next, caches set up: bl 0x710c0
    (0x02434, 0x94000784, RED,     False),  # 8 screen just cleared: first DEBUG print: bl 0x4244
    (0x02ACC, None,       GREEN,   True),   # 9 'SEC: memory HOBs done': MMU on
    (0x03308, None,       BLUE,    True),   # 10 'SEC: loading DXE core'
]
def asm(text):
    with tempfile.TemporaryDirectory() as t:
        open(t + '/a.s', 'w').write(text)
        subprocess.check_call(['aarch64-linux-gnu-as', '-o', t + '/a.o', t + '/a.s'])
        subprocess.check_call(['aarch64-linux-gnu-objcopy', '-O', 'binary', '-j', '.text', t + '/a.o', t + '/a.bin'])
        b = open(t + '/a.bin', 'rb').read()
    return list(struct.unpack('<%dI' % (len(b) // 4), b))
def branch(frm, to, op=0x14000000):
    delta = (to - frm) >> 2
    assert -(1 << 25) <= delta < (1 << 25)
    return op | (delta & 0x3FFFFFF)
def relocate(w, frm, to):
    if (w & 0xFC000000) in (0x14000000, 0x94000000):
        imm = w & 0x3FFFFFF
        if imm & (1 << 25): imm -= 1 << 26
        return branch(to, frm + (imm << 2), w & 0xFC000000)
    if (w & 0x9F000000) == 0x90000000:
        imm = ((w >> 29) & 3) | (((w >> 5) & 0x7FFFF) << 2)
        if imm & (1 << 20): imm -= 1 << 21
        run = 0xA7100000 - 0xC0
        page = ((frm + run) & ~0xFFF) + (imm << 12)
        new = (page - ((to + run) & ~0xFFF)) >> 12
        return (w & 0x9F00001F) | ((new & 3) << 29) | (((new >> 2) & 0x7FFFF) << 5)
    assert (w & 0x9F000000) != 0x10000000 and (w & 0xFF000000) not in (0x54000000, 0x58000000), hex(w)
    return w
READOUT = f"""
    movz x9, #{SLOT >> 16:#x}, lsl #16
    dc civac, x9
    dsb sy
    ldr x10, [x9]
    lsr x11, x10, #16
    movz x12, #0x4658
    cmp x11, x12
    b.ne 2f
    and x10, x10, #0xff
    cmp x10, #10
    b.hi 2f
    movz x11, #{TICKS >> 16:#x}, lsl #16
    movk x11, #{TICKS & 0xFFFF:#x}
    mul x10, x10, x11
    mrs x9, cntvct_el0
    add x9, x9, x10
1:  mrs x10, cntvct_el0
    cmp x10, x9
    b.lo 1b
2:
"""
at = CAVE
for n, (site, want, colour, save) in enumerate(SITES):
    orig = word(site)
    if want is not None:
        assert orig == want, (hex(site), hex(orig))
    else:
        assert (orig & 0x9F000000) == 0x90000000, (hex(site), hex(orig))
    fb = 0xB8000000 + 4320 * 100 * n
    text = ''
    if save:
        text += 'stp x9, x10, [sp, #-16]!\nstr x11, [sp, #-16]!\n'
    if n == 0:
        text += READOUT
    text += f"""
    movz x9, #{SLOT >> 16:#x}, lsl #16
    movz x10, #{n + 1}
    movk x10, #0x4658, lsl #16
    str x10, [x9]
    dc civac, x9
    dsb sy
    movz x9, #{fb >> 16:#x}, lsl #16
    movk x9, #{fb & 0xFFFF:#x}
    movz x10, #54000
    movz x11, #{colour >> 16:#x}, lsl #16
    movk x11, #{colour & 0xFFFF:#x}
    orr x11, x11, x11, lsl #32
3:  str x11, [x9], #8
    subs x10, x10, #1
    b.ne 3b
    dsb sy
"""
    if save:
        text += 'ldr x11, [sp], #16\nldp x9, x10, [sp], #16\n'
    code = asm(text)
    for i, w in enumerate(code):
        struct.pack_into('<I', body, at + 4 * i, w)
    p = at + 4 * len(code)
    struct.pack_into('<I', body, p, relocate(orig, site, p))
    struct.pack_into('<I', body, p + 4, 0x14000000 if orig == 0xD61F00A0 else branch(p + 4, site + 4))
    struct.pack_into('<I', body, site, branch(site, at))
    print('step', n + 1, 'site', hex(site), 'cave', hex(at), 'orig', hex(orig))
    at = p + 8
assert at < CAVE + 0x800
kernel = gzip.compress(bytes(body), mtime=0) + dtb
hdr = b'ANDROID!' + struct.pack('<IIII', len(kernel), 1, struct.unpack_from('<I', d, 16)[0], 1580) + bytes(16) + struct.pack('<I', 3) + d[44:44 + 1536]
page = lambda b: b + bytes(-len(b) % 4096)
open(dst, 'wb').write(page(hdr) + page(kernel) + page(b'\0'))
open('/tmp/marker4-body.bin', 'wb').write(bytes(body[:0x3000c0]))
print(dst, 'kernel section', hex(len(kernel)), 'cave end', hex(at))
