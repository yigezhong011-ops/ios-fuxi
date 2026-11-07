#!/usr/bin/env python3
"""Fix patch 0116 v2: put the forward declaration at file scope.

The first attempt declared `static bool exec_inject_target(...)` inside
exec_mach_imgact's body, which C forbids ("function declared in block scope
cannot have 'static' storage class"). The declaration now sits just above the
function definition.
"""
import difflib
import pathlib
import re
import subprocess
import tempfile

p = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/make-inject-v2.py')
src = p.read_text()

# 1) the block-scope declaration must go
old_decl = ('/* declared below, next to the rest of the injection code */\n'
            '\tstatic bool exec_inject_target(struct image_params *imgp);\n\n'
            '\tif (exec_inject_target(imgp)) {')
new_decl = '\tif (exec_inject_target(imgp)) {'
if old_decl in src:
    src = src.replace(old_decl, new_decl, 1)
    print('removed the block-scope declaration')

# 2) add a file-scope prototype above exec_mach_imgact
if 'prototype_fix' not in src:
    anchor = "assert flag_anchor in new, 'anchor 4 (csflags) not found'"
    addition = '''assert flag_anchor in new, 'anchor 4 (csflags) not found'

# file-scope prototype: exec_inject_target is defined further down
fn_anchor = 'static int\\nexec_mach_imgact(struct image_params *imgp)\\n{\\n'
assert fn_anchor in new, 'exec_mach_imgact definition not found'
new = new.replace(fn_anchor,
                  '/* defined below, with the rest of the injection code */\\n'
                  'static bool exec_inject_target(struct image_params *imgp);\\n\\n'
                  + fn_anchor, 1)
# prototype_fix'''
    if anchor in src:
        src = src.replace(anchor, addition, 1)
        p.write_text(src)
        print('added the file-scope prototype step')
    else:
        print('anchor for the prototype step not found — check manually')
else:
    print('prototype step already present')

r = subprocess.run(['python3', str(p)], capture_output=True, text=True)
print(r.stdout.strip()[:400])
print(r.stderr.strip()[:300])
