# 2026-11-08 上午：新插件已刷入，scanout 开关无效

## 一、官方文档更新（`unixnu-build` 上游）

拉了上游，`docs/devices/fuxi.md` 增加了 743 行完整机型记录。和我们相关的三条：

1. **`sheng-metal-flow=1`**（`docs/drivers/adreno-metal.md`）：打开 metal2vulkan 的 lowering 线程、
   commit 直接提交、管线预热。默认关闭，因为"在 sheng 上没测出帧率提升，还有一次启动停在 logo"。
   **但 t50 内核二进制里没有这个参数名**（`strings` 查 0 次），所以对我们是空操作。
2. **GPU BO 分配改成系统内存**：上游不再用 1 GiB 连续池，改成 `IOBufferMemoryDescriptor`
   （可页、写合并、`prepare()` 接线），日志行从 `[bo pool]` 变 `[bo memory]`。
3. `sheng-dpu-scanout=2`：让显示管道通过 stage-1 SMMU 窗口直接读合成表面，默认关闭。

## 二、找 20 帧的根因：scanout 是桩

t50 内核里这些字符串：

```
FuxiDpuScanoutStubs.c
DISPLAY HANDOFF: CPU scanout copy pending; diagnostic renderer yielding
[scanout wait] calls=... timeouts=... asked=...ms
sheng-dpu-scanout
```

`CPU scanout copy pending` = **扫描输出的 CPU 拷贝还没实现**，所以渲染器每帧让出、
`[scanout wait]` 只能靠超时兜底。这解释了两件事：滑动 17–22 fps、以及 1.3–3.2 秒的长停顿。

### 实测 `sheng-dpu-scanout`（每档 1 轮，同一次滑动手势）

| 镜像 | to 增量（超时） | calls 增量 | sub 增量 | 画面变化 |
| --- | --- | --- | --- | --- |
| m2vsb（基线） | 10576 | 13922 | 2958 | 5 |
| + `sheng-dpu-scanout=1` | **21316** | 28695 | 6995 | 5 |
| + `sheng-dpu-scanout=2` | 11569 | 15159 | 3177 | 4 |

**1 明显更差，2 基本持平。都不是解。** 没刷进日用版。
结论：这一项要作者实现真正的 scanout 路径（或给源码），本地靠参数调不出来。

## 三、新 Metal 插件 A/B：不差，略好 → 已刷入

### 滑动（6 次滑动，3 轮有效）

| 镜像 | 有效轮 | sub 增量 | 中位 | 画面变化 |
| --- | --- | --- | --- | --- |
| 旧插件 `t50-auto-g7f9sb` | 3/3 | 3160 / 3402 / 3120 | **3160** | 5 / 4 / 5 |
| 新插件 `t50-auto-m2vsb` | 3/4 | 2939 / 2952 / 3138 | **2952** | 5 / 5 / 4 |

新插件 **少 6.6% 提交**，画面变化次数相同。第 4 轮是因为回落 boot_b 作废（约 1/3 概率，和插件无关）。

### 开应用（每轮 3 次 × 4 个应用）

| 镜像 | 冷开（中位） | 热开（中位） |
| --- | --- | --- |
| g7f9sb | 2.42 s | 0.93 s |
| m2vsb | 2.41 s | 0.92 s |

**完全一致。**

### 其他验收

- 无 panic（所有 run 的 COM3 日志里 `panic(` 计数为 0）。
- `FUXI120R ... accepted=609 rejected=0`、`accepted=90b rejected=0` → **rejected=0** ✓
- 常用应用截图（新插件）：设置、照片、Safari、地图、备忘录**全部正常显示**，无花屏、无发黑。

### 已刷入

```
t50-daily-m2vsb.img  93970432 字节  606aaedfa4f277b6
备份 boot_b-before-m2vsb-082703.img  sha d3b1fd74b156a6da
read back matches: True
RESULT flashed（只刷 boot_b）
```

刷后正常开机，锁屏（花纹壁纸 + 红条）、桌面（壁纸 + 小组件 + 图标，无红条）都正常，
即时滑动测试 `sub` 686→2397 正常增长。

**注意：** 锁屏红条仍在（交接文档已知，状态栏库只修了桌面/应用内）。

