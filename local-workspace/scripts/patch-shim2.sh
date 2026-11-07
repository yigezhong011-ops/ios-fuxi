#!/bin/bash
set -euo pipefail
SHIM=/root/uefi-fuxi/BootShim/BootShim.S
cp "$SHIM.orig" "$SHIM" 2>/dev/null || true
python3 - "$SHIM" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old_head = """_Head:
  adr   x1, _Payload    /* Set _Entry address */
  b     _Start          /* Jump to the real code */"""
new_head = """_Head:
  adr   x1, _Payload    /* Set _Entry address */
  mov   x19, x0         /* keep the bootloader's device tree pointer */
  nop
  nop
  nop
  b     _Start          /* Jump to the real code */"""
assert old_head in t
t = t.replace(old_head, new_head, 1)

old_entry = """  dsb   sy
  ic    iallu
  dsb   sy
  isb
  br    x5"""
new_entry = """  dsb   sy
  ic    iallu
  dsb   sy
  isb
  mov   x0, x19         /* hand SEC the device tree in x0 */
  nop
  nop
  nop
  br    x5"""
assert old_entry in t
t = t.replace(old_entry, new_entry, 1)
p.write_text(t)
print('shim patched with aligned padding')
PY
grep -n 'x19\|nop' "$SHIM" | head -12
