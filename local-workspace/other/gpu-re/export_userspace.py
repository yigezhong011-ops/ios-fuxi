"""Inventory and disassemble the GPU frontend binaries recovered from the addon."""
import hashlib
import json
from pathlib import Path
import subprocess
from recover_gpu import MachO, write_csv
import capstone

root = Path(__file__).resolve().parent
directory = root/'gpu-userspace'
out = directory/'analysis'
out.mkdir(exist_ok=True)
binaries = [directory/'addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal',
            directory/'addons/NativeAdrenoMetal.bundle/libvulkan_freedreno.dylib',
            directory/'bin/adrenoprobed']
results = []
for path in binaries:
    m = MachO(path)
    symbols = []
    for s in m.symbols:
        if s['type']&0xe0 or not s['name']:
            continue
        sec = m.section(s['value']) if s['value'] else None
        symbols.append(dict(name=s['name'], address=f"0x{s['value']:016x}",
                            defined=(s['type']&0x0e)==0x0e,
                            executable=sec['executable'] if sec else False))
    write_csv(out/(path.name+'.symbols.csv'), symbols, ['address','name','defined','executable'])
    imports = [s['name'] for s in symbols if not s['defined']]
    (out/(path.name+'.imports.txt')).write_text('\n'.join(imports)+'\n')
    md=capstone.Cs(capstone.CS_ARCH_ARM64,capstone.CS_MODE_LITTLE_ENDIAN)
    md.skipdata=True
    labels={int(s['address'],16):s['name'] for s in symbols if s['defined'] and s['executable']}
    instructions=0
    with (out/(path.name+'.assembly.s')).open('w') as handle:
        handle.write('// AArch64 disassembly from the original GPU frontend binary.\n')
        for sec in m.sections:
            if not sec['executable'] or not sec['size']:
                continue
            handle.write('// SECTION '+sec['segment']+','+sec['name']+'\n')
            buffer=[]
            for address,size,mnemonic,operands in md.disasm_lite(m.data[sec['offset']:sec['offset']+sec['size']],sec['va']):
                if address in labels:
                    buffer.append('\n// '+labels[address]+'\n')
                buffer.append(f'{address:016x}: {mnemonic:<10} {operands}\n')
                instructions+=1
                if len(buffer)>=4096:
                    handle.writelines(buffer)
                    buffer=[]
            handle.writelines(buffer)
    results.append(dict(file=str(path.relative_to(directory)), bytes=len(m.data),
        sha256=hashlib.sha256(m.data).hexdigest(), symbol_count=len(symbols),
        code_symbols=sum(s['defined'] and s['executable'] for s in symbols),
        undefined_symbols=len(imports), disassembly=str((out/(path.name+'.assembly.s')).relative_to(directory)),
        disassembled_entries=instructions))
    print(results[-1],flush=True)
(out/'userspace-summary.json').write_text(json.dumps(results,indent=2)+'\n')