## 四、Hello 探针：加了 `presentsWithTransaction`

在 `fuxi-statusbar.c` 的探针里加了：
- 读 `instances[7].view.layer.presentsWithTransaction`，显示为 `pwt %d set %d`；
- 第 3 个 tick 后把它设成 `YES` 并 `setNeedsDisplay`，作为一次实验。

第一次跑（`shot-t50-auto-m2vhp-085436-hello.png`）标签显示：

```
0:h1 a1.0 1:h2 a1.0 2:h2 a1.0 3:h2 a1.0 4:h2 a1.0 5:h2 a1.0 6:h2 a1.0 7:h2 a1.0
t7 test present 0 0 0 0 nil 0 0 0 0
L1: Poster.HelloView
```

全部 8 个实例都有 1–2 层隐藏的祖先（h1/h2），alpha 都是 1.0。

把 `pwt` 放进标签第一行后（`shot-t50-auto-m2vhp-091918-hello.png`）：

```
pwt 0 set 0 | views 8 draws 13 presents 1 commits 1
0:h1 a1.0 1:h1 a1.0 2:h1 a1.0 3:h1 a1.0 4:h1 a1.0 5:h1 a1.0 6:h1 a1.0 7:h1 a1.0
t1 test present 0 0 0 0 nil 0 0 0 0
status 0 0 0 0
L0:
L1: Poster.HelloView
L2: UIView UIView
L3: ormedContentView
```

**结论：`presentsWithTransaction` 初始是 0（NO）**，8 个实例全部有隐藏祖先。
这一帧 `presents=1 commits=1`、tick 只有 1，说明抓到的是 Hello 刚进入编辑器的瞬间，
翻转实验（tick>3 且 views>=8 时把它设成 YES）还没执行到。**下一轮要等编辑器稳定后再截图**，
并看设定后 `set 1` 时画面变不变。

### 导航的坑（已验证两次）

用 `ready 250; wait 20` 代替 `at 125` 会**点错页面**：一次进了壁纸编辑器的蓝色预设，
一次进了「辅助功能 → 切换控制」。按文档的 `at 125` 时序才进到 Hello 编辑器。
所以：**导航必须用 `at 125` 起手**，并且每次都要看最后一张截图确认真的进了编辑器。

## 五、E 盘

清理了 `logs/carve-{hello2,hp1,hp2}`（5.4 GB）等，删后 **19–20 GB 可用**。

## 六、锁屏红条：试过提高重建预算，无效

状态栏库的 `repair()` 每个 family 最多重建 12 次，`attempt()` 每 2 秒一次、共 30 次（60 秒）。
锁屏那条栏可能出现在重试结束之后，所以把预算改成 **40 次重建 / 60 次重试（120 秒）**，
编了 `t50-auto-m2vsb2.img` 验：

```
shot-t50-auto-m2vsb2-094833-lock.png   红条仍在（74812 字节，和旧版锁屏一致）
```

**结论：不是预算问题。** 两个待查方向：

1. 锁屏那条栏不在 `[UIWindow allWindowsIncludingInternalWindows:onlyVisibleWindows:]` 能扫到的
   窗口里（比如在另一个进程：SpringBoard 的锁屏由 `CoverSheet` 呈现）。
2. 它用的不是 `_UIStatusBar` / `STUIStatusBar`，而是第三个类。

下一步：用探针在锁屏上把窗口和栏的类名打印出来，再决定修哪条路。

## 七、Hello 导航两次跑偏（记录）

- 用 `ready 250; wait 20` 起手：一次进壁纸编辑器蓝色预设，一次进「辅助功能 → 切换控制」。
- 用文档的 `at 125` 起手：进到编辑器，但抓到的是 **tick=1** 的瞬间
  （`pwt 0 set 0 | views 8 draws 13 presents 1 commits 1`），翻转实验没跑。
- 屏幕 30 秒无触摸会熄灭，截图变 4524 字节全黑；锁屏截图前要先 `tap` 一次唤醒。

## 八、状态

```
boot_b = t50-daily-m2vsb.img（新插件 + 状态栏库），已刷入并读回校验
备份 boot_b-before-m2vsb-082703.img sha d3b1fd74b156a6da
E: 约 19 GB 可用
```
