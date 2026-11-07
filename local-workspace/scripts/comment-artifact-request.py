#!/usr/bin/env python3
"""Post the precise artifact request that the fuxi GPU work is blocked on."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'UniXNU/UniXNU'
ISSUE = 126
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

BODY = """## 进展：fuxi 的内核已经能从源码编出来了

今天把构建链打通了，`archive` 01–11 全部通过，产出了：

```
out/fuxi/kernel/kernel.macho  51,744,768 B  sha256 2d5b2cd60ba3124941c51d79a1b68a034efefe64f3de4d6384789fe38a96f45a
```

为走到这一步，设备仓库里加了这些（都在
[yigezhong011-ops/unixnu-fuxi@old](https://github.com/yigezhong011-ops/unixnu-fuxi)）：

- `patches/xnu/fuxi-link-stubs.patch`：在 `bsd_init.c` 末尾补 12 个 stub，
  让第一次链接通过（候选正是这次链接产出的）。每个定义都按调用处的
  `extern` 声明写（`void`、`int(dev_t)`、`int(const char *, dev_t *, char *, size_t)` 等）
- `configs/fuxi_gpu_defconfig`：full 配置 + `CONFIG_XNU_EXTRA_LD_ARCHIVES`
- `board.toml`：去掉 `build-sheng-platform-power.py`（它是唯一需要候选的归档）
- `scripts/data/fuxi-adreno-inputs.json`：ZAP 指向本机 ODM 的签名版
  （12,088 B，sha256 `fd107982…`；仓库原来 pin 的 9,040 B 版）

## 现在卡在三处"只有移植者才有的产物"

### 1. 候选内核的哈希白名单

`tree/scripts/audit-mobile-graphics-legacy.py:22`：

```python
require(hashlib.sha256(blob).hexdigest() == plan['candidate_sha256'] and
        (plan['candidate_sha256'] == 'aded28d3c61dafaf7b8a7c96b14427a798e9e95470ae6f287bcd038c07626798'
         or plan['original_executable_sha256']['com.apple.iokit.IOMobileGraphicsFamily'] == FAMILY_TEXT_SHA),
        'Exact previously qualified original-family candidate')
```

我们自己编出来的内核哈希不同，所以 archive-12 `build-native-legacy-display`
必然失败（然后 13–21 也不会跑）。

### 2. 运行时证据 `gdb-stop.json`

同一文件第 58 行读
`build/darwinboot-owner-hvf-mobile-graphics-legacy-class/gdb-stop.json`，
第 63 行要求 `d['kernel_sha256'] == plan['candidate_sha256']` 且
`d['function_return_stack_matched']` —— 这是在真机上抓的 GDB 现场。

### 3. GPU 参数与 addon 都已验证，问题不在它们

专家 payload 里 `kernel.macho.gpuaddon`（12,169,360 B）一直都在，原始参数是：

```
sheng-gpu-metal=1 sheng-gpu-addon=1 sheng-gpu-dcvs=1 sheng-fb-gpu=1
sheng-vsync=120 sheng-gpu-power=9
```

实测（同一内核）：

| 参数 | 结果 |
| --- | --- |
| 全套 GPU | 内核 `IRQ-off hard lock` |
| `metal` / `fb-gpu` / `metal+fb` / `metal+addon+fb` | 用户态进程 `sig=5`（SIGTRAP） |
| 无 GPU | 白苹果 → launchd → backboardd → SpringBoard（NSException 退出） |
| 另一份 GPU16 内核（有 `sheng-gpu-start/match/run`） | 卡在 SecurityLock，加不加 GPU 参数都一样 |

也就是说：addon、ZAP、设备树（GPU16 的 DTB 与仓库 fuxi.dtb 的 kgsl/GMU/SMMU
节点逐项一致）、参数组合都不是原因，**卡在内核里的 Adreno 驱动本身**，
这与 `docs/devices/fuxi-mouse233.md` 的 GPU 段（`planned`，
"the Adreno scripts … were not run against this board"）一致。

## 具体请求

1. **`kernel/kernel.macho`**（你本地能跑的那份）——哪怕只给这一份，我们就能立刻验证 GPU
2. 或者 `build/xnu-prelink/native-owner-mobile-graphics-candidate.macho` + 同名 `.json`
3. 或者告诉我：fuxi 是否计划迁到共享的 `component:Adreno740`（sheng 上验证过的路径）

如果这些不能公开，能否说明我们应该怎么在本地生成合格的候选——即
`candidate_sha256 == aded28d3…` 的那份内核是怎么构建出来的？
"""


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


c = call(f'https://api.github.com/repos/{REPO}/issues/{ISSUE}/comments', method='POST', data={'body': BODY})
print('已评论:', c.get('html_url') or c)
