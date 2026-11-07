"""Assemble and validate GPU reverse-engineering artifacts for delivery."""
import collections
import csv
import hashlib
import html
import json
from pathlib import Path
import re
import struct
import sys
from recover_gpu import MachO, write_csv

root=Path(__file__).resolve().parent
sys.path.insert(0,str(root/'tools/angr-runtime'))
import pydemumble
out=root/'kernel-gpu'
m=MachO(root/'extracted/kernel.macho')
functions=json.loads((out/'gpu-functions.json').read_text())
groups=collections.defaultdict(list)
for f in functions:
    f['demangled']=pydemumble.demangle(f['name'][1:] if f['name'].startswith('__Z') else f['name'])
    groups[f['member']].append(f)
    assert (out/'pseudocode'/f"{f['va']:016x}.c").is_file(),f['name']
write_csv(out/'gpu-functions-demangled.csv',functions,['address','size','name','demangled','member','source','sha256'])
merged=out/'pseudocode-by-object'
merged.mkdir(exist_ok=True)
for member,fs in groups.items():
    filename=member.removesuffix('.o')+'.cpp'
    text='// Decompiled C/C++ pseudocode from linked machine code. Not a buildable source module.\n'
    for f in fs:
        text+='\n// '+f['demangled']+'\n'+(out/'pseudocode'/f"{f['va']:016x}.c").read_text(encoding='utf-8')+'\n'
    (merged/filename).write_text(text,encoding='utf-8')

layout=json.loads((out/'analysis-elf-layout.json').read_text())
elf=(out/layout['file']).read_bytes()
raw_code=0
for f in functions:
    original=m.data[m.offset(f['va'],f['size']):m.offset(f['va'],f['size'])+f['size']]
    assert hashlib.sha256(original).hexdigest()==f['sha256']
    r=next(r for r in layout['ranges'] if r['va']<=f['va'] and f['va']+f['size']<=r['end'])
    off=r['file_offset']+f['va']-r['va']
    assert elf[off:off+f['size']]==original,f['name']
    raw_code+=len(original)
for member,fs in groups.items():
    filename=re.sub(r'[^a-zA-Z0-9_.-]','_',member)+'.linked.bin'
    data=(out/'linked-code-by-object'/filename).read_bytes()
    manifest=json.loads((out/'linked-code-by-object'/(filename+'.json')).read_text())
    for frag in manifest:
        va=int(frag['va'],16)
        original=m.data[m.offset(va,frag['size']):m.offset(va,frag['size'])+frag['size']]
        assert data[frag['output_offset']:frag['output_offset']+frag['size']]==original
firmware=json.loads((out/'firmware/manifest.json').read_text())
for fw in firmware:
    data=(out/'firmware'/fw['file']).read_bytes()
    assert len(data)==fw['size']==fw['declared_size_u64']
    assert hashlib.sha256(data).hexdigest()==fw['sha256']
status=[]
for f in functions:
    text=(out/'pseudocode'/f"{f['va']:016x}.c").read_text(encoding='utf-8')
    assert f['address'] in text and f['name'] in text
    status.append(dict(address=f['address'], name=f['name'], member=f['member'],
                       pseudocode_bytes=len(text.encode()), opaque_abi_fallback_mode='opaque register' in text))
(out/'pseudocode-coverage.json').write_text(json.dumps(status,indent=2)+'\n')
validation=dict(selected_function_entries=len(functions), object_groups=len(groups),
    pseudocode_files=len(status), byte_verified_code=raw_code, firmware_files=len(firmware),
    analysis_elf_code_bytes_match=True, per_object_linked_bytes_match=True,
    original_image_executed=False,
    limitation='Pseudocode presence and byte identity are verified, not semantic equivalence or buildability.')
(out/'validation.json').write_text(json.dumps(validation,indent=2)+'\n')
summary=json.loads((out/'recovery-summary.json').read_text())
summary.update(pseudocode_files=len(status),opaque_abi_fallback_mode_files=sum(r['opaque_abi_fallback_mode'] for r in status))
summary.pop('opaque_abi_fallbacks',None)
(out/'recovery-summary.json').write_text(json.dumps(summary,indent=2)+'\n')

module_rows='\n'.join(f'| `{member}` | {len(fs)} | {sum(f["size"] for f in fs):,} |'
                     for member,fs in groups.items())
