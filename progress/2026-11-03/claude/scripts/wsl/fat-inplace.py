#!/usr/bin/env python3
"""Overwrite a file of a FAT32 volume image in place: the new content goes into the file's own cluster chain and must be exactly
as long as the old file. The FAT, the directory entries and every other cluster stay untouched.
Why: the payload volume keeps its packed Data seed in clusters that FAT marks free; mtools' mcopy -o frees and reallocates the
chain, moved t32's kernel and ADT, and overwrote 41 MiB of that seed (t32-iphone1..3 stopped at the colour bars).
--grow lets the new content be longer than the old file as long as it still fits the file's existing cluster chain (the slack of
its last cluster); only the size field of its directory entry changes besides the data.
Usage: fat-inplace.py <volume.img> <::/path/in/volume> <new-file> [--grow]"""
import re
import struct
import subprocess
import sys

vol, path, src = sys.argv[1:4]
new = open(src, 'rb').read()
# mdir prints "<short name> [ext] <size with spaces> <date> <time> <long name>": the size is what precedes the date.
listing = subprocess.run(['mdir', '-a', '-i', vol, path], capture_output=True, text=True,
                         env={'MTOOLS_SKIP_CHECK': '1', 'PATH': '/usr/bin:/bin'}).stdout
line = next(l for l in listing.splitlines() if l.lower().rstrip().endswith(path.rsplit('/', 1)[1].lower()))
size = int(re.search(r'\s([\d ]+?)\s+\d{4}-\d\d-\d\d', line).group(1).replace(' ', ''))
grow = '--grow' in sys.argv[4:]
if len(new) != size and not (grow and len(new) > size):
    sys.exit(f'{path}: new size {len(new)} != old size {size}; refusing')
short = line.split()[:2]   # 8.3 name and extension as mdir prints them, e.g. KERNEL~1 ADT
chain_text = subprocess.run(['mshowfat', '-i', vol, path], capture_output=True, text=True,
                            env={'MTOOLS_SKIP_CHECK': '1', 'PATH': '/usr/bin:/bin'}).stdout
clusters = []
for a, b in re.findall(r'(\d+)(?:-(\d+))?', chain_text.split('<', 1)[1]):
    clusters += range(int(a), int(b or a) + 1)
with open(vol, 'r+b') as f:
    bpb = f.read(512)
    bps, spc, reserved, nfats = struct.unpack_from('<HBHB', bpb, 11)
    fatsz = struct.unpack_from('<I', bpb, 36)[0]
    data_start = (reserved + nfats * fatsz) * bps
    csize = bps * spc
    if len(clusters) * csize < size or (len(clusters) - 1) * csize >= max(size, 1):
        sys.exit(f'chain of {len(clusters)} clusters does not fit {size} bytes')
    if len(clusters) * csize < len(new):
        sys.exit(f'{len(new)} bytes do not fit the {len(clusters)}-cluster chain ({len(clusters) * csize} bytes)')
    entry = None
    if len(new) != size:
        # The directory entry: scan the parent directory's own chain for the 8.3 name with the old size.
        parent = path.rsplit('/', 1)[0]
        ptext = subprocess.run(['mshowfat', '-i', vol, parent], capture_output=True, text=True,
                               env={'MTOOLS_SKIP_CHECK': '1', 'PATH': '/usr/bin:/bin'}).stdout
        pclusters = []
        for a, b in re.findall(r'(\d+)(?:-(\d+))?', ptext.split('<', 1)[1]):
            pclusters += range(int(a), int(b or a) + 1)
        want = (short[0].ljust(8) + (short[1] if len(short) > 1 and not short[1][0].isdigit() else '').ljust(3)).encode()
        for c in pclusters:
            f.seek(data_start + (c - 2) * csize)
            block = f.read(csize)
            for o in range(0, csize, 32):
                if block[o:o + 11] == want and struct.unpack_from('<I', block, o + 28)[0] == size:
                    entry = data_start + (c - 2) * csize + o + 28
        if entry is None:
            sys.exit(f'directory entry {want!r} with size {size} not found')
    for i, c in enumerate(clusters):
        piece = new[i * csize:(i + 1) * csize]
        f.seek(data_start + (c - 2) * csize)
        f.write(piece)
    for i, c in enumerate(clusters):
        f.seek(data_start + (c - 2) * csize)
        if f.read(len(new[i * csize:(i + 1) * csize])) != new[i * csize:(i + 1) * csize]:
            sys.exit('read back mismatch')
    if entry is not None:
        f.seek(entry)
        f.write(struct.pack('<I', len(new)))
print(f'{path}: {len(new)} bytes written in place over {len(clusters)} clusters ({clusters[0]}..{clusters[-1]})' +
      (f', size {size} -> {len(new)}' if len(new) != size else ''))
