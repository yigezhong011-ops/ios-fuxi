#!/usr/bin/env python3
"""Unpack a pulled export region: the crash snapshot (SHCRASH01) and the exported cache directory with zz-oslog.
Usage: read-diag.py <name>   reads /mnt/e/DSH-Fuxi/logs/twrp-<name>.bin and twrp-<name>-export.bin, writes /root/fuxi/diag-<name>/."""
import gzip
import re
import struct
import sys
from collections import Counter
from pathlib import Path

BLOCK = 4096
name = sys.argv[1]
logs = Path('/mnt/e/DSH-Fuxi/logs')
out = Path('/root/fuxi') / f'diag-{name}'
out.mkdir(parents=True, exist_ok=True)
head = (logs / f'twrp-{name}.bin').read_bytes()[:BLOCK]
region = (logs / f'twrp-{name}-export.bin').read_bytes()
fields =struct.unpack_from('<9I', head, 8 + 4 * 28)
export_first, export_blocks, export_bytes, export_gen, export_below, crash_blocks, crash_bytes, crash_gen, crash_name = fields
print('export first', export_first, 'blocks', export_blocks, 'bytes', export_bytes, 'gen', export_gen, 'below', export_below)
print('crash blocks', crash_blocks, 'bytes', crash_bytes, 'gen', crash_gen, 'name_len', crash_name)

base = len(region) - 4096 * BLOCK
hdr = region[base:base + BLOCK]
print('crash magic', hdr[:9])
if hdr[:8] == b'SHCRASH0':
    gen, name_len, size = struct.unpack_from('<III', hdr, 16)
    ips = region[base + BLOCK:base + BLOCK + size]
    (out / 'latest.ips').write_bytes(ips)
    print('crash file bytes', size, 'generation', gen)
    print(ips[:1400].decode(errors='replace'))

if export_bytes:
    blob = region[export_first * BLOCK:export_first * BLOCK + export_bytes]
    print('export magic', blob[:8])
    raw_bytes = struct.unpack_from('<I', blob, 8)[0]
    raw = blob[16:16 + raw_bytes]
    at = 8
    n = struct.unpack_from('<I', raw, at)[0]; at += 4
    root = raw[at:at + n].decode(); at += n
    count = struct.unpack_from('<I', raw, at)[0]; at += 4
    print('directory', root, 'files', count)
    for _ in range(count):
        plen, mode, uid, gid, size = struct.unpack_from('<IIIIQ', raw, at); at += 24
        rel = raw[at:at + plen].decode(); at += plen
        data = raw[at:at + size]; at += size
        if 'oslog' in rel and rel.endswith('.gz') and not Path(rel).name.startswith('.'):
            text = gzip.decompress(data).decode(errors='replace')
            (out / 'oslog.txt').write_text(text)
            print('oslog lines', text.count('\n'), 'first', text[:120].replace('\n', ' | '))
        elif rel.endswith(('.txt', '.log')) and size < 2000000:
            dest = out / 'files' / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)

log = out / 'oslog.txt'
if log.exists():
    lines = log.read_text(errors='replace').splitlines()
    pat = re.compile(r'PosterBoard|CollectionsPoster|GradientPoster|LegacyPoster|WallpaperKit|PaperBoard|PosterKit|WidgetRenderer|chronod|WidgetKit|Chrono', re.I)
    hits = [x for x in lines if pat.search(x)]
    bad = [x for x in hits if re.search(r' (error|fault) ', x) or re.search(r'fail|invalid|denied|cannot|could not|unable|timed? ?out|crash|not found|missing|nil', x, re.I)]
    print('lines', len(lines), 'poster/widget', len(hits), 'errors among them', len(bad))
    (out / 'poster-widget.txt').write_text('\n'.join(hits))
    (out / 'poster-widget-errors.txt').write_text('\n'.join(bad))
    procs = Counter(x.split()[2] if len(x.split()) > 2 else '-' for x in hits)
    print(procs.most_common(16))
    c = Counter(re.sub(r'0x[0-9a-f]+|\b\d+\b|[0-9A-F]{8}-[0-9A-F-]{27}', '#', ' '.join(x.split()[2:]))[:210] for x in bad)
    for k, v in c.most_common(45):
        print(v, k)
