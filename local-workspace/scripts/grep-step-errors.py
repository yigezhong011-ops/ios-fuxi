#!/usr/bin/env python3
"""Find the failure inside the downloaded Build kernel step log."""
from pathlib import Path

lines = Path('/root/ci-step.log').read_text(errors='replace').splitlines()
print('行数:', len(lines))
hits = [(i, l) for i, l in enumerate(lines)
        if any(k in l for k in ('error:', 'Error:', '##[error]', 'fatal:', 'No reference', 'failed'))]
print('命中:', len(hits))
for i, l in hits[:14]:
    print('%5d | %s' % (i, l[:170]))
