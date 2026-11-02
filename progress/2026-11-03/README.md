# 2026-11-03 凌晨：壁纸实验（重建载荷）

> 承接 `progress-2026-11-02-late.md`。这一轮的目标是把壁纸 PNG 塞进附加包——旧附加包必须原地等长，
> 所以改成**从零重建整个载荷**。

## 做成的事

**从零重建载荷这条路完全走通了。** 用 t32 的内核 + trust cache + Data 种子 + 44 个启动参数，
在本地跑 `./unixnu build payload`（老树 + 设备仓库 `fuxi_full_defconfig`），重新生成 ADT，
再用 `pack-payload.sh` 装进启动镜像。第一版（`t32-wall2`）**开机成功**：

- 设置打开变快 ✓
- 图标出现 ✓
- 小部件白 → 黑 ✓（和 gpu6 一致，证明名单生效）
- 壁纸仍然黑 ✗

出现的坑（都记下来，明天接着弄）：

| 坑 | 处理 |
|---|---|
| `--kernel-arg -v` 被当成选项 | 用 `--kernel-arg=-v` 形式 |
| trust cache 不在 `board.toml` 白名单 | 把 t32 那份的 sha256 加进 `[payload] trust_cache_sha256` |
| `panic_screen = true` 要求特定入口序列 | 改 `false`（t32 的内核序列不同） |
| 命令行 1004 字节 > 1000 上限 | 清空 `board.toml` 的 `kernel_args`，只用 `--kernel-arg` 传；并去掉 `armcpu-diagnostics=1` |
| **`sheng-data-persist=2` 下第二次开机卡米标** | 用 `sheng-data-reset=1` 试 → **卡三色条后黑屏**（重置太重） |

## 壁纸为什么还没出来

内核里确实有这段：`/private/var/ngpu/wallpaper`（源）→
`/Library/Wallpaper/Collections/iPadOS_17~ipad.wallpaperCollection/Wallpapers/
7570.iPadOS_17_Flat-1024w-1366h@2x~ipad.wallpaper/`（目标），
符号 `_native_gpu_addon_prepare.wallpaper_source` / `.wallpaper_point`，
并且**没有专门的启动参数**——它挂在 `sheng-gpu-addon=1` 下。

所以怀疑两点：
1. 内核写入 Data 与挂载的**顺序**，以及 PosterBoard 的缓存；
2. 第二次读回持久化的 Data 时崩（wall2 第二次开机卡米标），说明这份 Data 状态不干净。

## 明天的第一件事

**把壁纸和 Data 持久化解耦**：先用 `sheng-data-persist=2`（不加 reset）+ 壁纸，开机一次；
如果第二次崩，就说明是"Data 里多了 10.6 MB 壁纸"导致的，改为
`--wallpaper` 只放 `main.caml` + 小尺寸 PNG（每张 ~300 KB 的 JPEG 改名 PNG），
把写入量降到 1 MB 以内再试。

## 镜像（都在 E 盘，都只临时启动）

| 文件 | 说明 | 结果 |
|---|---|---|
| `t32-wall2.img` | 壁纸 + 2 客户端 | **第一次开机成功**，第二次卡米标 |
| `t32-wall3.img` | 加 `sheng-data-reset=1` | 卡三色条后黑屏 |
| `t32-gpu6.img` | 只改名单（壁纸白→黑） | 反复可开机 |

boot_b 始终是 `t32-bl-daily`（按键 + 亮度），没有任何改动。
