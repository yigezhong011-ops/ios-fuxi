#!/usr/bin/env python3
"""Make REBOOT and panic go straight to fastboot in a t50 kernel that already has the USB_REBOOT blob. Same idea as V2's QcomReset: skip reboot_kernel,
whose unmount path never finishes on this UFS driver. Checks every old word first and refuses anything unexpected.
  worker: mov w0,#0 -> mov w0,#1 and bl reboot_kernel -> bl reboot_hook. The worker has just armed the reboot, so the hook's gate passes.
  panic_spin_forever: after the USB drain, wfe -> b reboot_hook past its gate. The old loop stays out of use.
Usage: patch-t50-usbfast.py <in kernel> <out kernel>"""
import struct
import sys

WORKER_ARG = 0xfffffff00bd0d95c
WORKER_BL = 0xfffffff00bd0d964
REBOOT_KERNEL = 0xfffffff00bd58058
SPIN_WFE = 0xfffffff00b8a322c
HOOK = 0xfffffff00c09039c
HOOK_BODY = HOOK + 0x1c
HOOK_WORDS = {HOOK: 0x7100041f, HOOK_BODY: 0xd10243ff}

k = bytearray(open(sys.argv[1], 'rb').read())
if struct.unpack_from('<I', k)[0] != 0xfeedfacf:
    raise SystemExit('not a thin 64-bit Mach-O')
ncmds = struct.unpack_from('<I', k, 16)[0]
segs, at = [], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, at)
    if cmd == 0x19:
        vm, vmsize, off, filesize = struct.unpack_from('<QQQQ', k, at + 24)
        segs.append((vm, filesize, off))
    at += size


def foff(va):
    for vm, filesize, off in segs:
        if vm <= va < vm + filesize:
            return off + va - vm
    raise SystemExit(f'{va:#x} not in the file')


def word(va):
    return struct.unpack_from('<I', k, foff(va))[0]


def put(va, old, new):
    if word(va) != old:
        raise SystemExit(f'{va:#x}: found {word(va):#010x}, expected {old:#010x}')
    struct.pack_into('<I', k, foff(va), new)
    print(f'{va:#x}: {old:#010x} -> {new:#010x}')


def bl(frm, to, op=0x94000000):
    delta = (to - frm) // 4
    if not -(1 << 25) <= delta < (1 << 25):
        raise SystemExit('branch out of range')
    return op | (delta & 0x3ffffff)


for va, want in HOOK_WORDS.items():
    if word(va) != want:
        raise SystemExit(f'reboot_hook not at the expected place: {va:#x} holds {word(va):#010x}')
# cbz w0 after wait_drained gives up when the host has stopped reading. A reset must not depend on the host: go on regardless.
WORKER_DRAINED = 0xfffffff00bd0d950
put(WORKER_DRAINED, 0x34000000 | (((0xfffffff00bd0d988 - WORKER_DRAINED) // 4) << 5), 0xd503201f)
put(WORKER_ARG, 0x52800000, 0x52800020)
put(WORKER_BL, bl(WORKER_BL, REBOOT_KERNEL), bl(WORKER_BL, HOOK))
put(SPIN_WFE, 0xd503205f, bl(SPIN_WFE, HOOK_BODY, 0x14000000))
open(sys.argv[2], 'wb').write(k)
