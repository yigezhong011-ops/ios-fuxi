#!/usr/bin/env python3
"""Patch 0112 (v5): one minimal hunk on the ZAP-free CTL0 block; counter is function-local."""
import difflib, re, subprocess, tempfile, pathlib

# The block 0082 introduced and 0087/0108 left untouched, with 3 lines of context.
ctx_before = '''void fuxi_display_kick(void)
{
    /* GPU-SCANOUT owns manual START until reset; console must stay muted. */
    if (fuxi_gpu_scanout_owned()) return;
'''
# ...but 0108's guard may not be present if 0108 is ordered after; use only the
# lines directly above the block that every patch chain keeps:
ctx_before = '''        __asm__ volatile("dsb sy" ::: "memory");
        return;
    }
'''

old = ctx_before + '''    if (fuxi_ctl0 != NULL && !(fuxi_ctl0[0x1c / 4] & 1)) {
        __asm__ volatile("dsb sy" ::: "memory");
        fuxi_ctl0[0x1c / 4] = 1;
        __asm__ volatile("dsb sy" ::: "memory");
    }
}
'''

new = ctx_before + '''    if (fuxi_ctl0 != NULL) {
        volatile uint32_t *start = &fuxi_ctl0[0x1c / 4];
        uint32_t before = *start;
        static int logged;
        __asm__ volatile("dsb sy" ::: "memory");
        *start = 1;
        __asm__ volatile("dsb sy" ::: "memory");
        if (logged < 8) {
            logged++;
            printf("FUXI KICK %d: start before=%#x after=%#x\\n",
                logged, before, *start);
        }
    }
}
'''
assert old != new

diff = list(difflib.unified_diff(
    old.splitlines(keepends=True), new.splitlines(keepends=True),
    fromfile='a/pexpert/arm/pe_serial.c', tofile='b/pexpert/arm/pe_serial.c', n=3))
# fragment starts at file line 730 (the block sits ~10 lines into the function)
BASE = 730
out = [diff[0], diff[1]]
for line in diff[2:]:
    m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', line)
    if m:
        a, n_old, b, n_new = (int(x) for x in m.groups())
        start = BASE + a - 1
        out.append(f'@@ -{start},{n_old} +{start},{n_new} @@\n')
    else:
        out.append(line)
text = ''.join(out)
pathlib.Path('/root/fuxi/0112-fuxi-kick-always.patch').write_bytes(text.encode())
print(text)

# verify on a padded reconstruction
fragment = '''void fuxi_display_kick(void)
{
    if (fuxi_intf1 == NULL || (fuxi_intf1[0x2b4 / 4] & 0x80000000u)) {
        __asm__ volatile("dsb sy" ::: "memory");
        return;
    }
    if (fuxi_ctl0 != NULL && !(fuxi_ctl0[0x1c / 4] & 1)) {
        __asm__ volatile("dsb sy" ::: "memory");
        fuxi_ctl0[0x1c / 4] = 1;
        __asm__ volatile("dsb sy" ::: "memory");
    }
}
#endif
'''
work = pathlib.Path(tempfile.mkdtemp())
(work / 'pexpert/arm').mkdir(parents=True)
padding = ''.join(f'/* pad {i} */\n' for i in range(BASE - 1))
(work / 'pexpert/arm/pe_serial.c').write_text(padding + fragment)
r = subprocess.run(['git', 'apply', '--check', '--verbose',
                    '/root/fuxi/0112-fuxi-kick-always.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check ===')
print('rc =', r.returncode, r.stdout.strip()[:200], r.stderr.strip()[:300])
