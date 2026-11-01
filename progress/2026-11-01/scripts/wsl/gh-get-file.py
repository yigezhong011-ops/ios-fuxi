#!/usr/bin/env python3
"""Download one file from a GitHub repository (read-only) to stdout or a path.
Usage: gh-get-file.py owner/name ref path [out]"""
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
repo, ref, path = sys.argv[1:4]
req = urllib.request.Request(f'https://api.github.com/repos/{repo}/contents/{path}?ref={ref}',
                             headers={'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh',
                                      'Accept': 'application/vnd.github.raw'})
data = urllib.request.urlopen(req, timeout=120).read()
if len(sys.argv) > 4:
    pathlib.Path(sys.argv[4]).write_bytes(data)
    print(f'{path}: {len(data)} bytes -> {sys.argv[4]}')
else:
    sys.stdout.write(data.decode(errors='replace'))
