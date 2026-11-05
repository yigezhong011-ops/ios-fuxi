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
if '-DPANEL_120' in defs:
    defs += [f"-DADDR_IODELAY={syms['_IODelay']:#x}UL", f"-DADDR_IOLOG={syms['_IOLog']:#x}UL",
             f"-DADDR_MACH_TIME={syms['_mach_absolute_time']:#x}UL"]
if '-DCPU_PROBE' in defs:
    defs.append(f"-DADDR_REAL_NCPUS={syms['_real_ncpus']:#x}UL")
if '-DCPU_LOAD' in defs:
    defs += [f"-DADDR_PROCESSOR_ARRAY={syms['_processor_array']:#x}UL", f"-DADDR_PROCESSOR_INFO={syms['_processor_info']:#x}UL"]
if any(d.startswith('-DCLOCK_SECS=') for d in defs):
    defs.append(f"-DADDR_CLOCK_SET={syms['_clock_set_calendar_microtime']:#x}UL")
row_users = [d for d in ('-DDIAG_ROW', '-DBL_DIAG_ROW', '-DUSB_DIAG') if d in defs]
if len(row_users) > 1:
    raise SystemExit(f'{" and ".join(row_users)} share the one diagnostic row: pick one')
if row_users:
    defs += [f"-DADDR_DIAG_ROW={syms['_native_cpufreq_row']:#x}UL", f"-DADDR_DIAG_STAGE={syms['_native_cpufreq_stage']:#x}UL"]
if '-DUSB_DIAG' in defs:
    # FuxiUsbCompat.c's fuxi_usbdbg_phase / fuxi_usbdbg_result (kernels with the fuxi USB debug glue, e.g. t36)
    defs += [f"-DADDR_USB_PHASE={syms['_fuxi_usbdbg_phase']:#x}UL", f"-DADDR_USB_RESULT={syms['_fuxi_usbdbg_result']:#x}UL",
             f"-DADDR_QUD_NATIVE={syms['_native']:#x}UL"]
if '-DUSB_BOOTCPU' in defs:
    if '-DUSB_DIAG' not in defs:
        raise SystemExit('USB_BOOTCPU reports through USB_DIAG: add -DUSB_DIAG')
    defs += [f"-DADDR_QUD_INIT={syms['_qcom_usb_debug_init']:#x}UL", f"-DADDR_QUD_POLL={syms['_qcom_usb_debug_poll']:#x}UL",
             f"-DADDR_CPU_NUMBER={syms['_cpu_number']:#x}UL", f"-DADDR_MASTER_CPU={syms['_master_cpu']:#x}UL"]
    if not any(d.startswith('-DUSB_BOOTCPU_DELAY_MS=') for d in defs):
        defs.append('-DUSB_BOOTCPU_DELAY_MS=60000')
if '-DDIAG_ROW' in defs:
    defs += [f"-DADDR_HID_EVENTS={syms['_native_hid_input_events']:#x}UL",
             f"-DADDR_HID_RESULTS={syms['_native_hid_input_results']:#x}UL",
             f"-DADDR_HID_OBJECT={syms['_native_hid_input_object']:#x}UL"]


def word(va):
    return struct.unpack_from('<I', k, foff(va))[0]


def bl_target(va):
    w = word(va)
    if (w & 0xfc000000) != 0x94000000:
        return None
    imm = w & 0x3ffffff
    return va + ((imm - (1 << 26)) if imm & (1 << 25) else imm) * 4


