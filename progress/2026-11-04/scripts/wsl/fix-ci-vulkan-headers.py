#!/usr/bin/env python3
"""Install the Vulkan headers the host smoke test needs.

check-turnip-darwin-host.py compiles drivers/Adreno740/tests/hostsim/vulkan_smoke.c with
-I /opt/homebrew/include, which needs vulkan/vulkan.h on the macOS runner.
"""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
text = p.read_bytes().decode('utf-8').replace('\r\n', '\n')
old = 'brew install dtc llvm lld cmake mtools ninja glslang shaderc spirv-tools bison pkgconf rustup age unifdef blacktop/tap/ipsw\n'
if 'vulkan-headers' in text:
    print('已经装过 vulkan-headers')
elif old in text:
    new = old.replace('brew install ', 'brew install vulkan-headers vulkan-loader ')
    p.write_bytes(text.replace(old, new, 1).encode('utf-8'))
    print('已在 tools 步骤加入 vulkan-headers vulkan-loader')
else:
    print('找不到 brew install 行')

for i, line in enumerate(p.read_bytes().decode('utf-8').splitlines(), 1):
    if 'brew install' in line:
        print('%4d| %s' % (i, line.strip()[:160]))
