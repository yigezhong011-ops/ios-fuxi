#!/usr/bin/env python3
"""Show the payload patch log from the artifact."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    names = [n for n in z.namelist() if 'payload' in n or 'patch' in n]
    print('相关日志:', names)
    for name in names:
        lines = z.read(name).decode('utf-8', 'replace').splitlines()
        print()
        print('=== %s（%d 行）===' % (name, len(lines)))
        for line in lines[-18:]:
            print('   ', line[:175])
