#!/usr/bin/env python3
"""Look for an AVB footer (and size) in both boot images."""
files = [
    ('作者/进度条正常', '/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/boot-gpu3-cpus6.img'),
    ('我们/只有点', '/mnt/e/DSH-Fuxi/fuxi-metal-arrearm.img'),
]
for label, path in files:
    d = open(path, 'rb').read()
    print('=== %s ===' % label)
    print('  文件大小 %d 字节 (%#x)' % (len(d), len(d)))
    tail = d[-64:]
    print('  尾部 64 字节 magic: %r' % tail[:4])
    print('  含 "AVBf":', d.rfind(b'AVBf'))
    print('  含 "AVB0":', d.rfind(b'AVB0'))
    print('  含 "ANDROID!":', d.find(b'ANDROID!'))
    # 头部剩余空间里有没有别的东西
    print('  0x30..0x80:', d[0x30:0x80].hex())
    print()
