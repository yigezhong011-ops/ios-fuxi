#!/usr/bin/env python3
"""My CLT clang shim routes SETUP tools to the host compiler; make that link with
the host linker too, not with cctools' Apple ld (which rejects GNU -z)."""
from pathlib import Path

p = Path('/opt/unixnu-linux/CommandLineTools/usr/bin/clang')
t = p.read_text()
old = 'exec /usr/bin/clang -Wno-error -Wno-format "${args[@]}"'
new = ('exec /usr/bin/clang -Wno-error -Wno-format --ld-path=/usr/bin/ld '
       '-include /opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include/unixnu-host-prefix.h '
       '-L/opt/unixnu-linux/CommandLineTools/usr/lib "${args[@]}"')

if '--ld-path=/usr/bin/ld' in t:
    print('已经指定主机 ld')
elif old in t:
    p.write_text(t.replace(old, new))
    print('已改为使用主机 ld 和 xnu 的主机前缀头')
else:
    raise SystemExit('找不到 host 分支')
for line in p.read_text().splitlines():
    if 'usr/bin/clang' in line:
        print('  ' + line.strip()[:160])
