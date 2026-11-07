#!/usr/bin/env python3
"""Show the patch failure and the link failure in the newest logs."""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    names = z.namelist()
    print('包内日志:', len(names))
    boot = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
    print('bootstrap 行数', len(boot))
    for i, line in enumerate(boot):
        if 'patch' in line and ('fail' in line or 'does not apply' in line):
            for ctx in boot[max(0, i - 6):i + 2]:
                print('  ', ctx[:185])
            print('---')
            break

    if 'kernel.log' in names:
        main = z.read('kernel.log').decode('utf-8', 'replace').splitlines()
        print('kernel.log 行数', len(main))
        errs = [l for l in main if 'Undefined symbols' in l or 'referenced from' in l or 'ld: ' in l]
        for line in errs[:12]:
            print('  ', line[:185])
