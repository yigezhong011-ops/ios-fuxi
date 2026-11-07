#!/bin/bash
# Read-only: how NativeHidInput::touchAction builds its report in t50, and the source if a local clone has it.
D=/root/fuxi/t50.dis; K=/root/fuxi/t50/kernel.macho
grep -rl --include='*.cpp' --include='*.mm' --include='*.h' -E 'NativeHidInput::touchAction|class NativeHidInput' /root/fuxi/ref-* 2>/dev/null | head -5
awk '$1>="fffffff00c032984:" && $1<="fffffff00c032d00:"' "$D" | sed -E 's/^fffffff00c0//' | cut -c1-72 | head -210
