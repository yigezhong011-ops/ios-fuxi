#!/usr/bin/env python3
"""Inject fuxi-buttons-blob.c into a COPY of the t32 kernel and point native_buttons_set_sink at it.

1. resolve the kernel functions the blob calls (llvm-nm), and native_buttons_set_sink (must be a bare `ret`)
2. compile the blob freestanding, link it at the cave (zero run after __hib_text, inside __TEXT_EXEC), keep only .text
3. check the cave is all zeros and inside the segment, write the blob, replace the `ret` with `b <blob>`
Usage: patch-t32-buttons.py <kernel.macho in> <kernel.macho out>   (BLOB_DEFS="-DSELF_TEST" adds compile defines)
"""
import os
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

SRC = Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi-buttons-blob.c')
RET = 0xD65F03C0
src, dst = Path(sys.argv[1]), Path(sys.argv[2])
k = bytearray(src.read_bytes())

ncmds = struct.unpack_from('<I', k, 16)[0]
segs, off = [], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        name = k[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24)
        segs.append((name, vmaddr, vmsize, fileoff, filesize))
    off += size


def foff(va, seg='__TEXT_EXEC'):
    for name, vmaddr, vmsize, fileoff, filesize in segs:
        if name == seg and vmaddr <= va < vmaddr + filesize:
            return fileoff + va - vmaddr
    raise SystemExit(f'{va:#x} not in {seg}')


nm = subprocess.run(['llvm-nm', '--defined-only', str(src)], capture_output=True, text=True, check=True).stdout
syms = {}
for line in nm.splitlines():
    parts = line.split()
    if len(parts) == 3:
        syms.setdefault(parts[2], int(parts[0], 16))
need = {'ADDR_ML_IO_MAP': '_ml_io_map', 'ADDR_IOSLEEP': '_IOSleep', 'ADDR_IOMALLOCZERO': '_IOMallocZero_external',
        'ADDR_KERNEL_THREAD_START': '_kernel_thread_start', 'ADDR_THREAD_DEALLOCATE': '_thread_deallocate'}
defs = []
for macro, sym in need.items():
    if sym not in syms:
        raise SystemExit(f'missing {sym}')
    defs.append(f'-D{macro}={syms[sym]:#x}UL')
defs += os.environ.get('BLOB_DEFS', '').split()
if '-DDIAG_ROW' in defs:
    defs += [f"-DADDR_DIAG_ROW={syms['_native_cpufreq_row']:#x}UL", f"-DADDR_DIAG_STAGE={syms['_native_cpufreq_stage']:#x}UL"]
sink = syms['_native_buttons_set_sink']
hib_end = None
for name, vmaddr, vmsize, fileoff, filesize in segs:
    if name == '__TEXT_EXEC':
        text_seg = (vmaddr, filesize)
if struct.unpack_from('<I', k, foff(sink))[0] != RET:
    raise SystemExit('native_buttons_set_sink is not a bare ret: refusing (already patched or a different kernel)')

# The cave: the zero run that ends the __TEXT_EXEC segment's file data (after __hib_text).
seg_va, seg_size = text_seg
end = seg_va + seg_size
start = end
while start > seg_va and k[foff(start - 4):foff(start - 4) + 4] == b'\0\0\0\0':
    start -= 4
cave = (start + 0x3f) & ~0x3f
print(f'cave {cave:#x}..{end:#x} ({end - cave:#x} bytes)')

with tempfile.TemporaryDirectory() as t:
    t = Path(t)
    subprocess.run(['clang', '--target=aarch64-none-elf', '-ffreestanding', '-fno-builtin', '-fno-stack-protector',
                    '-mgeneral-regs-only', '-fno-pic', '-mcmodel=tiny', '-O2', '-Wall', '-Werror', *defs,
                    '-c', str(SRC), '-o', str(t / 'b.o')], check=True)
    sizes = subprocess.run(['llvm-size', '--format=berkeley', str(t / 'b.o')], capture_output=True, text=True,
                           check=True).stdout.splitlines()[-1].split()
    if int(sizes[1]) or int(sizes[2]):
        raise SystemExit(f'blob has writable data (data {sizes[1]}, bss {sizes[2]})')
    (t / 'b.ld').write_text('SECTIONS { . = %#x; .text : { *(.text.a_entry) *(.text*) *(.rodata*) } '
                            '/DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) *(.ARM.*) } }\n' % cave)
    subprocess.run(['ld.lld', '-T', str(t / 'b.ld'), '-e', 'buttons_set_sink', str(t / 'b.o'), '-o', str(t / 'b.elf')], check=True)
    subprocess.run(['llvm-objcopy', '-O', 'binary', '-j', '.text', str(t / 'b.elf'), str(t / 'b.bin')], check=True)
    blob = (t / 'b.bin').read_bytes()
    entry = next(int(l.split()[0], 16) for l in subprocess.run(['llvm-nm', str(t / 'b.elf')], capture_output=True,
                 text=True, check=True).stdout.splitlines() if l.split()[-1] == 'buttons_set_sink')
    load = None
    for l in subprocess.run(['llvm-readelf', '-S', str(t / 'b.elf')], capture_output=True, text=True, check=True).stdout.splitlines():
        p = l.replace('[', ' ').replace(']', ' ').split()
        if len(p) >= 4 and p[1] == '.text':
            load = int(p[3], 16)
    shutil.copy(t / 'b.elf', dst.with_suffix('.blob.elf'))
if load != cave or entry != cave:
    raise SystemExit(f'blob linked at {load:#x}, entry {entry:#x}, expected {cave:#x}')
if cave + len(blob) > end:
    raise SystemExit(f'blob {len(blob):#x} bytes does not fit')
o = foff(cave)
if any(k[o:o + len(blob)]):
    raise SystemExit('cave not empty')
k[o:o + len(blob)] = blob
# FORCE_REPORT=1: NativeHidInput::buttonsAction sends report 2 only after eventDriver() found an in-kernel IOHIDEventDriver
# below the device (+0xe4); its `tbz w8, #0, <return>` after re-reading +0xe4 becomes a nop so the report always goes out.
if os.environ.get('FORCE_REPORT') == '1':
    gate = syms['__ZN14NativeHidInput13buttonsActionEP8OSObjectPvS2_S2_S2_'] + 0xd4
    w = struct.unpack_from('<I', k, foff(gate))[0]
    prev = struct.unpack_from('<I', k, foff(gate - 4))[0]
    # ldrb w8, [x19, #0xe4] then tbz w8, #0, +0x84
    if prev != 0x39439268 or (w & 0xfffc001f) != 0x36000008:
        raise SystemExit(f'buttonsAction gate at {gate:#x} is {prev:08x} {w:08x}, not the expected ldrb/tbz')
    struct.pack_into('<I', k, foff(gate), 0xD503201F)
    print(f'buttonsAction {gate:#x}: tbz -> nop (report 2 sent without an IOHIDEventDriver)')
delta = (cave - sink) // 4
if not -(1 << 25) <= delta < (1 << 25):
    raise SystemExit('branch out of range')
struct.pack_into('<I', k, foff(sink), 0x14000000 | (delta & 0x3ffffff))
dst.write_bytes(k)
print(f'blob {len(blob):#x} bytes at {cave:#x}; native_buttons_set_sink {sink:#x}: ret -> b {cave:#x}')
print(f'calls: ' + ', '.join(f'{s}={syms[s]:#x}' for s in need.values()))
