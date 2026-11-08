# 交接给 Claude（2026-11-08 晚）

小米 13（fuxi，SM8550）UniXNU / iPadOS 17.7.11（21H461），设备身份 iPhone 14 Pro。
回复用中文短句。工作顺序（用户定的）：**Metal → 控制中心和键盘 → 电量显示 → 流畅度 → WiFi**。

本文接 `交接-DeepSeek-20261107(1).md`。那一份里的规则、脚本清单、环境坑仍然有效，
这里只写**这两天的新情况**和**下一步该做什么**。

## 一、现在的状态

```
手机：已断开（USB 全 Unknown，COM3 无）。插上线即可继续
boot_b：t50-daily-m2vsb.img（93970432 字节，606aaedfa4f277b6）
        备份 boot_b-before-m2vsb-082703.img（sha d3b1fd74b156a6da）
E:     约 18.7 GB 可用
仓库：yigezhong011-ops/ios-fuxi，最新 6dfda2a
```

## 二、今天做完的事

### 1. 新 Metal 插件 A/B → 已刷入日常版 ✓

| 镜像 | 有效轮 | 6 次滑动 sub 增量 | 中位 |
| --- | --- | --- | --- |
| 旧插件 `t50-auto-g7f9sb` | 3/3 | 3160 / 3402 / 3120 | **3160** |
| 新插件 `t50-auto-m2vsb` | 3/4 | 2939 / 2952 / 3138 | **2952** |

- 新插件**少 6.6% 提交**，画面变化次数相同（5/4/5 vs 5/5/4）
- 开应用：冷开 2.41 vs 2.42 s，热开 0.92 vs 0.93 s —— **完全一致**
- `rejected=0`（`accepted=609 rejected=0`、`accepted=90b rejected=0`）、无 panic
- 常用应用截图正常：设置、照片、Safari、地图、备忘录，无花屏/发黑
- 第 4 轮作废是**回落 boot_b**（约 1/3 概率，和插件无关）

**已刷**（只刷 boot_b、备份、读回校验 True）。刷后正常开机，锁屏（花纹壁纸 + 红条）、
桌面（壁纸 + 小组件 + 图标，无红条）都正常。

### 2. 20 帧：找到根因，但本地修不了 ✗

t50 内核里有这些字符串：

```
FuxiDpuScanoutStubs.c
DISPLAY HANDOFF: CPU scanout copy pending; diagnostic renderer yielding
[scanout wait] calls=%llu timeouts=%llu asked=%llums ...
```

**扫描输出的 CPU 拷贝还没实现**，渲染器每帧让出、靠 500 ms 超时兜底。
空闲 8 小时后计数：`calls=1854883 to=1237760`（**67% 超时**，静止时也在超时）。

官方文档的 `sheng-dpu-scanout` 实测（每档 1 轮，同样的滑动手势）：

| 镜像 | to 增量 | calls 增量 | sub 增量 |
| --- | --- | --- | --- |
| m2vsb 基线 | 10576 | 13922 | 2958 |
| + `sheng-dpu-scanout=1` | **21316** | 28695 | 6995 |
| + `sheng-dpu-scanout=2` | 11569 | 15159 | 3177 |

`1` 明显更差、`2` 持平 → **不是解**。这一项要作者实现真正的 scanout 路径。

### 3. 官方文档更新（`unixnu-build` 上游）

- **`sheng-metal-flow=1`**（`docs/drivers/adreno-metal.md`）：打开 lowering 线程、commit 直接提交、
  管线预热。默认关闭（"没测出帧率提升，还停在 logo 一次"）。**但 t50 内核二进制里没有这个参数名**
  （`strings` 查 0 次），对我们是空操作。
- **GPU BO 分配改成系统内存**：不再用 1 GiB 连续池，改 `IOBufferMemoryDescriptor`
  （可页、写合并、`prepare()` 接线），日志行 `[bo pool]` → `[bo memory]`。
- `docs/devices/fuxi.md` 新增 743 行完整机型记录（本地已拉到 `/root/fuxi/fuxi-upstream.md`）。

### 4. 锁屏红条：提高重建预算无效 ✗

状态栏库 `repair()` 每 family 上限 12 次、`attempt()` 30 次（60 秒）。改成 **40 次 / 60 次（120 秒）**
编了 `t50-auto-m2vsb2.img` 验证：**锁屏红条照旧**（`shot-t50-auto-m2vsb2-094833-lock.png`）。

结论：不是预算问题。两个方向：
1. 锁屏那条栏不在 `[UIWindow allWindowsIncludingInternalWindows:onlyVisibleWindows:]` 扫到的窗口里；
2. 它用的不是 `_UIStatusBar` / `STUIStatusBar`（dyld 里查过：没有 `CSProminentStatusBar`，
   只有 STUI 和 _UI 两族，各有一堆 VisualProvider）。

**下一步做法**：在锁屏上把窗口列表和栏的类名打到屏幕上（照抄 Hello 探针的 UILabel 手法），
看它到底在哪；再决定加第 3 个 family 还是改扫描范围。

### 5. Hello：`presentsWithTransaction` 初值 0，翻转实验没跑到 ⚠️

在 `fuxi-statusbar.c` 的探针里加了：读 `instances[7].view.layer.presentsWithTransaction`，
第 3 个 tick 后设成 YES 并 `setNeedsDisplay`。抓到的一帧：

