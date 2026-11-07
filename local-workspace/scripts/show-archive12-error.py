#!/usr/bin/env python3
"""Show the compile error inside archive-12."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    lines = z.read('archive-12-build-native-legacy-display.log').decode('utf-8', 'replace').splitlines()

print('行数', len(lines))
hits = [i for i, l in enumerate(lines) if 'error:' in l]
print('error 行数', len(hits))
for i in hits[:6]:
    print()
    for line in lines[max(0, i - 3):i + 6]:
        print('   ', line[:165])
