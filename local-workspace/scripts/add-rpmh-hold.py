#!/usr/bin/env python3
"""Add a short hold after the RPMh probe so the console values can be photographed."""
from pathlib import Path

F = Path('/root/ios-fuxi/shim/fuxi-loader/loader.c')
src = F.read_text()

if 'rpmh_hold' in src:
    print('already patched')
    raise SystemExit

helper = '''
/* Hold the loader console so the probe lines can be read off the panel. */
static void rpmh_hold(void)
{
	uint64_t freq, start, now;
	__asm__ volatile("mrs %0, cntfrq_el0" : "=r"(freq));
	__asm__ volatile("mrs %0, cntpct_el0" : "=r"(start));
	do {
		__asm__ volatile("mrs %0, cntpct_el0" : "=r"(now));
	} while (now - start < freq * 8);
}
'''

anchor = 'static void rpmh_probe(void)'
assert anchor in src
src = src.replace(anchor, helper + '\n' + anchor, 1)

call = ' rpmh_probe();'
assert call in src
src = src.replace(call, call + '\n rpmh_hold();', 1)

F.write_text(src)
print('hold added')