```
pwt 0 set 0 | views 8 draws 13 presents 1 commits 1
0:h1 a1.0 1:h1 a1.0 2:h1 a1.0 3:h1 a1.0 4:h1 a1.0 5:h1 a1.0 6:h1 a1.0 7:h1 a1.0
t26 test present 0 0 0 0 nil 0 0 0 0
L1: Poster.HelloView
```

- `pwt` 初值是 **0（NO）**；
- `set 0` 说明翻转实验没执行（`inspectPwt()` 在 `afterSnaps == 2` 分支里，需要 `views>=8`）；
- 8 个实例全部有 1 层隐藏祖先，alpha 都是 1.0；
- `draws 13 presents 1 commits 1` 两次抓取完全一样 → **Hello 只画了一次就没再画**。

## 三、导航的坑（踩了两次，务必照做）

| 现象 | 原因 / 做法 |
| --- | --- |
| 进到蓝色壁纸预设 / 辅助功能「切换控制」 | 用 `ready 250; wait 20` 起手会点错。**必须用 `at 125` 起手**（文档原时序） |
| 截图全是 4524 字节 | 屏幕 30 秒无触摸会熄灭。**截图前先 `tap 180 400` 唤醒** |
| 锁屏截图 67200 / 74812 字节 | 正常锁屏 |
| 抓到 tick=1 的瞬间 | Hello 进编辑器后**等 60 秒**再截图，让探针跑够 tick |
| 这轮无效 | 启动回落 boot_b：日志有 `FALLBACK: this is boot_b`，`ctl-run` 会自动重试 2 次 |

## 四、脚本（都在 `E:\DSH-Fuxi\dump\wsl`）

| 用途 | 命令 |
| --- | --- |
| 一轮完整测试 | `ctl-run.ps1 -Name <镜像> -Steps "..." -Timeout 420` |
| 不重启直接测 | `ctl-run.ps1 -Attach -NoReboot -NoArgCheck -Steps "..."` |
| 叫回 fastboot | `qud-reboot.ps1`（实测 5 秒） |
| **插件 A/B** | `run-plugin-ab.ps1 -Rounds 3`；补齐有效轮：`run-plugin-ab2.ps1 -Target 3` |
| **开应用时间 A/B** | `run-open-plugin.ps1 -Timeout 450` |
| **scanout 对比** | `run-scanout-test.ps1 -Rounds 1` |
| 给已有镜像加启动参数 | `add-arg-to-img.sh <in.img> <arg=value> <out>`（会缩短 toml 标题腾空间） |
| 探针镜像 | `build-hello-probe.sh`（约 3 分钟） |
| 探针补丁 | `patch-probe-pwt.py` / `patch-probe-pwt2.py`（把 pwt 放到标签第一行） |

**本轮新增的可复用脚本**：`run-plugin-ab.ps1`、`run-plugin-ab2.ps1`、`run-open-plugin.ps1`、
`run-scanout-test.ps1`、`add-arg-to-img.sh`、`patch-probe-pwt*.py`、`clean-1108.sh`。

## 五、现有镜像

| 镜像 | 用途 |
| --- | --- |
| `t50-daily-m2vsb.img` | **已刷 boot_b**：新插件 + 状态栏库 + f9 |
| `t50-auto-m2vsb.img` | 上面日用版对应的测试版（`sheng-autoreset=420`） |
| `t50-auto-g7f9sb.img` | 旧插件测试版（对照） |
| `t50-auto-m2vsb-so1/so2.img` | scanout 实验版（**无效，可删**） |
| `t50-auto-m2vsb2.img` | 状态栏重建预算 40 版（**红条仍在，可删**） |
| `t50-auto-m2vhp.img` | Hello 探针版（每次编都变） |
| `t50-mine.img` | 给 `make-t50-sb.sh` 提供 loader 和 dtb，**不要删** |

## 六、下一步（按优先级）

1. **Hello 的 `presentsWithTransaction` 翻转实验**（交接文档第六节点名的第 2 项）：
   进编辑器 → 等 60 秒 → 截图看 `set 1` 后画面变不变。探针代码已经就位。
2. **Hello 与能显示的壁纸对比**（第 1 项）：Pride 第二个缩略图能显示、Hello 不能。
   需要把探针从"只认 Hello 类"扩展到也能看那个能显示的图层。
3. **锁屏红条**：先打印锁屏上的窗口和栏类名。
4. 上面任一项有结论后，回第六节继续；**Metal 三项完成标准**是：
   日用版正常、Hello/Pride/Unity/Rainbow 都能显示、多轮不卡死、流畅度不低于旧插件。

**已知没法本地解决的**：20 帧（scanout 桩）、`sheng-metal-flow`（内核没有）、
`FuxiDpuScanoutStubs` 的 CPU 拷贝 —— 这三项都需要作者的源码或新内核。

## 七、红线（与上一份交接一致）

- 刷写/写分区要用户逐次同意；只用 `fastboot boot` 做测试；刷前必须备份 boot_b 并读回校验。
- 动 Data 前先备份（`pull-data.ps1`）。
- 不永久删除用户软件；`keys\`、`token2.txt`、已刷镜像、回滚备份不能删。
- 公开仓库不能有镜像、内核、IPSW、token、芯片 ID、序列号、Data 原始转储。
- 不 force push；不碰作者的 `ljhhkx529/unixnu-fuxi`。
- 身份不匹配的镜像（`t32-*`）不要在这个 Data 上启动。
- 只报告验证过的结果；没测就写没测，推断要标明。
