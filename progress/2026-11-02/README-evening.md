# 2026-11-02 晚上：GPU 名单实验、壁纸覆盖、给作者的请求

> 接 `progress-2026-11-02-README.md`（下午：按键 + 亮度）。晚上做的是三件事，按交接文档的顺序。

## 1. GPU 客户端名单实验（镜像已做好，等上机）

### 先说一个把下午卡死的 bug

`addon-set-clients.py --same-size` 的填充搜索是**天文数字级**的：

```python
for n in range(0, 4000):                 # 4000 轮
    filler = sha256(str(n))*40           # 2560 字符
    for cut in range(1, len(filler)):    # 每轮 2559 次
        size = len(build(entries))       # ← 每次都重建 12 MB 的整个容器
```

下午 15:28 起的 `t32-gpu3` 构建跑了 **58 分钟 CPU 也没结束**，`t32-gpu4` 一直排在它后面。

**修法两点**：

1. 容器长度只取决于每个条目的 `pad8(压缩后大小)`，所以用解析公式算：
   `24 + Σ(24 + pad8(名字长度+1) + pad8(压缩大小))`，不再重建数据。
2. 填充内容换成**多行随机名**（`zz-filler-<12 hex>`）。原来是一长串重复的十六进制，
   zlib 把 40 KB 压成 272 字节，目标大小根本到不了。

修好后 **0.13 秒**完成（原来 58 分钟不结束），大小仍与原件完全一致。

### 镜像 `t32-gpu4.img`（93,904,896 字节）

名单：`SpringBoard,WidgetRenderer_Default,iconservicesagent,Preferences`

| 验证项 | 结果 |
|---|---|
| 内核（镜像内 vs 源文件） | 125,476,864 B，sha256 一致 |
| 附加包 | 12,172,992 B（= 原件），10 个条目（去掉 `bluetoothd.plist` 腾空间） |
| `.clients` | 4 个名字 + 38 行填充（只补长度，不匹配任何进程） |
| ADT | 13,944 B（未改动） |
| 启动参数 | 去掉 `-v` / `boot-progress=2` / `armcpu-diagnostics=1` / `qcom-usb-debug=1`；加上 `sheng-gpu-pause-us=100`、`sheng-backlight=1`，保留 `sheng-fb-gpu=1`、`sheng-data-persist=2` |
| 卷差异 | **6 个 64 KiB 区间**（Data 种子完好） |

> 参数编辑注意：`unixnu.toml` 只能变短（用空格补齐），变长会被 `make-arg-variant.sh` 拒绝。
> 所以多删了一个 `qcom-usb-debug=1`。

## 2. 壁纸覆盖（文件已生成，但**塞不进附加包**）

用 GitHub macOS runner 做：下载 iPadOS 17.7.11 21H461 的 IPSW → `bsdtar` 流式解出
`044-76040-038.dmg`（5.16 GB）→ `hdiutil attach` → 跑 `make-wallpaper-overlay.py`。整个流程约 2 分钟。

产出（`E:\DSH-Fuxi\wallpaper-overlay\`）：

```
J120.png             5,389,045 B   （2732×2732）
J120-Dark.png        5,262,293 B
main.caml              105,940 B   （已指向 PNG）
index.xml                1,355 B
assetManifest.caml         177 B
J120-q92.jpg           361,938 B   （本地转的 JPEG 版）
J120-Dark-q92.jpg      331,692 B
```

**为什么没进镜像**（按"做不到同大小就不要硬塞"）：

| 项 | 压缩后 |
|---|---|
| `main.caml` | ~40 KB |
| 两张 JPEG（2723² q92） | 694 KB |
| xml | ~1 KB |
| **需要** | **~735 KB** |
| 可删的非必需条目 | ~27 KB |
| `libvulkan_freedreno.dylib` | 3 MB **不能删**：`NativeAdrenoMetal` 内置 metal2vulkan，运行时要它 |

结论：只有**重建整个载荷**（`--gpu-addon ... --wallpaper DIR`，Data 种子重新生成）才能加。
我们手上没有 t32 的构建树，这一条写进了给作者的请求。

## 3. 给 ljhhkx529 的请求

`E:\DSH-Fuxi\REQUEST-ljhhkx529-gpu-2026-11-02.md`。上游 `fix/gpu-scheduling-and-metal`
分支（比 main 多 13 个提交）的 pin 已经查实：

```
AdrenoMetal  b82fa275  Default every Metal client to single-sample rendering   ← 小部件白
Adreno740    4db2aa75  双环调度 / 跨环顺序 / 全局 fence                        ← 设置慢
```

请求四件事：按这组 pin 重编插件与驱动、确认单一采样默认值、放宽客户端窗口数、
下次构建带上壁纸 PNG。

## 下次开机先做这个

1. 进 fastboot，`fastboot boot E:\DSH-Fuxi\t32-gpu4.img`（临时启动，不刷分区）。
2. 看四件事：小部件是否还白、设置打开速度、图标、是否变卡或重启。
3. 如果改善但不稳，再试只加 `SpringBoard,WidgetRenderer_Default` 的名单。

## 这一轮新增/修改的脚本

- `addon-set-clients.py`：**修好了死循环**（解析算大小 + 随机多行填充）。
- `make-t32-gpu4.sh`：gpu4 的构建命令（含多删 `qcom-usb-debug=1` 的原因）。
- `verify-gpu4.py`、`verify-gpu4-kernel.py`：镜像逐项验证（内核 sha、addon 名单、参数、卷差异）。
- `wallpaper-workflow.yml`：macOS 云端出壁纸覆盖的工作流。
- `check-vulkan-usage.sh`：证明插件内置 metal2vulkan（所以那个 dylib 不能删）。