readme=f'''# boot.img 中的 Adreno 740 GPU 逆向结果

输入镜像 SHA-256：`9fe80a90c492d72be49c3af3663e218ea65c80db8157a864e9a3095b21e0086a`。
提取内核 SHA-256：`{summary['kernel_sha256']}`。

本包只包含该镜像的 GPU 相关提取物、静态逆向结果与复现脚本。

## 已交付

- **{len(functions)} 个有名称及 STABS 长度的函数入口、{len(groups)} 个对象分组**。其中 `libNativeAdreno.a` 的 43 个成员覆盖通用 A740、GMU/HFI、SMMU、内存、ring、submit、user-client 和加速器；另含板级 `GpuPowerProbe`、插件装载与呈现衔接函数。
- 所选函数的 **{raw_code:,} 字节原始链接后机器码**、完整 AArch64 反汇编，以及每个入口的自动 C/C++ 伪代码。这里的“覆盖”是按保留符号与对象来源选定的范围，不代表证明所有运行时依赖都在本包内。
- **3 份原始 GPU 固件**：`gmu_gen70200.bin`（66,844 字节）、`a740_sqe.fw`（74,804 字节）、`a740_zap.mbn`（12,088 字节）。长度同时核对 `_image`、`_end` 和 `_size`，内容直接来自该镜像。
- **2 套用户客户端分发表（14 / 16 个 selector）、14 张虚表**及数据切片。`RecoveredGpuMethodABI.h` 给出从表中直接读取的输入/输出长度；没有猜填结构体字段。
- 原镜像 GPU addon 中的 **NativeAdrenoMetal、libvulkan_freedreno.dylib 和 adrenoprobed** 完整二进制、伴随配置及用户态反汇编。
- **保留原虚拟地址的 ELF 分析容器**，方便在 IDA、Ghidra、Binary Ninja 中继续分析。

## 从哪里看

| 文件或目录 | 用途 |
| --- | --- |
| `kernel-gpu/pseudocode-by-object/` | 按原编译对象合并的 C/C++ 伪代码，优先读 `GpuPowerProbe.cpp`、`Adreno740.cpp`、`NativeAdrenoUserClient.cpp`、`NativeAdrenoSubmit.cpp`、`NativeAdrenoVm.cpp` |
| `kernel-gpu/pseudocode/` | 按原虚拟地址命名的单函数伪代码 |
| `kernel-gpu/assembly/` | 原地址、原指令字节及已解析的直接跳转目标 |
| `kernel-gpu/NativeAdreno-GPU-analysis-only.elf` | 仅供静态分析的 GPU 页面、代码、数据和符号容器 |
| `kernel-gpu/gpu-functions-demangled.csv` | 函数地址、长度、还原后的 C++ 名称、对象来源和代码指纹 |
| `kernel-gpu/gpu-direct-calls.json` | 直接调用/跳转关系；间接虚调用不宣称已全部解析 |
| `kernel-gpu/gpu-interface-tables.json` | 原始分发表及虚表的指针和目标名称 |
| `kernel-gpu/RecoveredGpuMethodABI.h` | selector 输入/输出尺寸表 |
| `kernel-gpu/linked-code-by-object/` | 按对象归组的链接后字节及逐函数偏移清单 |
| `kernel-gpu/data-slices/` | 已命名数据的切片，除独立固件外长度通常取下一个符号作为上界，可能带填充 |
| `kernel-gpu/firmware/` | 独立 GMU、SQE、ZAP 固件和来源地址 |
| `gpu-userspace/addons/NativeAdrenoMetal.bundle/` | 从 addon 原样恢复的用户态插件和 Turnip 库 |
| `gpu-userspace/analysis/` | 用户态符号、导入及反汇编 |
| `kernel-gpu/validation.json` | 实际完成的静态核对范围 |

## 读伪代码时必须保留的区别

这是**二进制逆向结果，不是原始工程源码，也不是可直接链接的 `.a` / `.o` / `.kext`**。原始重定位、未保留的类型、宏、模板及被优化掉的逻辑不能由这个镜像无损恢复。文件中的自动类型和局部变量是反编译器推断，尚未证明语义等价，也未通过重编与实机验证。

内核真实地址为 `0xfffffff...`。为了避开反编译器内部有符号地址字段的限制，仅在分析视图中使用：

`分析地址 = 原始地址 - 0xfffffff000000000`

分析视图内指向该内核范围的已识别数据指针也随之归一化。伪代码中的数字地址需要加回该偏移；汇编、原始代码片段和 ELF 分析容器仍保留原地址，输入镜像及提取内核没有被改写。

部分批次启用了未知按值 C++ 类型的不透明寄存器处理模式，以继续生成伪代码；对应文件有注释，处理模式记录在 `pseudocode-coverage.json`，遇到的未知类型名单保留在 `pseudocode/opaque-types-*.json`。这些记录不证明推断的类型宽度正确，不能直接当成接口定义。

`MinimumOSVersion=17.0` 是本镜像 Metal 插件 Info.plist 的原始声明；本次只逆向，未修改该声明，也未据此承诺兼容 iOS 16。ADT 中按名称/compatible 筛选没有发现 GPU/GMU/SMMU 专用节点；板级初始化代码和固件已单独保留，不能据此断言 GPU 没有初始化。

ELF 文件包含选中函数和数据所在页面，部分页包含相邻内容，外部函数以符号引用保留。它不是可执行的 Linux 程序，也不是可装载的 XNU 驱动。

## 静态核对结果

所选 {len(functions)} 个入口全部有反汇编和伪代码。所有导出的机器码片段和 ELF 内对应函数字节均与原内核一致；3 份固件长度与内嵌长度记录一致。没有执行提取出的 ARM64 程序。本结果不包含重新编译内核、启动镜像或设备刷写。

## 原编译对象分组

| 对象 | 函数入口 | 代码字节 |
| --- | ---: | ---: |
{module_rows}

## 复现入口

`unpack_boot.py` → 从原 boot 镜像解出 Android kernel 并解压；FAT 位于解压内容偏移 `0x3000c0`。
用 mtools 读取 FAT 中 `EFI/UniXNU/Payloads/kernel.macho`、`.gpuaddon`、`.adt`；`unpack_gpuaddon.py` 解出 addon。
`recover_gpu.py`（Python + Capstone）恢复内核符号/对象/机器码，`recover_tables.py` 导出固件与接口表，`decompile_gpu.py`（angr 10.0.5）生成伪代码，`make_analysis_elf.py` 生成分析容器，`assemble_result.py` 汇总并核对。
`export_userspace.py` 导出用户态符号及 AArch64 反汇编。脚本中的工作目录指向本次本地归档，迁移机器时需要调整。

反编译方法参考：[angr Decompiler](https://docs.angr.io/en/latest/analyses/decompiler.html)。组件背景参考：[Adreno740](https://github.com/UniXNU/Adreno740)、[GPU 与 Metal 适配](https://unixnu.com/zh/porting/gpu)。这些公开源码是辅助参考，没有冒充本镜像已恢复的原始源码。
'''
(root/'README-逆向结果.md').write_text(readme,encoding='utf-8')
rows=[]
for member,fs in groups.items():
    href='kernel-gpu/pseudocode-by-object/'+member.removesuffix('.o')+'.cpp'
    rows.append('<tr><td><a href="'+html.escape(href,quote=True)+'">'+html.escape(member)+'</a></td><td>'+str(len(fs))+'</td><td>'+str(sum(f['size'] for f in fs))+'</td></tr>')
