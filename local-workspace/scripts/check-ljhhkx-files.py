#!/usr/bin/env python3
"""Check ljhhkx529's old branch for the files our build needed."""
import urllib.request

H = {'User-Agent': 'dsh'}
REPO = 'ljhhkx529/unixnu-fuxi'
REF = 'old'


def head(path):
    url = f'https://raw.githubusercontent.com/{REPO}/{REF}/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30) as r:
            data = r.read()
        return '%d B' % len(data)
    except Exception as e:
        return '缺失 (%s)' % getattr(e, 'code', e)


for path in ('board.toml', 'configs/fuxi_gpu_defconfig', 'configs/fuxi_gpu_bootstrap_defconfig',
             'package/fuxi.dtb', 'blobs/a740_zap.mbn', 'package/libFuxiLinkStubs.a',
             'patches/xnu/fuxi-link-stubs.patch', 'scripts/fetch-adreno-inputs.py',
             'scripts/build-xnu-4k-baseline.sh', 'scripts/build-adreno740-kits.py',
             'scripts/build-adreno740-accelerator.py', 'scripts/build-native-legacy-display.py'):
    print('%-52s %s' % (path, head(path)))
