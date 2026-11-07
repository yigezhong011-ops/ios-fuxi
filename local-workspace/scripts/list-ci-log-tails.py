#!/usr/bin/env python3
"""List every log in the artifact and show the tails, to find the current failure."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    names = z.namelist()
    print('日志文件:', names)
    for n in names:
        text = z.read(n).decode('utf-8', 'replace').splitlines()
        print()
        print('=== %s（%d 行）尾部 ===' % (n, len(text)))
        for line in text[-12:]:
            print('   ', line[:160])
