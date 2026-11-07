"""Static decompilation of the recovered GPU functions, without running the image."""
import argparse
import json
import logging
from pathlib import Path
import re
import sys
import time

root = Path(__file__).resolve().parent
sys.path.insert(0, str(root / 'tools/angr-runtime'))
logging.basicConfig(filename=root/'decompiler-diagnostics.log', level=logging.ERROR)
import angr
from recover_gpu import MachO

parser = argparse.ArgumentParser()
parser.add_argument('--filter', default='')
parser.add_argument('--limit', type=int, default=0)
parser.add_argument('--shard', type=int, default=0)
parser.add_argument('--shards', type=int, default=1)
parser.add_argument('--opaque-enums', action='store_true', help='Lower unresolved by-value C++ types to opaque register values')
args = parser.parse_args()
opaque_types = set()
if args.opaque_enums:
    from angr.analyses.calling_convention.calling_convention import CallingConventionAnalysis
    from angr.sim_type import SimCppClass, SimTypeLongLong
    original_cpp_parser = CallingConventionAnalysis._analyze_demangled_name
    def opaque_cpp_parser(self, name):
        result = original_cpp_parser(self, name)
        if result is None:
            return result
        cc, proto, library = result
        lowered = []
        for arg in proto.args:
            if isinstance(arg, SimCppClass):
                opaque_types.add(str(arg))
                arg = SimTypeLongLong(signed=False).with_arch(self.project.arch)
            lowered.append(arg)
        proto.args = tuple(lowered)
        return cc, proto, library
    CallingConventionAnalysis._analyze_demangled_name = opaque_cpp_parser
out = root/'kernel-gpu/pseudocode'
out.mkdir(exist_ok=True)
m = MachO(root/'extracted/kernel.macho')
functions = json.loads((root/'kernel-gpu/gpu-functions.json').read_text())
# The decompiler's native IR uses signed metadata fields. Normalize the kernel's
# high-half VAs in an analysis-only view; originals and all byte exports stay intact.
bias = 0xfffffff000000000
regions = sorted((f['va']-bias, f['va']+f['size']-bias) for f in functions)
project = angr.Project(str(m.path), auto_load_libs=False,
    main_opts=dict(backend='blob', arch='aarch64', base_addr=min(s['va']-bias for s in m.segments if s['filesize']),
                   entry_point=regions[0][0], segments=[(s['offset'],s['va']-bias,s['filesize'])
                       for s in m.segments if s['filesize']]))
import struct
minimum = min(s['va'] for s in m.segments if s['filesize'])
maximum = max(s['va']+s['size'] for s in m.segments if s['filesize'])
normalized = 0
for seg in m.segments:
    if not seg['filesize'] or seg['prot']&4:
        continue
    blob = m.data[seg['offset']:seg['offset']+seg['filesize']]
    for match in re.finditer(b'\xff\xff\xff', blob):
        offset = match.start()-5
        if offset < 0 or offset%8 or offset+8>len(blob):
            continue
        value, = struct.unpack_from('<Q', blob, offset)
        if minimum <= value < maximum:
            project.loader.memory.store(seg['va']-bias+offset, struct.pack('<Q',value-bias))
            normalized += 1
print('analysis pointer normalizations:',normalized,flush=True)
print('recovering GPU control flow', flush=True)
cfg = project.analyses.CFGFast(regions=regions, function_starts=[f['va']-bias for f in functions],
    force_complete_scan=False, function_prologues=False, normalize=True,
    resolve_indirect_jumps=True, data_references=True, start_at_entry=False,
    skip_specific_regions=False, exclude_sparse_regions=False)
for sym in m.symbols:
    if not sym['type'] & 0xe0 and sym['type'] & 0x0e == 0x0e and sym['value']:
        project.kb.labels[sym['value']-bias] = sym['name']
        func = project.kb.functions.get(sym['value']-bias)
        if func:
            func.name = sym['name']
for f in functions:
    func = project.kb.functions.get(f['va']-bias)
    if func:
        func.name = f['name']
if args.opaque_enums:
    import copy
    from angr.sim_type import SimCppClass, SimTypeLongLong
    adjusted = 0
    for func in project.kb.functions.values():
        proto = func.prototype
        if proto is not None and any(isinstance(t,SimCppClass) for t in proto.args):
            proto = copy.deepcopy(proto)
            proto.args = tuple(SimTypeLongLong(signed=False).with_arch(project.arch)
                               if isinstance(t,SimCppClass) else t for t in proto.args)
            func.prototype = proto
            adjusted += 1
    print('opaque by-value type prototypes:',adjusted,flush=True)
print('CFG functions:', len(project.kb.functions), flush=True)
selection = [f for i,f in enumerate(functions) if i%args.shards==args.shard and
             (not args.filter or args.filter in (f['name']+f['member']))]
if args.limit:
    selection = selection[:args.limit]
results = []
for index,f in enumerate(selection):
    path = out/(f"{f['va']:016x}.c")
    start = time.monotonic()
    status, error = 'ok', ''
    if path.is_file() and path.stat().st_size > 100:
        status = 'cached'
    else:
        try:
            func = project.kb.functions.get(f['va']-bias)
            if func is None:
                raise RuntimeError('CFG did not recover this function')
            dec = project.analyses.Decompiler(func, cfg=cfg.model)
            if not dec.codegen or not dec.codegen.text:
                raise RuntimeError('decompiler produced no C output')
            text = '// Automatically decompiled pseudocode; not original C/C++ source.\n'
            text += '// Original linked VA: '+f['address']+'; size: '+str(f['size'])+' bytes.\n'
            text += '// Object: '+f['member']+'\n// Symbol: '+f['name']+'\n\n'
            text += '// Analysis addresses = original VA - 0xfffffff000000000.\n'
            if args.opaque_enums:
                text += '// Unresolved by-value C++ types are opaque register values in this fallback.\n'
            path.write_text(text+dec.codegen.text, encoding='utf-8')
        except Exception as exc:
            status, error = 'failed', repr(exc)
    result=dict(address=f['address'], name=f['name'], member=f['member'], status=status,
                seconds=round(time.monotonic()-start,3), error=error)
    results.append(result)
    (out/f'status-{args.shard}.json').write_text(json.dumps(results,indent=2)+'\n')
    if index%10==0 or status=='failed' or index+1==len(selection):
        print(index+1,'/',len(selection),f['address'],status,result['seconds'],error[:160],flush=True)
print('DONE', sum(r['status']!='failed' for r in results),'/',len(results),flush=True)
if args.opaque_enums:
    (out/f'opaque-types-{args.shard}.json').write_text(json.dumps(sorted(opaque_types),indent=2)+'\n')
