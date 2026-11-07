# local-workspace

小米 13（fuxi）移植的本地工作区：我们自己写的脚本、补丁和实验改动。这是原样导出，很多是一次性脚本，不是整理过的工程。

## 内容

- `scripts/`：全部脚本，来自本地的 `dump/wsl`。
- `trees/`：构建用的上游仓库里，我们本地的改动。文件名里有基线分支和提交。
  - `unixnu-fuxi-old-e5b3d35.diff` 和 `unixnu-fuxi-patches/`：设备仓库的改动和未跟踪的补丁。
  - `UniXNU-main-066c8d8.diff`、`uefi-fuxi-old-57969ab.diff`、`uefi-fuxi-FuxiUsbStartDxe/`：框架和固件。
  - `AdrenoMetal-local-commits/`：Metal 插件的本地提交（`git am` 格式）。
  - `amp-try-xnu.diff`：AMP 调度的试验改动，没有做成。
- `other/`：其他工作目录里的源码和说明。

## 主要入口

| 用途 | 脚本 |
| --- | --- |
| 手势、截图、自动测试 | `ctl-run.ps1` |
| 手势和核心掩码的内核补丁 | `touch-cave2.c`、`make-t50-tap.sh`、`patch-t50-tap.py` |
| GPU 槽位和地址空间 | `patch-t50-gpu7.py`、`make-t50-gpu7.sh` |
| 壁纸扩展的沙盒授权 | `patch-t50-grant.py`、`make-t50-grant.sh` |
| 合并新插件到 addon | `make-t50-plug.sh`、`fit-addon.py`、`patch-trustcache.py`、`fat-inplace.py` |
| udid-version | `patch-adt-udid.py`、`make-t50-udid.sh` |
| 固件 USB 启动 | `FuxiUsbStartDxe/`、`fw-build-usbstart.sh`、`swap-fd.py` |
| 插件 CI | `push-ci-small.sh`、`get-ci-plugin.sh`（工作流在 yigezhong011-ops/unixnu-ci） |

脚本写死了本地路径（`E:\DSH-Fuxi`、WSL 的 `/root/fuxi`）。多数补丁是对已编好内核的二进制补丁，地址只对应我们的 t50 内核。

## 没有放进来的

- 启动镜像、内核、IPSW、Apple 和第三方的二进制文件。
- 日志、Data 数据、设备树原始数据、密钥和令牌。
- 芯片 ID、序列号和本机用户名已替换成占位符，用到它们的脚本要先填回自己的值。

## 许可证

本目录里我们自己写的内容按 BSD-2-Clause-Patent 开源，见 `LICENSE`。

许可证只管这个目录，不管仓库的其他部分。`trees/` 里的补丁和改动，以及来自其他项目的文件，仍按原项目的许可证。这里不授予 Apple 或其他第三方内容的任何权利。
