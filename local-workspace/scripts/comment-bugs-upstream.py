#!/usr/bin/env python3
"""Report the four real defects found while building the fuxi port from source:
each one blocks a clean checkout on a host that is not Apple's toolchain."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'UniXNU/UniXNU'
ISSUE = 126
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

BODY = """再补充一条：为了让 fuxi 的内核能在干净环境编出来，我把构建整条链跑了一遍，
发现四个**真实缺陷**。前三个是与宿主无关的代码问题，第四个是工具链假设。

## 1. `IOUserServer.cpp` 的定义与 iig 生成的原型不一致

```
iokit/Kernel/IOUserServer.cpp:666: error: out-of-line definition of
  'UserSetProperties' does not match any declaration in 'IOService'
iokit/Kernel/IOUserServer.cpp:672: error: out-of-line definition of
  'SendIOMessageServicePropertyChange' does not match any declaration in 'IOService'
```

`iokit/DriverKit/IOService.iig` 里这两项在 `#if PRIVATE_WIFI_ONLY` 内，iig 生成到
`IOService_Methods` 时**带了 `OSDispatchMethod supermethod = NULL` 参数**：

```c
kern_return_t UserSetProperties(OSContainer * properties, OSDispatchMethod supermethod = NULL);
kern_return_t SendIOMessageServicePropertyChange(OSDispatchMethod supermethod = NULL);
```

而 `IOUserServer.cpp` 里 `IOService::UserSetProperties(OSContainer *)` 没有这个参数。

`iokit/conf/Makefile.template:20` 已定义 `-DPRIVATE_WIFI_ONLY=1`，所以这是
iig 对 `LOCAL` 方法的归类与 Apple 的 iig 不同（Apple 会放进 `X_ImplMethods`）。
补法要么让 iig 输出 `_Impl` 形式，要么定义处补上参数。

## 2. `BootProgress.c` 与 `osfmk/kern/boot_progress.h` 冲突

```
kits/sheng/BootProgress.c:1085:26: error: too many arguments provided to
  function-like macro invocation
kits/sheng/BootProgress.c:1085:6: error: variable has incomplete type 'void'
```

`boot_progress.h` 在 `XNU_BOOT_PROGRESS` 为假时把同名函数定义成宏。
`scripts/build-boot-progress.py` 拿 `startup.o.json` 的编译选项（其中
`XNU_BOOT_PROGRESS=0`）并 `-I …/osfmk`，于是真实实现被宏顶掉。
需要在该次编译里 `-UXNU_BOOT_PROGRESS -DXNU_BOOT_PROGRESS=1`。

## 3. `archive-12 build-native-legacy-display` 缺分析输入

```
FileNotFoundError: build/display-analysis/mobile-graphics-legacy-abi.json
```

`build-native-legacy-display.py:21` 直接读这个文件，它由
`scripts/audit-mobile-graphics-legacy.py` 产出；后者在没有
`build/native-prelink` 候选时退出 `No reference candidate available`，
于是 `CONFIG_XNU_NATIVE_LEGACY_DISPLAY=y` + 无候选 = 必然失败。

## 4. 引导自举链本身缺一环

第一次链接需要四个由 archive 提供的符号，而那些 archive 又要求先有 prelink 候选：

```
Undefined symbols for architecture arm64:
  "_native_verified_block_root_authorized", referenced from: _bsd_init in bsd_init.o
  "_native_verified_block_volume_device",  referenced from: _load_init_program in kern_exec.o
  "_native_verified_root_probe",           referenced from: _bsd_init in bsd_init.o
  "_sheng_pmgr_run",                       referenced from: _bsd_init in bsd_init.o
```

我在 `bsd_init.c` 末尾加了 no-op 定义才让第一次链接通过（这只为生成候选）。
建议文档里明确「第一次链接用 stub、候选生成后再由真 archive 覆盖」这个循环，
或者让 `build-sheng-platform-power.py` 在无候选时自行降级。

## 另外两个工具链细节

- `SETUP/*` 的 Makefile 使用 `HOST_COMPAT_CFLAGS`/`HOST_COMPAT_LIBS`，
  当 `HOST_CC` 已经是自带前缀头的包装器时，这两个变量会造成
  glibc `unistd.h` 冲突和 `-lhostcompat` 链接失败。
- `SETUP/config/Makefile` 调用 `/usr/sbin/bison`（macOS 路径），
  flex 又需要 `/usr/sbin/m4`。

需要的话我可以把这四处整理成 patch 或 PR。
"""


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


c = call(f'https://api.github.com/repos/{REPO}/issues/{ISSUE}/comments', method='POST', data={'body': BODY})
print('已评论:', c.get('html_url') or c)
