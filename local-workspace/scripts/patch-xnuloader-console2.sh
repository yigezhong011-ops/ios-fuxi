#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()

# 1) add a console helper before Log()
helper = '''
STATIC
VOID
ConsoleAscii (
  IN CONST CHAR8  *Text
  )
{
  CHAR16  Buffer[257];
  UINTN   Index;

  if (gST == NULL || gST->ConOut == NULL || Text == NULL) {
    return;
  }

  for (Index = 0; (Index < 256) && (Text[Index] != 0); Index++) {
    Buffer[Index] = (CHAR16)Text[Index];
  }

  Buffer[Index] = 0;
  gST->ConOut->OutputString (gST->ConOut, Buffer);
}

'''
if 'ConsoleAscii' not in t:
    anchor = 'VOID\nEFIAPI\nLog (\n'
    assert anchor in t, 'Log definition anchor missing'
    t = t.replace(anchor, helper.lstrip('\n') + anchor, 1)

# 2) use it instead of AsciiPrint
t = t.replace('    AsciiPrint ("%a", Line);', '    ConsoleAscii (Line);')
t = t.replace('  AsciiPrint ("\\nXNULOADER: payload was not started; diagnostics above, halting\\n");',
              '  ConsoleAscii ("\\nXNULOADER: payload was not started; diagnostics above, halting\\n");')
assert 'AsciiPrint' not in t, 'AsciiPrint still present'
p.write_text(t)
print('patched: console helper instead of AsciiPrint')
PY
grep -n 'ConsoleAscii' "$F" | head -5
