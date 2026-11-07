#!/usr/bin/env python3
"""Inspect a flattened device tree: header, strings block, and the /chosen node."""
import struct
import sys

path = sys.argv[1] if len(sys.argv) > 1 else '/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt'
data = open(path, 'rb').read()
magic, totalsize, off_struct, off_strings, off_rsv, version, last_comp, boot_cpu, size_strings, size_struct = \
    struct.unpack('>10I', data[:40])
print('magic %#x totalsize %d version %d' % (magic, totalsize, version))
print('struct @%d (%d B), strings @%d (%d B)' % (off_struct, size_struct, off_strings, size_strings))
strings = data[off_strings:off_strings + size_strings]
print('strings:', strings.split(b'\0')[:12])

# walk the structure block
pos = off_struct
depth = 0
path_parts = []
chosen = None
while pos < off_struct + size_struct:
    tok = struct.unpack_from('>I', data, pos)[0]
    pos += 4
    if tok == 1:  # FDT_BEGIN_NODE
        end = data.index(b'\0', pos)
        name = data[pos:end].decode(errors='replace')
        pos = end + 1
        pos = (pos + 3) & ~3
        path_parts.append(name)
        depth += 1
    elif tok == 2:  # FDT_END_NODE
        if path_parts:
            path_parts.pop()
        depth -= 1
    elif tok == 3:  # FDT_PROP
        ln, nameoff = struct.unpack_from('>II', data, pos)
        pos += 8
        pname = strings[nameoff:strings.index(b'\0', nameoff)].decode(errors='replace')
        value = data[pos:pos + ln]
        pos = (pos + ln + 3) & ~3
        if depth <= 2:
            shown = value[:24].hex() if ln > 24 else repr(value)
            print('  %s/%s (len %d) = %s' % ('/'.join(path_parts), pname, ln, shown))
    elif tok == 4:  # FDT_NOP
        continue
    elif tok == 9:  # FDT_END
        break
    else:
        print('unknown token %#x at %d' % (tok, pos - 4))
        break
