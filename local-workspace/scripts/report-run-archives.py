#!/usr/bin/env python3
"""Report where the newest run's archive chain stopped."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    names = sorted(z.namelist())
    print('日志文件:', names)
    for n in names:
        text = z.read(n).decode('utf-8', 'replace').splitlines()
        print()
        print('=== %s（%d 行）=== 尾:' % (n, len(text)))
        for line in text[-5:]:
            print('   ', line[:165])
