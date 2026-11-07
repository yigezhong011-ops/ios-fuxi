#!/usr/bin/env python3
"""Compare the two fuxi ZAP images the user supplied."""
import hashlib
from pathlib import Path

files = [
    Path('/mnt/c/Users/USER/Downloads/a740_zap-odm-fd107982.mbn'),
    Path('/mnt/c/Users/USER/Downloads/a740_zap-odm.mbn'),
]
for p in files:
    if not p.is_file():
        print('%s 不存在' % p)
        continue
    d = p.read_bytes()
    print('=== %s ===' % p.name)
    print('  大小      %d 字节' % len(d))
    print('  sha256    %s' % hashlib.sha256(d).hexdigest())
    print('  前 32 字节 %s' % d[:32].hex())
    print('  前 16 ascii %r' % d[:16])
    # ELF 或 IMEM 段特征
    if d[:4] == b'\x7fELF':
        print('  格式      ELF')
    for kw in (b'zap', b'ZAP', b'a740', b'qcom'):
        if kw in d[:4096]:
            print('  头部含    %r' % kw)

a = files[0].read_bytes() if files[0].is_file() else b''
b = files[1].read_bytes() if files[1].is_file() else b''
if a and b:
    print()
    print('=== 两者比较 ===')
    print('  完全相同:', a == b)
    print('  长度差:', len(a) - len(b))
    # 找第一处不同
    n = min(len(a), len(b))
    for i in range(n):
        if a[i] != b[i]:
            print('  第一处不同在偏移 %d: %02x vs %02x' % (i, a[i], b[i]))
            print('    上下文 a:', a[max(0, i - 8):i + 8].hex())
            print('    上下文 b:', b[max(0, i - 8):i + 8].hex())
            break
    else:
        print('  前 %d 字节相同' % n)
