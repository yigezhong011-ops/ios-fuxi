#!/usr/bin/env python3
"""Confirm the kernel and ADT inside the gpu4 payload, and compare with the source files."""
import hashlib
import subprocess
from pathlib import Path

PAYLOAD = Path('/root/verify-gpu4/payload.img')
print('=== payload 文件清单 ===')
r = subprocess.run(['mdir', '-i', str(PAYLOAD), '-/ ::/EFI/UniXNU/Payloads', '::/EFI/UniXNU'],
                   capture_output=True, text=True)
print(r.stdout[:1200] or r.stderr[:500])

print('=== 内核比对 ===')
got = subprocess.run(['mtype', '-i', str(PAYLOAD), '::/EFI/UniXNU/Payloads/kernel.macho'],
                     capture_output=True).stdout
want = Path('/root/fuxi/t32/kernel-t32-gpu4.macho').read_bytes()
print('  镜像内 %d 字节 sha256 %s' % (len(got), hashlib.sha256(got).hexdigest()[:16]))
print('  源文件 %d 字节 sha256 %s' % (len(want), hashlib.sha256(want).hexdigest()[:16]))
print('  一致:', got == want)

print('=== ADT 比对（应与原卷相同） ===')
adt = subprocess.run(['mtype', '-i', str(PAYLOAD), '::/EFI/UniXNU/Payloads/kernel.macho.adt'],
                     capture_output=True).stdout
base = subprocess.run(['mtype', '-i', str(Path('/mnt/e/DSH-Fuxi/t32-bl-daily.img')),
                       '::/EFI/UniXNU/Payloads/kernel.macho.adt'], capture_output=True).stdout
print('  镜像内 %d 字节' % len(adt))
if adt:
    print('  sha256', hashlib.sha256(adt).hexdigest()[:16])
