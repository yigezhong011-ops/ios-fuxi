#!/usr/bin/env python3
"""List the archive logs present in this run and the tail of the last one."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    names = sorted(z.namelist())
    print('日志:', names)
    last = [n for n in names if n.startswith('archive-')]
    if last:
        name = last[-1]
        lines = z.read(name).decode('utf-8', 'replace').splitlines()
        print()
        print('=== %s（%d 行）===' % (name, len(lines)))
        for line in lines[-14:]:
            print('   ', line[:170])
