#!/usr/bin/env python3
"""Read-only: disassemble PosterBoard's buildDataStoreForURL with selectors and strings named. Usage: read-store-build.py <dsc dir> <start hex> <bytes hex>"""
import importlib.util
import sys
args = sys.argv[1:]
sys.argv = ['x', args[0]]
spec = importlib.util.spec_from_file_location('c', '/mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
c.dump(int(args[1], 16), int(args[2], 16))
