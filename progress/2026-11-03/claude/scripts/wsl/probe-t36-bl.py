#!/usr/bin/env python3
"""Can the BACKLIGHT patch of patch-t32-buttons.py apply to another kernel (t36)? Checks the symbols and every site
the patch verifies, without writing. Usage: probe-t36-bl.py <kernel.macho>"""
import struct
import subprocess
import sys

k = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack_from('<I', k, 16)[0]
segs, off = [], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        name = k[off + 8:off + 24].split(b'\0')[0].decode()
        segs.append((name, *struct.unpack_from('<4Q', k, off + 24)))
    off += size


def word(va):
    for name, vmaddr, vmsize, fileoff, filesize in segs:
        if name == '__TEXT_EXEC' and vmaddr <= va < vmaddr + filesize:
            return struct.unpack_from('<I', k, fileoff + va - vmaddr)[0]
    return None


nm = subprocess.run(['llvm-nm', '--defined-only', sys.argv[1]], capture_output=True, text=True, check=True).stdout
syms = {}
for line in nm.splitlines():
    p = line.split()
    if len(p) == 3:
        syms.setdefault(p[2], int(p[0], 16))
want = ['_ml_io_map', '_IOSleep', '_IOMallocZero_external', '_kernel_thread_start', '_thread_deallocate', '_IODelay',
        '__ZN9IOService11getPlatformEv', '_sheng_backlight_start', '__ZN14ShengBacklight14startBacklightEPKb',
        '__ZN14ShengBacklight4kickEj', '__ZN14ShengBacklight11attachFiredEP8OSObjectP18IOTimerEventSource',
        '_geni_i2c_prepare', '_native_backlight_stats', '__ZN14ShengBacklight10gMetaClassE', '_native_buttons_set_sink',
        '_native_cpufreq_row']
for s in want:
    print(f'{s:72s} {syms[s]:#x}' if s in syms else f'{s:72s} MISSING')
sink = syms.get('_native_buttons_set_sink')
if sink:
    print('native_buttons_set_sink first word', f'{word(sink):08x}', '(ret)' if word(sink) == 0xD65F03C0 else '(not a bare ret)')
start, sb = syms.get('_sheng_backlight_start'), syms.get('__ZN14ShengBacklight14startBacklightEPKb')
if start and sb:
    print('start+0x3c/0x40', f'{word(start + 0x3c):08x} {word(start + 0x40):08x}')
    for at in (0x188, 0x1e4):
        w = word(sb + at)
        tgt = sb + at + (((w & 0x3ffffff) - (1 << 26)) if w & (1 << 25) else (w & 0x3ffffff)) * 4 if (w & 0xfc000000) == 0x94000000 else None
        print(f'sb+{at:#x}', f'{w:08x}', 'bl geni_i2c_prepare' if tgt == syms.get('_geni_i2c_prepare') else f'-> {tgt}')
    print('sb+0x218', f'{word(sb + 0x218):08x}')
