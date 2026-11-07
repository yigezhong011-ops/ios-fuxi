#!/usr/bin/env python3
import pathlib
p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh')
b = p.read_bytes()
print('has CRLF:', b'\r\n' in b)
t = p.read_text()
i = t.find('redwood-drm')
print(repr(t[i - 100:i + 200]))
