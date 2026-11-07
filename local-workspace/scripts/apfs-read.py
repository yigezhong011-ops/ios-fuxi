#!/usr/bin/env python3
"""Read-only APFS walker for a raw copy of Data that starts somewhere inside the container.

apfs-read.py <img> info
apfs-read.py <img> ls <volume index> <path>
apfs-read.py <img> stat <volume index> <path>
apfs-read.py <img> get <volume index> <path> <local output>
Blocks outside the copy raise an error naming the block. Encrypted volumes are not handled.
"""
import struct
import sys

BS = 4096
J_INODE, J_XATTR, J_DSTREAM_ID, J_EXTENT, J_DIR_REC = 3, 4, 10, 8, 9


class Img:
    def __init__(self, path):
        self.f = open(path, 'rb')
        self.f.seek(0, 2)
        self.blocks = self.f.seek(0, 2) // BS
        self.base = None
        self.cache = {}

    def raw(self, n):
        self.f.seek(n * BS)
        return self.f.read(BS)

    def block(self, paddr):
        n = paddr + self.base
        if not 0 <= n < self.blocks:
            raise IOError(f'block {paddr} is outside the copy (file block {n})')
        b = self.cache.get(n)
        if b is None:
            if len(self.cache) > 20000:
                self.cache.clear()
            b = self.cache[n] = self.raw(n)
        return b


def find_container(img):
    """Newest NXSB in the first 64 MiB, and the container's offset in the file from its checkpoint descriptor area."""
    best = None
    for n in range(min(img.blocks, 16384)):
        b = img.raw(n)
        if b[32:36] != b'NXSB':
            continue
        xid = struct.unpack_from('<Q', b, 16)[0]
        o, t = struct.unpack_from('<QI', b, 8)
        if best is None or xid > best[0]:
            best = (xid, n, b)
    if not best:
        raise SystemExit('no NXSB')
    return best


def nx_fields(b):
    d = {}
    d['block_size'], d['block_count'] = struct.unpack_from('<IQ', b, 36)
    d['next_xid'] = struct.unpack_from('<Q', b, 96)[0]
    d['desc_blocks'], d['data_blocks'], d['desc_base'], d['data_base'] = struct.unpack_from('<IIqq', b, 104)
    d['desc_next'], d['data_next'], d['desc_index'], d['desc_len'] = struct.unpack_from('<IIII', b, 128)
    d['omap_oid'] = struct.unpack_from('<Q', b, 160)[0]
    d['max_fs'] = struct.unpack_from('<I', b, 180)[0]
    d['fs_oids'] = [x for x in struct.unpack_from('<100Q', b, 184) if x]
    return d


class BTree:
    def __init__(self, img, root_paddr, resolve=None):
        self.img, self.root, self.resolve = img, root_paddr, resolve or (lambda oid: oid)

    def node(self, oid_or_paddr):
        return self.img.block(self.resolve(oid_or_paddr))

    @staticmethod
    def parse(b):
        flags, level, nkeys, tab_off, tab_len = struct.unpack_from('<HHIHH', b, 32)
        keys = 56 + tab_off + tab_len
        vals = BS - (40 if flags & 1 else 0)
        fixed = bool(flags & 4)
        out = []
        toc = 56 + tab_off
        for i in range(nkeys):
            if fixed:
                ko, vo = struct.unpack_from('<HH', b, toc + 4 * i)
                kl, vl = None, None
            else:
                ko, kl, vo, vl = struct.unpack_from('<HHHH', b, toc + 8 * i)
            out.append((keys + ko, kl, vals - vo if vo != 0xffff else None, vl))
        return level, out


