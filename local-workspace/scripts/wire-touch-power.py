#!/usr/bin/env python3
"""Expose probe.c's touch_power() and call it from the loader before the XNU handoff."""
from pathlib import Path

P = Path('/root/ios-fuxi/shim/fuxi-probe/probe.c')
src = P.read_text()

if 'probe_touch_up' not in src:
    # append a public wrapper after touch_power's definition: find the function end by
    # anchoring on the following function (touch_events / request handler) instead of parsing.
    anchor = 'static void touch_power(unsigned stage)\n{'
    assert anchor in src, 'touch_power not found'
    # place the wrapper at the end of the file (C allows calling a function defined later
    # only with a declaration, so declare it first here)
    src += '''
/* Public wrapper: power the touch rails and run the controller through its
 * reset. The loader calls this before the XNU handoff; the RPMh votes persist,
 * so the kernel driver finds the IC powered and answers its chip-id read. */
void probe_touch_up(void)
{
	touch_power(9);
}
'''
    P.write_text(src)
    print('probe.c: wrapper appended')
else:
    print('probe.c already has the wrapper')

L = Path('/root/ios-fuxi/shim/fuxi-loader/loader.c')
lsrc = L.read_text()
if 'probe_touch_up' not in lsrc:
    decl_anchor = 'void probe_main(uintptr_t fdt);'
    assert decl_anchor in lsrc
    lsrc = lsrc.replace(decl_anchor, decl_anchor + '\nvoid probe_touch_up(void);', 1)
    call_anchor = ' rpmh_hold();'
    assert call_anchor in lsrc
    lsrc = lsrc.replace(call_anchor, call_anchor + '\n con_str("TOUCH", "powering the rails + reset");\n probe_touch_up();', 1)
    L.write_text(lsrc)
    print('loader.c: probe_touch_up call added')
else:
    print('loader.c already calls it')
