#!/bin/bash
set -euo pipefail
L=/root/hackios/xnuloader/loader.c
python3 - "$L" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if 'platform_fuxi' in t:
    print('already present')
    raise SystemExit
m = re.search(r'static const struct platform platform_redwood = \{.*?\n\};\n', t, re.S)
assert m, 'platform_redwood not found'
plat = '''
static const struct platform platform_fuxi = {
	.name = "fuxi",
	.io_base = 0x00400000, .io_size = 0x3FC00000,
	.gic_dist = 0x17100000, .gic_redist = 0x17180000,
	.uart = 0,
	.log_other_cpu = 1,
	.cores = 8, .core_shift = 8,
	.small_cores = 0x7,
	.fb_base = 0xB8000000,
};
'''
t = t[:m.end()] + plat + t[m.end():]
# add to the platforms[] array
m2 = re.search(r'(static const struct platform \*const platforms\[\] = \{.*?)(\n\};)', t, re.S)
assert m2, 'platforms[] not found'
body = m2.group(1)
if '&platform_fuxi' not in body:
    body = body.rstrip()
    if not body.endswith(','):
        body += ','
    body += '\n\t&platform_fuxi,'
t = t[:m2.start()] + body + m2.group(2) + t[m2.end():]
p.write_text(t)
print('platform_fuxi added')
PY
grep -n 'platform_fuxi' "$L" | head -5
cd /root/hackios && bash xnuloader/build.sh 2>&1 | tail -3
ls -lh xnuloader/loader.efi
