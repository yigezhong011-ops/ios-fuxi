#!/usr/bin/env python3
"""Tail of archive-15's log: the HTTP status that failed."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    lines = z.read('archive-15-prepare-fuxi-gmu.log').decode('utf-8', 'replace').splitlines()
for line in lines[-18:]:
    print(line[:180])
