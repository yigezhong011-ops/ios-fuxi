#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
cp "$F" "$F.orig" 2>/dev/null || true
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()

# 1) Log(): mirror every line to the console
old_log = """  VA_START (Marker, Format);
  mLogLen += AsciiVSPrint (mLog + mLogLen, LOG_SIZE - mLogLen, Format, Marker);
  VA_END (Marker);
}"""
new_log = """  VA_START (Marker, Format);
  {
    CHAR8  Line[256];
    AsciiVSPrint (Line, sizeof (Line), Format, Marker);
    AsciiPrint ("%a", Line);
  }
  VA_END (Marker);
  VA_START (Marker, Format);
  mLogLen += AsciiVSPrint (mLog + mLogLen, LOG_SIZE - mLogLen, Format, Marker);
  VA_END (Marker);
}"""
assert old_log in t, 'Log anchor missing'
t = t.replace(old_log, new_log, 1)

# 2) keep the diagnostics on screen instead of resetting
old_reset = """  // The phone is unattended: always come back to Android.
  gRT->ResetSystem (EfiResetCold, EFI_SUCCESS, 0, NULL);"""
new_reset = """  //
  // Diagnostics build: stay on screen so the log can be read.
  //
  AsciiPrint ("\\nXNULOADER: payload was not started; diagnostics above, halting\\n");
  for (;;) {
    gBS->Stall (1000000);
  }"""
assert old_reset in t, 'reset anchor missing'
t = t.replace(old_reset, new_reset, 1)
p.write_text(t)
print('XnuLoader patched: console log + halt')
PY
grep -n 'AsciiPrint\|halting' "$F" | head -5
