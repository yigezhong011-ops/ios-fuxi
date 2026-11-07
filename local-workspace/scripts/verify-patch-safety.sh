#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import struct

orig = open('/root/fuxi/backboardd.orig', 'rb').read()
pat = open('/root/fuxi/backboardd.patched', 'rb').read()

def parse(d):
    magic, ct, cs, ft, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', d[:32])
    cmds = []
    off = 32
    for _ in range(ncmds):
        c, s = struct.unpack_from('<II', d, off)
        cmds.append((c, s, off))
        off += s
    return dict(ncmds=ncmds, sizeofcmds=sizeofcmds, cmds=cmds, end=off)

a, b = parse(orig), parse(pat)
print('原: ncmds=%d sizeofcmds=%d 结束=%#x' % (a['ncmds'], a['sizeofcmds'], a['end']))
print('新: ncmds=%d sizeofcmds=%d 结束=%#x' % (b['ncmds'], b['sizeofcmds'], b['end']))

# 1) 除了最后新增的一条，原有命令必须逐字节相同
same = orig[32:32 + a['sizeofcmds']] == pat[32:32 + a['sizeofcmds']]
print('原有加载命令逐字节不变:', same)

# 2) 新命令必须是最后一条且是 LC_LOAD_DYLIB
c, s, off = b['cmds'][-1]
name = None
if c == 0xc:
    no = struct.unpack_from('<I', pat, off + 8)[0]
    e = pat.index(b'\0', off + no)
    name = pat[off + no:e].decode()
print('新增命令: cmd=%#x size=%d name=%s' % (c, s, name))

# 3) 填充区之后（__text 起点及以后）必须完全没变
first_text = 0x2090
print('__text 之后内容不变:', orig[first_text:] == pat[first_text:])
print('新增命令结束 %#x < __text %#x: %s' % (b['end'], first_text, b['end'] < first_text))

# 4) 每个 segment 的 fileoff 都没被改动
def segs(d, n):
    out = {}
    off = 32
    for _ in range(n[0]):
        c, s = struct.unpack_from('<II', d, off)
        if c == 0x19:
            nm = d[off + 8:off + 24].split(b'\0')[0].decode()
            fo = struct.unpack_from('<Q', d, off + 40)[0]
            fs = struct.unpack_from('<Q', d, off + 48)[0]
            out[nm] = (fo, fs)
        off += s
    return out

sa, sb = segs(orig, (a['ncmds'],)), segs(pat, (b['ncmds'],))
print('segment fileoff/filesize 全部一致:', sa == sb)
if sa != sb:
    for k in sa:
        if sa[k] != sb.get(k):
            print('  差异', k, sa[k], sb.get(k))
PY