# BACKLIGHT: t32's ShengBacklight with its transport moved to the DSI link (see fuxi-buttons-blob.c). Every site is checked
# against the instruction this kernel has there; anything else refuses the patch.
bl_sites = []
if '-DBACKLIGHT' in defs:
    start = syms['_sheng_backlight_start']
    sb = syms['__ZN14ShengBacklight14startBacklightEPKb']
    kick = syms['__ZN14ShengBacklight4kickEj']
    attach = syms['__ZN14ShengBacklight11attachFiredEP8OSObjectP18IOTimerEventSource']
    # gGcc.map: `adrp x20, page` at +0x3c, `str x0, [x20, #off]` at +0x40 (the first map's result)
    adrp, store = word(start + 0x3c), word(start + 0x40)
    if (adrp & 0x9f00001f) != 0x90000014 or (store & 0xffc003ff) != 0xf9000280:
        raise SystemExit(f'sheng_backlight_start+0x3c/0x40 are {adrp:08x} {store:08x}, not adrp x20 / str x0,[x20]')
    immlo, immhi = (adrp >> 29) & 3, (adrp >> 5) & 0x7ffff
    imm = (immhi << 2) | immlo
    if imm & (1 << 20):
        imm -= 1 << 21
    slot = ((start + 0x3c) & ~0xfff) + (imm << 12) + ((store >> 10) & 0xfff) * 8
    for at in (sb + 0x188, sb + 0x1e4):
        if bl_target(at) != syms['_geni_i2c_prepare']:
            raise SystemExit(f'{at:#x} is not bl geni_i2c_prepare')
    gate = sb + 0x218
    g = word(gate)
    imm14 = (g >> 5) & 0x3fff
    if imm14 & 0x2000:
        imm14 -= 0x4000
    if (g & 0xfff8001f) != 0x36000008 or gate + imm14 * 4 != sb + 0x138:
        raise SystemExit(f'{gate:#x} is {g:08x}, not tbz w8,#0 to the failure return')
    for va in (start, kick, attach):
        if (word(va) & 0x7c000000) == 0x14000000 or word(va) == RET:
            raise SystemExit(f'{va:#x} already starts with a branch or ret: patched kernel?')
    defs += [f"-DADDR_IODELAY={syms['_IODelay']:#x}UL", f"-DADDR_GETPLATFORM={syms['__ZN9IOService11getPlatformEv']:#x}UL",
             f'-DADDR_START_BACKLIGHT={sb:#x}UL', f"-DADDR_BL_STATS={syms['_native_backlight_stats']:#x}UL",
             f'-DADDR_DSI_SLOT={slot:#x}UL', f"-DADDR_BL_METACLASS={syms['__ZN14ShengBacklight10gMetaClassE']:#x}UL"]
    bl_sites = [('branch', start, 'bl_start'), ('branch', kick, 'bl_kick'), ('word', attach, RET),
                ('word', sb + 0x188, 0x12800000), ('word', sb + 0x1e4, 0x12800000), ('word', gate, 0xD503201F)]
    print(f'backlight: DSI va slot {slot:#x}')
sink = syms['_native_buttons_set_sink']
# NO_SINK=1: a kernel with its own buttons (t36, fuxi-buttons=1): leave native_buttons_set_sink alone and use only the
# BACKLIGHT entry points of the blob; the poller code stays in the cave unused.
no_sink = os.environ.get('NO_SINK') == '1'
if no_sink and not bl_sites:
    raise SystemExit('NO_SINK=1 without -DBACKLIGHT patches nothing')
hib_end = None
for name, vmaddr, vmsize, fileoff, filesize in segs:
    if name == '__TEXT_EXEC':
        text_seg = (vmaddr, filesize)
# REPLACE_SINK=1: the kernel has its own native_buttons_set_sink body (t36's interrupt-driven fuxi-buttons, which does
# not report on this phone): branch its first instruction to the blob's poller instead (same arguments). Boot without
# fuxi-buttons=1 so the two do not share the PMIC.
replace_sink = os.environ.get('REPLACE_SINK') == '1'
first = struct.unpack_from('<I', k, foff(sink))[0]
if not no_sink and first != RET and not replace_sink:
    raise SystemExit('native_buttons_set_sink is not a bare ret: refusing (already patched or a different kernel)')
if replace_sink and (first & 0x7c000000) == 0x14000000:
    raise SystemExit('native_buttons_set_sink already starts with a branch: patched kernel?')

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
    blob_syms = {l.split()[-1]: int(l.split()[0], 16) for l in subprocess.run(
        ['llvm-nm', str(t / 'b.elf')], capture_output=True, text=True, check=True).stdout.splitlines() if len(l.split()) == 3}
    entry = blob_syms['buttons_set_sink']
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
def branch(frm, to):
    delta = (to - frm) // 4
    if not -(1 << 25) <= delta < (1 << 25):
        raise SystemExit('branch out of range')
    struct.pack_into('<I', k, foff(frm), 0x14000000 | (delta & 0x3ffffff))


if not no_sink:
    branch(sink, cave)
for kind, va, what in bl_sites:
    if kind == 'branch':
        branch(va, blob_syms[what])
        print(f'backlight: {va:#x} -> b {what} {blob_syms[what]:#x}')
    else:
        struct.pack_into('<I', k, foff(va), what)
        print(f'backlight: {va:#x} = {what:08x}')
dst.write_bytes(k)
print(f'blob {len(blob):#x} bytes at {cave:#x}; native_buttons_set_sink {sink:#x}: ' +
      ('left alone (NO_SINK)' if no_sink else f'ret -> b {cave:#x}'))
print(f'calls: ' + ', '.join(f'{s}={syms[s]:#x}' for s in need.values()))
