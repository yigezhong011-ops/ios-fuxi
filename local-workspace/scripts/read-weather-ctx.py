#!/usr/bin/env python3
"""What file are the Weather.app hits in? Prints printable runs. Read-only."""
import re
from pathlib import Path

b = Path('/mnt/e/DSH-Fuxi/logs/staged-ctx/weather.bin').read_bytes()
t = re.sub(rb'[^ -~\n]+', b' | ', b).decode()
print(t[:1800])
print('.....')
i = t.find('Weather.app', 12000)
print(t[i - 500:i + 900])
