#!/usr/bin/env python3
"""File a technical report/question issue on the fuxi device repository."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'ljhhkx529/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

TITLE = "fuxi 上已跑到用户态，但开启 GPU 参数后用户态进程 SIGTRAP；另外干净构建缺 xnu-prelink candidate"

BODY = """## 背景

用 `UniXNU@main` + `unixnu-fuxi@old` + `uefi-fuxi@old` 在小米 13（fuxi）上验证。
`userdata` 用 `./unixnu build userdata` 从 iPadOS 17.7.11（21H461）的
`OS` / `Cryptex1,SystemOS` 生成并刷入（稀疏镜像 8.21 GB），`root_match_volume_uuid`
在镜像中命中（偏移 43 MB / 51 MB / 155 MB 处都能搜到）。

boot 镜像按 `uefi-fuxi/scripts/bootimage.py` 的布局打包：
`kernel = gzip(BootShim + UEFI FD + payload 卷) + 设备树`，ramdisk 字段 1 字节。

## 已经跑通的

- UEFI → UniXNU 菜单 → DarwinBoot → 内核入口
- 显示（GOP/PM4）、内存管理
- **UFS 读到根卷**（诊断行 `req` 达到 24 万）
- **APFS 根挂载、白苹果、launchd**
- 诊断面板出现 `PROC backboardd` / `PROC SpringBoard`

## 问题 1：只要开 GPU 参数，用户态就崩

| 参数组合 | 结果 |
|---|---|
| 无 `sheng-gpu-*` / `sheng-fb-gpu` | ✅ 白苹果 + launchd + backboardd + SpringBoard（SpringBoard 因无合成 NSException 退出） |
| `sheng-fb-gpu=1 sheng-vsync=120` | ❌ 黑屏 + `EXIT ... sig=5` |
| `sheng-gpu-metal=1 sheng-fb-gpu=1` | ❌ 黑屏 + `sig=5` |
| `sheng-gpu-metal=1 sheng-gpu-addon=1 sheng-fb-gpu=1` | ❌ 黑屏 + `sig=5` |
| 全套（+ `sheng-gpu-dcvs` / `sheng-gpu-power=9`） | ❌ 内核 `IRQ-off hard lock` |

诊断行示例：

```
EXIT p229 live/activated status=exited sig=5 exited=0 ne2 sub=5
PROC backboardd p56 ...
PROC SpringBoard p27 ...
FS: total verif=3419ms read=2115ms req=249784
```

`sig=5` 是 SIGTRAP，看起来是 Metal 设备创建失败后进程被陷阱杀死。

另外注意到：仓库里 pin 的 `qcom/sm8550/fuxi/a740_zap.mbn` 是 **9,040 字节 / `e05d28dd…`**，
而从本机 ODM 分区提取的 `a740_zap.mbn` 是 **12,088 字节 / `fd107982…`**。
想确认哪个才是 GPU 需要的（ODM 版是签名版？）。

## 问题 2：干净 clone 无法构建内核

`macos-26` + Xcode 26.6 CI 上：

1. `archive-11-build-sheng-platform-power` 报
   `No reference candidate available`，
   `build-sheng-platform-power.py` 需要 `build/native-prelink/*-candidate.macho`；
   文档 `porting/migration#build-inputs` 把它列为「Qualified … candidate.macho」必需输入。
2. 用 `fuxi_defconfig`（stage 2a）先编一次并 stage 候选，仍不行——主构建的 `tree`
   步骤会重建树，候选被清掉。
3. 试 `main` 分支（format 2）时，`archive-05 NativeAES` 之后
   `ar: build/software-aes/NativeAES.o: No such file or directory`。

## 想问的

1. 能否提供一份可用的 `kernel/kernel.macho`（以及 `build/xnu-prelink/*candidate.macho`
   和对应 `.json`）？仅用于个人验证，不会分发。
2. `main` 分支迁移到 format 2（`component:Adreno740`）到哪一步了？
   `NativeAES` 那处缺 `.o` 是迁移未完成，还是我这边少了输入？
3. GPU 部分：fuxi 是继续用 `NativeAdreno`（板级）还是打算切到共享的
   `component:Adreno740`（像 sheng 那样）？

## 环境

- 设备：Xiaomi 13（fuxi，SM8550，A740，1080×2400）
- 系统：iPadOS 17.7.11 21H461，Darwin 23.6.0
- 启动：`fastboot boot`（不改分区），userdata 已按上面的窗口布局刷入
- 平台种子：`--unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}"`
"""


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


issue = call(f'https://api.github.com/repos/{REPO}/issues', method='POST',
             data={'title': TITLE, 'body': BODY})
print('已开 issue:', issue.get('html_url') or issue)
