#!/usr/bin/env python3
"""Show the full tail of the boot-progress and legacy-display archive logs."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    for name in ('archive-11-build-boot-progress.log', 'archive-12-build-native-legacy-display.log'):
        try:
            text = z.read(name).decode('utf-8', 'replace').splitlines()
        except KeyError:
            print(name, '不存在')
            continue
        print('=== %s（%d 行）===' % (name, len(text)))
        for line in text[-18:]:
            print('   ', line[:170])
        print()
