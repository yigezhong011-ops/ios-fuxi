# 给 ljhhkx529：fuxi 的 120 帧与壁纸（2026-11-05，附实测数据）

设备小米 13（fuxi，SM8550），UniXNU + iPadOS 17.7.11 根卷，iPhone 14 Pro 身份。
内核是 t50（2026-11-03 那次构建），GPU 附加包用 UniXNU `793d6bddf7` 编的插件（含 bridge 补丁 0020）。

## 1. 120 帧：卡在 `[scanout wait]` 的 500 ms 超时

一次受控测试（同一次启动，先静止 180 s，再连续滑动 150 s，`t50-mine-gpu-fix.img`）：

```
[scanout wait] calls=3312 timeouts=550 asked=500ms mean=500849us
[scanout prepare] prepare calls=2761 failures=0 ... sent=0 arms=0 idle=0 late=0
[dpu] st=3 hw=90000000 us=1001026 i1 en=0 cfg=800000 cnt=0 f=1406540..1406601 ln=1 vp=0 s=0
[display state] d+5808: 438 960 ac9 ac9 ac9 ff000000 0 1 1 ...
```

- **550 次超时 × 500 ms ≈ 275 秒**，整轮运行只有 322 秒；
- 早期几乎每次必超时：`calls=2 timeouts=1`、`calls=6 timeouts=5`、`calls=10 timeouts=9`；
- `[scanout prepare]` 的 `sent` 和 `arms` **始终是 0**，只有 `calls` 在涨；
- `[dpu]` 里 `i1 en=0`、`cnt=0`，`f=` 计数在涨。

滑动时的真实帧率（按连续区间算）：

```
180–210 s   22.1 fps   中位间隔 17 ms
240–270 s   21.8 fps
270–300 s   17.2 fps
300–330 s   16.4 fps   最大间隔 3213 ms
```

面板本身是 120 Hz（内核自己的计数 `FUXI120 rate` = 0x78 = 120），CPU 三频域全部 enable
（2016 / 2707 / 2957 MHz），coherence 探测通过（`d64/64 a7 -> on`）。

**问题**：`[scanout wait]` 在等什么事件？为什么它不回来？是不是缺 DPU 的 frame-done / tear-check
中断（或 mailbox），导致只能靠 500 ms 超时兜底？`sent/arms` 一直是 0 是不是也指向同一个原因？

顺带：`[fence wait]` 超时 21822/29443（74%），`slept=12246 spun=5`，但总等待只有 5.7 秒，
不像 scanout 那么致命。

## 2. 壁纸：PosterBoard 每轮清空壁纸库后重建失败

```
Data store migration initiated
Reaping snapshots for reasons: language change
Error ... NSCocoaErrorDomain Code=260 ... No such file or directory
Reaped snapshot / Reaped gallery / Reaped descriptors / Reaped extension provider info
Data store migration finished (stashed 21H461 -> current 21H461)
Error Domain=com.apple.PosterBoard.generalErrorDomain Code=0
      "Data store could not be created for an unknown reason which evades explanation."
```

一次启动里：`for reasons: language change` 8 次、`Data store migration initiated` 4 次、
`Data store could not be created` 5 次、`com.apple.migration.plist` **0 次**。

同时 SpringBoard 的场景图里壁纸层始终被隐藏：

```
CSWallpaperComponent  hidden: YES; alpha: 0.00   ×153（全部）
CSBackgroundContentComponent  hidden: NO; alpha: 1.00   ← 小部件背景正常
CSComplicationContainerComponent  hidden: NO; alpha: 1.00
```

另外日志里反复出现 `volume does not support data protection, stripping SQLITE_OPEN_FILEPROTECTION_* flags`
（29406 次）——如果 PosterBoard 的数据库必须按 file protection 建，这里就会失败。

**问题**：
1. 这台机器的 Data 卷没有 Data Protection，PosterBoard 的数据存储是不是因此建不起来？
2. `com.apple.migration.plist` 从来没被写（0 次），是不是它导致每轮都判定"语言变了"、于是清库？
3. 有没有办法让 PosterBoard 跳过 file protection（或者让内核的 Data 卷支持它）？

## 3. 已排除的方向

- **不是 CPU 调频**：EPSS 三频域全部 enable=200/200，静态满频（两次探测值完全一致）。
- **不是 coherence**：开着仍然 17–22 fps。
- **不是 Metal 插件**：新插件装上后 `no linear image` 归零，小部件正常显示。
- **不是 HEIC 编码器**：`CMPhotoCompressionSessionAddImage err -12782 (hvc1)` 属于
  ChronoServices 的小组件快照（`PhotosReliveWidget`），和壁纸无关。
- **不是启动参数**：`sheng-gpu-mailbox` / `sheng-gpu-wc` 不是 PE 参数（前者是线程名，
  后者不在 `PE_parse_boot_argn` 列表里），改它们没有任何效果。

## 4. 需要的帮助

1. `[scanout wait]` 的源码位置与它等待的事件（DPU frame done？tear check？mailbox？），
   以及为什么 `sent`/`arms` 恒为 0；
2. Data 卷的 Data Protection 支持是不是可以打开（哪个启动参数或内核选项）；
3. 如果这两个都在你的 t50 树里，能不能给一版带诊断输出的内核（把 scanout 等待的事件计数打印出来）。
