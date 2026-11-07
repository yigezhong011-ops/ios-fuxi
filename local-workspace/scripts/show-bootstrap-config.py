#!/usr/bin/env python3
"""Show the bootstrap defconfig and the prelink section that names the candidate."""
import urllib.request

H = {'User-Agent': 'dsh'}


def raw(path):
    url = f'https://raw.githubusercontent.com/yigezhong011-ops/unixnu-fuxi/old/{path}'
    try:
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60).read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败: %s)' % e


print('=== configs/fuxi_defconfig ===')
print(raw('configs/fuxi_defconfig')[:1500])
print()
print('=== board.toml 的 [kernel.prelink] ===')
b = raw('board.toml')
i = b.find('[kernel.prelink]')
print(b[i:i + 700] if i >= 0 else '(没有这一段)')