def omap_lookup(img, omap_paddr, oid, xid=0xffffffffffffffff):
    b = img.block(omap_paddr)
    tree = struct.unpack_from('<Q', b, 48)[0]
    n = img.block(tree)
    while True:
        level, ents = BTree.parse(n)
        best = None
        for ko, _, vo, _ in ents:
            k_oid, k_xid = struct.unpack_from('<QQ', n, ko)
            if (k_oid, k_xid) <= (oid, xid):
                best = (k_oid, k_xid, vo)
            else:
                break
        if best is None:
            raise KeyError(oid)
        if level == 0:
            if best[0] != oid:
                raise KeyError(oid)
            return struct.unpack_from('<IIQ', n, best[2])[2]
        n = img.block(struct.unpack_from('<Q', n, best[2])[0])


class Volume:
    def __init__(self, img, nx_omap_paddr, oid):
        self.img = img
        self.paddr = omap_lookup(img, nx_omap_paddr, oid)
        b = img.block(self.paddr)
        if b[32:36] != b'APSB':
            raise IOError('not APSB')
        self.omap = struct.unpack_from('<Q', b, 128)[0]
        self.root = struct.unpack_from('<Q', b, 136)[0]
        self.name = b[704:960].split(b'\0')[0].decode(errors='replace')
        self.role = struct.unpack_from('<H', b, 964)[0]
        self.fs_flags = struct.unpack_from('<Q', b, 264)[0]
        self.files, self.dirs = struct.unpack_from('<QQ', b, 184)
        self.map = {}

    def v2p(self, oid):
        p = self.map.get(oid)
        if p is None:
            p = self.map[oid] = omap_lookup(self.img, self.omap, oid)
        return p

    def records(self, want_oid, want_type=None):
        """Every fs tree record of an object id (optionally one type): (type, node, key offset, key length, value offset, value length)."""
        res = []
        self._visit(self.v2p(self.root), want_oid, want_type, res)
        return res

    def _visit(self, paddr, oid, typ, res):
        n = self.img.block(paddr)
        level, ents = BTree.parse(n)
        keys = [struct.unpack_from('<Q', n, e[0])[0] for e in ents]
        ids = [(k & 0x0fffffffffffffff, k >> 60) for k in keys]
        lo_key = (oid, 0)
        hi_key = (oid, 16)
        for i, (e, kid) in enumerate(zip(ents, ids)):
            if level == 0:
                if kid[0] == oid and (typ is None or kid[1] == typ):
                    res.append((kid[1], n, e[0], e[1], e[2], e[3]))
                continue
            next_id = ids[i + 1] if i + 1 < len(ids) else (1 << 62, 0)
            if kid > hi_key or next_id < lo_key:
                continue
            child = struct.unpack_from('<Q', n, e[2])[0]
            self._visit(self.v2p(child), oid, typ, res)

    def children(self, oid):
        out = []
        for t, n, ko, kl, vo, vl in self.records(oid, J_DIR_REC):
            nl = struct.unpack_from('<I', n, ko + 8)[0] & 0x3ff
            name = n[ko + 12:ko + 12 + nl - 1].decode(errors='replace')
            fid, added, flags = struct.unpack_from('<QQH', n, vo)
            out.append((name, fid, flags & 0xf))
        return sorted(out)

    def walk(self, path):
        oid = 2
        for part in [p for p in path.split('/') if p]:
            for name, fid, _ in self.children(oid):
                if name == part:
                    oid = fid
                    break
            else:
                raise FileNotFoundError(f'{part} in {path}')
        return oid

    def inode(self, oid):
        for t, n, ko, kl, vo, vl in self.records(oid, J_INODE):
            parent, private, create, mod, change, access, iflags, nlink, prot, gen, bsd, uid, gid, mode = struct.unpack_from('<QQQQQQQiIIIIIH', n, vo)
            size = None
            base = 92
            if vl > base + 8:
                num, used = struct.unpack_from('<HH', n, vo + 92)
                pos = vo + 96 + num * 4
                for i in range(num):
                    x_type, x_flags, x_size = struct.unpack_from('<BBH', n, vo + 96 + i * 4)
                    if x_type == 8:                    # INO_EXT_TYPE_DSTREAM
                        size = struct.unpack_from('<Q', n, pos)[0]
                    pos += (x_size + 7) & ~7
            return dict(private=private, mod=mod, nlink=nlink, prot=prot, uid=uid, gid=gid, mode=mode, size=size, bsd=bsd, iflags=iflags)
        return None

    def extents(self, private):
        out = []
        for t, n, ko, kl, vo, vl in self.records(private, J_EXTENT):
            logical = struct.unpack_from('<Q', n, ko + 8)[0]
            ln, phys, crypto = struct.unpack_from('<QQQ', n, vo)
            out.append((logical, ln & 0x00ffffffffffffff, phys, crypto))
        return sorted(out)

    def read(self, oid):
        ino = self.inode(oid)
        data = bytearray()
        for logical, ln, phys, crypto in self.extents(ino['private']):
            data.extend(b'\0' * (logical - len(data)))
            for i in range(ln // BS):
                data.extend(self.img.block(phys + i))
        return bytes(data[:ino['size']]) if ino['size'] is not None else bytes(data)


def main():
    img = Img(sys.argv[1])
    xid, at, sb = find_container(img)
    d = nx_fields(sb)
    # The superblock copy sits in the checkpoint descriptor area: try each slot, and keep the base where the object map is really an omap.
    base = None
    for i in range(d['desc_blocks']):
        guess = at - (d['desc_base'] + i)
        n = d['omap_oid'] + guess
        if 0 <= n < img.blocks:
            o = img.raw(n)
            if struct.unpack_from('<I', o, 24)[0] & 0xffff == 0xb:
                base = guess
                break
    if base is None:
        raise SystemExit(f'no base found: {d}')
    img.base = base
    cmd = sys.argv[2]
    if cmd == 'info':
        print(f'newest NXSB at file block {at}, xid {xid}; container offset {base} blocks in the file; container blocks {d["block_count"]}, copy {img.blocks}')
        print({k: d[k] for k in ('desc_blocks', 'desc_base', 'omap_oid', 'max_fs')}, 'volumes', len(d['fs_oids']))
        for i, oid in enumerate(d['fs_oids']):
            try:
                v = Volume(img, d['omap_oid'], oid)
                print(i, repr(v.name), 'role', hex(v.role), 'files', v.files, 'dirs', v.dirs, 'fs_flags', hex(v.fs_flags), 'root', v.root)
            except Exception as e:
                print(i, 'oid', oid, 'unreadable:', e)
        return
    v = Volume(img, d['omap_oid'], d['fs_oids'][int(sys.argv[3])])
    oid = v.walk(sys.argv[4])
    if cmd == 'ls':
        for name, fid, typ in v.children(oid):
            i = v.inode(fid) or {}
            print(f"{'d' if typ == 4 else 'f' if typ == 8 else str(typ)} {i.get('mode', 0):o} {i.get('uid')}:{i.get('gid')} {i.get('size')} prot{i.get('prot')} id{fid} {name}")
    elif cmd == 'tree':
        limit = int(sys.argv[5]) if len(sys.argv) > 5 else 6
        def rec(o, pre, depth):
            for name, fid, typ in v.children(o):
                i = v.inode(fid) or {}
                print(f"{pre}{name}{'/' if typ == 4 else ''}  {i.get('mode', 0):o} {i.get('uid')}:{i.get('gid')} size={i.get('size')} mod={i.get('mod', 0) // 1000000000} id{fid}")
                if typ == 4 and depth < limit:
                    rec(fid, pre + '  ', depth + 1)
        rec(oid, '', 0)
    elif cmd == 'stat':
        print(oid, v.inode(oid))
    elif cmd == 'get':
        data = v.read(oid)
        open(sys.argv[5], 'wb').write(data)
        print('wrote', len(data), 'bytes')


main()
