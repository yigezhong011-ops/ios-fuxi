#!/usr/bin/env python3
"""Print the structure of the Adreno input pins."""
import json
from pathlib import Path

d = json.loads(Path('/root/ux3/fuxi/tree/scripts/data/adreno-inputs.json').read_text())
for key, value in d.items():
    print('==', key, type(value).__name__)
    if isinstance(value, dict):
        for kk, vv in list(value.items())[:4]:
            print('   %-24s -> %s' % (kk, json.dumps(vv)[:170]))
    else:
        print('   ', str(value)[:170])
