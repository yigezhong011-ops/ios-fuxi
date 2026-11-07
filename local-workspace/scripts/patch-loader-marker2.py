#!/usr/bin/env python3
"""Copy a fuxi boot image with ten coloured bands along the loader's first steps, to read off how far a Mi-logo hang gets. Temp boot only.
Each band is 100 rows at the framebuffer ABL left scanning, row 100*(n-1). Bands 1-7 come before SEC clears the screen, bands 8-10 after it, so a hang shows
the last step reached. Hook sites are file offsets in the kernel body; the FD (file 0xc0) runs at 0xA7100000 after the stub's copy, and the caves are inside what it copies.
Usage: patch-loader-marker2.py <in.img> <out.img>"""
import gzip, struct, sys, zlib
src, dst = sys.argv[1:3]
HOLD = len(sys.argv) > 3 and sys.argv[3] == 'hold'   # keep each band up for about a second, so the order can be read by eye
TICKS = 19200000                                     # the arch timer runs at 19.2 MHz on this SoC; checked only by eye on the phone
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
# site, expected word there, colour, may temporaries be live (then x9-x11 are saved on the stack)
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
def movz(rd, imm16, hw, sf=1): return (sf << 31) | 0x52800000 | (hw << 21) | (imm16 << 5) | rd
def movk(rd, imm16, hw, sf=1): return (sf << 31) | 0x72800000 | (hw << 21) | (imm16 << 5) | rd
def branch(frm, to, op=0x14000000):
    delta = (to - frm) >> 2
    assert -(1 << 25) <= delta < (1 << 25)
    return op | (delta & 0x3FFFFFF)
def relocate(w, frm, to):
    """The displaced instruction, re-encoded for its new address when it is pc-relative."""
    if (w & 0xFC000000) in (0x14000000, 0x94000000):        # b, bl
        imm = w & 0x3FFFFFF
        if imm & (1 << 25): imm -= 1 << 26
        return branch(to, frm + (imm << 2), w & 0xFC000000)
    if (w & 0x9F000000) == 0x90000000:                      # adrp
        imm = ((w >> 29) & 3) | (((w >> 5) & 0x7FFFF) << 2)
        if imm & (1 << 20): imm -= 1 << 21
        # File offset and run address differ by 0xA7100000 - 0xc0, so pages follow the run address.
        run = 0xA7100000 - 0xC0
        page = ((frm + run) & ~0xFFF) + (imm << 12)
        new = (page - ((to + run) & ~0xFFF)) >> 12
        assert -(1 << 20) <= new < (1 << 20)
        return (w & 0x9F00001F) | ((new & 3) << 29) | (((new >> 2) & 0x7FFFF) << 5)
    assert (w & 0x9F000000) != 0x10000000 and (w & 0xFF000000) not in (0x54000000, 0x58000000), hex(w)
    return w
at = CAVE
for n, (site, want, colour, save) in enumerate(SITES):
    orig = word(site)
    if want is not None:
        assert orig == want, (hex(site), hex(orig))
    else:
        assert (orig & 0x9F000000) == 0x90000000, (hex(site), hex(orig))   # the adrp of the DEBUG string
    fb = 0xB8000000 + 4320 * 100 * n
    code = []
    if save:
        code += [0xA9BF2BE9, 0xF81F0FEB]                    # stp x9, x10, [sp, #-16]!; str x11, [sp, #-16]!
    code += [
        movz(9, fb >> 16, 1), movk(9, fb & 0xFFFF, 0),      # framebuffer row
        movz(10, 54000 & 0xFFFF, 0),                        # 54000 double words = 100 rows of 4320 bytes
        movz(11, colour >> 16, 1), movk(11, colour & 0xFFFF, 0),
        0xAA0B816B,                                         # orr x11, x11, x11, lsl #32
        0xF800852B,                                         # str x11, [x9], #8
        0xF100054A,                                         # subs x10, x10, #1
        0x54FFFFC1,                                         # b.ne -8
        0xD5033F9F,                                         # dsb sy
    ]
    if HOLD:
        code += [
            movz(10, TICKS >> 16, 1), movk(10, TICKS & 0xFFFF, 0),
            0xD53BE049,                                     # mrs x9, cntvct_el0
            0x8B0A0129,                                     # add x9, x9, x10
            0xD53BE04A,                                     # mrs x10, cntvct_el0
            0xEB09015F,                                     # cmp x10, x9
            0x54FFFFC3,                                     # b.lo -8
        ]
    if save:
        code += [0xF84107EB, 0xA8C12BE9]                    # ldr x11, [sp], #16; ldp x9, x10, [sp], #16
    for i, w in enumerate(code):
        struct.pack_into('<I', body, at + 4 * i, w)
    p = at + 4 * len(code)
    struct.pack_into('<I', body, p, relocate(orig, site, p))
    if orig == 0xD61F00A0:                                   # br x5 does not come back
        struct.pack_into('<I', body, p + 4, 0x14000000)      # never reached
    else:
        struct.pack_into('<I', body, p + 4, branch(p + 4, site + 4))
    struct.pack_into('<I', body, site, branch(site, at))
    print('band', n + 1, 'site', hex(site), 'cave', hex(at), 'orig', hex(orig))
    at = p + 8
assert at < CAVE + 0x800
kernel = gzip.compress(bytes(body), mtime=0) + dtb
hdr = b'ANDROID!' + struct.pack('<IIII', len(kernel), 1, struct.unpack_from('<I', d, 16)[0], 1580) + bytes(16) + struct.pack('<I', 3) + d[44:44 + 1536]
page = lambda b: b + bytes(-len(b) % 4096)
open(dst, 'wb').write(page(hdr) + page(kernel) + page(b'\0'))
open('/tmp/marker2-body.bin', 'wb').write(bytes(body[:0x3000c0]))
print(dst, 'kernel section', hex(len(kernel)), 'cave end', hex(at))
