#!/usr/bin/env python3
"""Add the fuxi GPU/GMU/SMMU identity (read from the device tree) to the issue:
it is the 'next action' the device record asks for."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'UniXNU/UniXNU'
ISSUE = 126
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

BODY = """补充一条：`docs/devices/fuxi-mouse233.md` 的 GPU 段写着
`planned` / "No device evidence for GPU on fuxi… the Adreno scripts in the
repository target the tablet configuration and were not run against this board"，
`Next action` 是「先记录 fuxi 上的 GPU/GMU 身份和它用的 SMMU stream」。

我按这条把 fuxi 自己的设备树（`uefi-fuxi/Resources/DTBs/fuxi.dtb`，
815,093 字节）反编译读了，结果如下，供参考。

## fuxi（SM8550 / A740）实测

`qcom,kgsl-3d0@3d00000`

```
compatible       = "qcom,adreno-gpu-gen7-2-1", "qcom,kgsl-3d0"
reg              = 0x3d00000 0x40000   (kgsl_3d0_reg_memory)
                   0x3d61000 0x800     (cx_dbgc)
                   0x3d50000 0x10000   (rscc)
                   0x3d8b000 0x2000    (isense_cntl)
                   0x3d9e000 0x1000    (cx_misc)
                   0x10900000 0x80000  (qdss_gfx)
                   0x10048000 0x8000   (qdss_etr)
                   0x10b05000 0x1000   (qdss_tmc)
interrupts       = <0 0x12c 4>        # GIC SPI 300
ubwc-mode        = 4
min-access-length= 0x20
interconnect     = <0x52 0x10 0x3d 0x200>   # gpu_icc_path
zap-shader       = memory-region <0x2cf>    # gpu_micro_code_region@9b09a000, 0x2000 字节
```

`qcom,kgsl-iommu@3da0000`（`qcom,kgsl-smmu-v2`，reg 0x3da0000 0x40000）

| 上下文 | iommus | stream |
| --- | --- | --- |
| `gfx3d_user` | `<0xdd 0x00 0x00>` | **0** |
| `gfx3d_lpac` | `<0xdd 0x01 0x00>` | **1** |
| `gfx3d_secure` | `<0xdd 0x02 0x00>` | **2** |

`qcom,gmu@3d69000`（`qcom,gen7-gmu`）

```
reg            = 0x3d68000 0x37000   (gmu)
                 0xb280000 0x10000   (gmu_pdc)
                 0x3d40000 0x10000   (gmu_ao_blk_dec0)
iommus         = <0xdd 0x05 0x00>    # stream 5
interrupts     = <0 0x130 4>, <0 0x131 4>   # hfi = 304, gmu = 305
gmu-freq-table = <0xd1cef00 0x40 0x20c85580 0x80>
clock-names    = gmu_clk, cxo_clk, axi_clk, memnoc_clk, ahb_clk, hub_clk
regulator-names= vddcx, vdd
mboxes         = <&aop 0>            # qcom,ipc-core = 0x400000 0x100000
```

## 和驱动的关系

`ljhhkx529/NativeAdreno-fuxi` 的 README 写的是
"Current state: GPU commands and the scanout copy run on **sheng hardware**"，
而它的头文件里 include 的是 `ShengGmu.h`、`ShengGmuConfig` 等。

所以想请教：fuxi 的 GPU 是否计划按上面这组板级值（stream 0/1/2 + GMU stream 5、
GMU 三个窗口基址、hfi/gmu 中断 304/305）在 `NativeAdreno-fuxi` 里独立成型，
还是等它迁移到共享的 `component:Adreno740`？如果方便，能否说明
`a740_zap.mbn` 应该取哪一份（仓库 pin 的 9,040 B 还是 ODM 的 12,088 B）？
"""


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


c = call(f'https://api.github.com/repos/{REPO}/issues/{ISSUE}/comments', method='POST', data={'body': BODY})
print('已评论:', c.get('html_url') or c)
