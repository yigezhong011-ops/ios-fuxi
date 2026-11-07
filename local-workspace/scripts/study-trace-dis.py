# Read-only: disassembly of libsystem_trace's preference parser around the privacy keys, with strings named. Run from dump/wsl with -I.
import importlib.util, re, subprocess, sys
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
A = 0x1a0702ad0; N = 0x1b0
open('/tmp/tr.bin', 'wb').write(bytes(c.rd(A, N)))
o = subprocess.run(['aarch64-linux-gnu-objdump', '-D', '-b', 'binary', '-m', 'aarch64', f'--adjust-vma={A:#x}', '/tmp/tr.bin'], capture_output=True, text=True).stdout
page = {}
for l in o.splitlines():
    m = re.match(r'\s*([0-9a-f]+):\s+[0-9a-f]+\s+(\S+)\s*(.*)', l)
    if not m: continue
    va, op, ar = int(m[1], 16), m[2], m[3]
    note = ''
    r = re.match(r'x(\d+), (0x[0-9a-f]+)', ar)
    if op == 'adrp' and r: page[int(r[1])] = int(r[2], 16)
    r = re.match(r'x(\d+), x(\d+), #(0x[0-9a-f]+)', ar)
    if op == 'add' and r and int(r[2]) in page:
        s = c.cstr(page[int(r[2])] + int(r[3], 16))
        if s: note = '  ; ' + repr(s)
    print(f'{va:#x} {op} {ar}{note}')
for t, name in ((0x1a0716648, 'callee 16648'), (0x1a0702ee8, 'callee 02ee8'), (0x1a677c480, 'callee 677c480')):
    print(name, [hex(x) for x in __import__('struct').unpack('<4I', bytes(c.rd(t, 16)))], c.stub(t))
