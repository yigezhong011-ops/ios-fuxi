#!/usr/bin/env python3
"""Report today's two blocking findings upstream so the port author can answer."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'UniXNU/UniXNU'
ISSUE = 126
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

BODY = """## 今天的成果：自编内核在真机上跑起来了

`fuxi_gpu_defconfig` + 设备仓库（[yigezhong011-ops/unixnu-fuxi@old](https://github.com/yigezhong011-ops/unixnu-fuxi)）
现在能从干净 clone 编出完整内核，20 个 archive 全过：

```
kernel.macho  52,793,344 B
```

真机实测到的进度（都是今天第一次达到）：

| 阶段 | 证据 |
| --- | --- |
| 内核启动 | 诊断面板：`MEM totalMiB=4864`、`IONVRAM size=8192`、`cntfrq=dt-timebase=19200000` |
| 显示输出 | 绿色交接条 + 内核 console 文字上屏 |
| UFS 读盘 | `FS: total verif=… req=…` |
| **APFS 挂载根卷** | panic 屏：`rootvp not authenticated after mounting` @ `bsd_init.c:1098` |

## 卡点一：根鉴权（`autherr`）无法在本地产出

`bsd_init.c:1057-1099` 里 `require_rootauth` 在 iOS 上恒为 TRUE，然后

```c
int autherr = VNOP_IOCTL(rootvnode, FSIOC_KERNEL_ROOTAUTH, NULL, 0, ctx);
...
if (autherr && !owner_authorized) panic("rootvp not authenticated after mounting");
```

而 `owner_authorized` 只在 `XNU_OWNER_ROOT_TRUST=1` 时赋值，那条链是：
`OWNER_ROOT_TRUST` → `OWNER_ROOT_AUDIT` → `VERIFIED_ROOT_PROBE` → `libVerifiedRootProbe.a`
→ 需要 `build-verified-root.py` 产出的 owner 策略（`verification.json` / `manifest.bin` / `trusted-key.bin`）。

**问题**：这套策略能否从 IPSW 本地生成，还是必须用你签名的那份？
如果是后者，能否提供 `build/verified-root-os/` 下的三个文件，
或者说明 `XNU_OWNER_ROOT_TRUST=0` 时内核应有的行为（我们现在只能 panic）。

## 卡点二：`EFI_COMPROMISED_DATA` 的占位符规则

按 `docs/concepts/payload.md:77`（"每个输入都必须有对应的占位符"），我们实测：

| payload | 结果 |
| --- | --- |
| 内核 + ADT（无 trust cache） | ✅ 能启动，到 `bsd_init` |
| 同上 + trust cache，ADT 是**不带占位符**的旧版（13,544） | ❌ 菜单报 `Compromised Data` |
| 内核 + **CI 生成的 ADT（13,596，带占位符）** + trust cache | ⚠️ 加载通过，但早期 hard lock（`IRQ=0`、`GIC stride=0`、`DISPLAY stage=0`） |

想确认：`13,596` 那份 ADT 是否就是带 `TrustCache` 占位符的正确版本？
如果是，为什么它会让内核比"无 trust cache"时更早卡住（early boot 而不是 bsd_init）？

## 另外两个观察

1. **console 字形错位**：内核 console 的文字每 3 个字符丢 1 个
   （`ec ive exce i  cc ed while d mig he C  a e`），而 DarwinBoot 的横幅渲染正常。
   疑似 `boot_progress_bind(base,w,h,rb,…)` 的 `rb` 与实际步进不符（fuxi 是 1080×2400）。
   请问 `rb` 的来源是 ADT 的 `/chosen/memory-map` 还是设备树？

2. **PMGR**：`CONFIG_XNU_SHENG_PMGR=y` + `build-sheng-platform-power.py` 现在能编过
   （候选由两段式 pre_build 产出），但 `sheng-pmgr=2` 下 `GIC stride` 仍是 0。

如果需要，我可以把这些整理成 PR。
"""


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


c = call(f'https://api.github.com/repos/{REPO}/issues/{ISSUE}/comments', method='POST', data={'body': BODY})
print('已评论:', c.get('html_url') or c)
