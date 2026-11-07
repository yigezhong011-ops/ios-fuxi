#!/usr/bin/env python3
"""Read the rest of the ios-on-fuxi README and its product-fix doc."""
import urllib.request

H = {'User-Agent': 'dsh'}


def raw(path):
    url = f'https://raw.githubusercontent.com/Xyvern08371/unixnu-fuxi/main/{path}'
    try:
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60).read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败 %s)' % e


print('=== README 全文（从 M5 之后）===')
text = raw('README.md')
i = text.find('| M5 |')
print(text[i:i + 2500])

print()
print('=== docs-fuxi-product-fix.md ===')
print(raw('docs-fuxi-product-fix.md')[:2500])
