#!/usr/bin/env python3
"""Patch 0113: short-circuit the INTF1 autorefresh guard so the kick always runs."""
import subprocess, tempfile, pathlib

line_old = '    if (fuxi_intf1 == NULL || (fuxi_intf1[0x2b4 / 4] & 0x80000000u)) {\n'
line_new = '    if (0) {   /* fuxi: this unit never enables autorefresh; always start */\n'

# zero-context hunk: only the removed/added lines, applied by line number
patch = (
    '--- a/pexpert/arm/pe_serial.c\n'
    '+++ b/pexpert/arm/pe_serial.c\n'
    '@@ -731,1 +731,1 @@\n'
    '-' + line_old[0:] +
    '+' + line_new[0:]
)
# strip the trailing newline duplication
patch = patch.replace('-\n', '-').replace('+\n', '+')
pathlib.Path('/root/fuxi/0113-fuxi-kick-intf1.patch').write_text(patch)
print(patch)

# verify against a reconstruction
fragment = '''void fuxi_display_kick(void)
{
    if (fuxi_gpu_scanout_owned()) return;
    if (fuxi_intf1 == NULL || (fuxi_intf1[0x2b4 / 4] & 0x80000000u)) {
        __asm__ volatile("dsb sy" ::: "memory");
        return;
    }
}
'''
work = pathlib.Path(tempfile.mkdtemp())
(work / 'pexpert/arm').mkdir(parents=True)
(work / 'pexpert/arm/pe_serial.c').write_text('/* pad */\n' * 728 + fragment)
r = subprocess.run(['git', 'apply', '--check', '--verbose',
                    '/root/fuxi/0113-fuxi-kick-intf1.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check ===')
print('rc =', r.returncode, r.stdout.strip()[:200], r.stderr.strip()[:300])
