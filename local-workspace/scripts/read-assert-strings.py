#!/usr/bin/env python3
"""Printable strings around each PBFModalRootViewController hit in SystemOS, to read the assertion's condition. Read-only."""
import re

with open('/mnt/e/DSH-Fuxi/dump/root-peek/systemos.img', 'rb') as f:
    for at in (52903872, 1279225593, 1279442344, 3105002569):
        f.seek(max(0, at - 5000))
        b = f.read(11000)
        print('=====', at)
        for m in re.finditer(rb'[ -~]{6,}', b):
            t = m[0].decode()
            if re.search(r'PBFModal|dataStore|DataStore|Invalid|condition|nil|must|scene|behaviorAssertion|not satisfying|expected|Assert|assert|\.m$', t):
                print('  ', m.start() - 5000, t[:170])
