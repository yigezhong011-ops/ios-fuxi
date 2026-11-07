#!/usr/bin/env python3
"""Second pass on the lscan strings: errors near the poster and widget stack, with context. Read-only. Usage: read-lscan2.py <lscan.txt>"""
import re
import sys
from collections import Counter

lines = open(sys.argv[1], 'rb').read().replace(b'\r\n', b'\n').decode('latin1').split('\n')


def distinct(title, pat, limit=40, width=330):
    c = Counter(l[:width] for l in lines if re.search(pat, l))
    print(f'== {title}: {sum(c.values())} lines, {len(c)} distinct')
    for k, v in c.most_common(limit):
        print(f'{v:5d} {k}')


def context(title, pat, before=4, after=6, limit=4, width=240):
    print(f'== context: {title}')
    seen = 0
    done = set()
    for i, l in enumerate(lines):
        if re.search(pat, l) and l[:80] not in done:
            done.add(l[:80])
            for x in lines[max(0, i - before):i + after + 1]:
                print('   ', x[:width])
            print('    ---')
            seen += 1
            if seen >= limit:
                break
    print('   shown', seen)


distinct('data store', r'(?i)data ?store|PBFPosterExtension|poster.*(extension|descriptor|configuration).*(fail|error|nil|not|invalid|unable)')
distinct('poster failures', r'(?i)(poster|PBF|PRS|PR[A-Z][a-z]+).*(fail|error|unable|could not|cannot|invalid|missing|timed out)')
distinct('widget failures', r'(?i)(widget|chrono|timeline|snapshot|archive).*(fail|error|unable|could not|cannot|invalid|timed out)', 45)
distinct('render failures', r'(?i)(CAContext|CoreAnimation|CALayer|IOSurface|BackBoard|FrontBoard|FBScene|snapshot|render).*(fail|error|unable|could not|cannot|invalid)', 30)
distinct('wallpaper services', r'(?i)(wallpaper|SBWallpaper|PBUIWallpaper|PBUI).*(fail|error|unable|could not|cannot|invalid|nil|load|missing|not )', 30)
distinct('metal client', r'native-metal: (device|library|client|queue|texture|render|drawable|surface|pipeline)|Metal failed|MTL[A-Z]\w+.*(fail|error)', 40)
distinct('e00002d5 and busy', r'e00002d5|AGXDeviceUserClient|IOAccelerator|no address space|IOGPU', 16)
distinct('data protection', r'(?i)data protection|MIPluginDataContainer|no system container|container.*(fail|error)', 16)
context('migration note', r'Data store migration not needed')
context('prefixPrimary', r'function prefixPrimary_cf refused')
context('collections container', r'Failed to set data protection on container')
context('no pipeline library', r'no pipeline library on this GPU')
context('device refused', r'native-metal: device refused')
