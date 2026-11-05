# 2026-11-05 傍晚：EPSS 探测结果 + 壁纸/120 帧定性

## 1. EPSS 探测（`t50-auto-epss.img`，两次串口采集）

探针源码 `dump/wsl/fuxi-buttons-blob.c` 的格式是
`FUXI120 e<域> <200 次采样里 enable=1 的次数> <level | perf_state<<8>`，频率 = level × 19.2 MHz。

实测（两轮一致）：

| 频域 | enable | level | 频率 | perf_state |
| --- | --- | --- | --- | --- |
| e0（cpu0-2） | 200/200 | 105 | 2016 MHz | 15 |
| e1（cpu3-6） | 200/200 | 141 | 2707 MHz | 19 |
| e2（cpu7 X3） | 200/200 | 154 | 2957 MHz | 20 |

**和此前"e1/e2 的 enable 始终是 0"相反**：三个频域全部 enable，而且都在最高档。
两轮相隔一段时间的取值完全相同，说明 CPU 频率是**静态满频**，没有在做负载调频。

推论：再做"直接写 perf_state 投票"的镜像没有意义——CPU 侧已经满频。

## 2. 120 帧：不是 CPU，也不是 coherence

同一次启动（`t50-mine-gpu-fix.img` 日常版）的帧节奏，来自日志窗口解码后的 slots：

```
swaps 2893，时间跨度 185 s
gap 中位 49.0 ms（≈20 帧/秒）
40–60 ms 占 81.3%，5–10 ms 占 8.3%
done 中位 1.0 ms，offer 中位 0
```

同一次启动的 coherence 是 **ON**：

```
[coherence] H d64/64 a3 r1024/0 w1024/1024 s0 k6 -> o    ×6
```

面板侧 `FUXI120 rate 78` = 120（面板确实在 120 Hz 刷）。

结论：coherence 开着、CPU 满频，出帧仍然是 49 ms；8.3% 的帧能到 5–10 ms，说明能力有、但被阻塞。
瓶颈在 GPU/合成路径，和壁纸、小部件是同一类问题（Metal 路径不完整）。

## 3. 壁纸：CoverSheet 的 Wallpaper 组件恒被隐藏

同一次启动的统一日志（`logs/carve-wallnew/lscan.txt`）：

```
CSWallpaperComponent ... identifier: (active);  priority: 100;  hidden: YES; alpha: 0.00   ×86
CSWallpaperComponent ... identifier: (default); priority: -100; hidden: YES; alpha: 0.00   ×67
CSBackgroundContentComponent ...  hidden: NO; alpha: 1.00
CSComplicationContainerComponent ... hidden: NO; alpha: 1.00
CSComplicationSidebarComponent ... hidden: NO; alpha: 1.00
```

**153 条 Wallpaper 组件全部 hidden + alpha 0，从未出现 hidden: NO**；其它组件正常可见。

这解释了黑壁纸：不是画不出来，是壁纸层被隐藏且透明——系统的 poster 数据存储里没有可显示的 poster。
这一轮 PosterBoard 并没有报数据存储错误（三条失败路径的次数都是 0），但组件仍然隐藏。

## 4. `hvc1 / -12782` 是小组件快照，不是壁纸

之前把 `CMPhotoCompressionSessionAddImage err -12782 (codec 'hvc1')` 当成壁纸线索，**这个判断错了**。
日志上下文显示它属于 widget 扩展：

```
NSExtensionIdentifier = "com.apple.mobileslideshow.PhotosReliveWidget"
NSExtensionPointName = ( "com.apple.widgetkit-extension" )
_DKEvent.Dasd.WidgetRefresh
```

计数：`chronod` 145535 行、`ChronoServices...unableToFinalizeImageDestination` 910 次、
`PosterBoard` 24206 行。每次启动约 43 次失败（868 → 911），全部在 ChronoServices 侧。

含义：小组件的**快照缓存**写不出来（HEVC 编码器缺失，`-12782` = UnsupportedOperation），
但小组件靠插件实时渲染已经能显示，所以这只影响缓存/性能。

## 5. 下一步

- 壁纸：查 `PRBPosterExtensionDataStore/61/` 里到底有没有数据库、有没有 poster 记录（要读 Data，先备份并问用户）。
- 120 帧：从 GPU 侧查，不在 CPU/coherence 上继续投入。
- 小组件快照：如果要消掉报错，需要 HEVC 编码器（`VideoToolbox` 里有 `HEVCEncoder`/`HEVCRegisterEncoder` 符号，但 CMPhoto 走的是 UnsupportedOperation 路径）。