page='''<!doctype html><meta charset="utf-8"><title>Adreno740 逆向结果</title>
<style>body{font:16px system-ui;max-width:1050px;margin:40px auto;padding:0 24px;color:#203040}table{border-collapse:collapse;width:100%}td,th{text-align:left;border-bottom:1px solid #ddd;padding:8px}a{color:#1555a0}small{color:#666}</style>
<h1>Adreno 740 GPU 逆向结果</h1><p>517 个函数入口的原始指令、反汇编与自动 C/C++ 伪代码；3 份 GPU 固件及原始用户态插件。</p>
<p><strong>伪代码不是原始源码，不能直接重编为驱动。</strong></p>
<p><a href="README-逆向结果.md">说明与边界</a> · <a href="kernel-gpu/NativeAdreno-GPU-analysis-only.elf">IDA/Ghidra 分析文件</a> · <a href="kernel-gpu/gpu-functions-demangled.csv">函数索引</a> · <a href="kernel-gpu/firmware/">GPU 固件</a> · <a href="gpu-userspace/">用户态组件</a></p>
<table><thead><tr><th>原编译对象 / 伪代码</th><th>函数入口</th><th>代码字节</th></tr></thead><tbody>'''+''.join(rows)+'</tbody></table>'
(root/'index.html').write_text(page,encoding='utf-8')
print(json.dumps(validation,indent=2))
