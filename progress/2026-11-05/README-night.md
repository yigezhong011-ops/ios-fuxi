# 2026-11-05 深夜：更正、120 帧、壁纸

## 1. 更正：我昨晚说的 "3.8 倍帧率提升" 是假的

我以为 `sheng-gpu-mailbox=1` 是启动参数，实际查源码（`drivers/Adreno740/NativeAdrenoPublish.cpp:183`）它只是**线程名**：

```c
void nativeAdrenoMailboxPoller(...) {
    thread_set_thread_name(current_thread(), "sheng-gpu-mailbox");
```

驱动真正解析的启动参数只有这几个：

```
sheng-gpu-pool            默认 1536 MiB
sheng-gpu-bringup / -bank / -asid / -sid / -slot / -cmddb-version   仅 bringup 用
sheng-gpu-metal-opens     每进程打开次数上限
```

所以 `sheng-gpu-mailbox=1`、`sheng-gpu-wc=0` **都被忽略**：
- "20 fps → 65 fps" 是**不同镜像（EPSS 探针版 vs 日常版）+ 不同滑动强度**造成的误差，不是参数效果；
- "wc=0 越来越卡" 也是长跑退化，与 wc 无关。

教训：改启动参数前先在驱动源码里确认 `PE_parse_boot_argn("名字")` 是否存在。

## 2. 120 帧：稳定且可复现的信号是 fence / scanout 等待

三次启动（EPSS 探针、日常版、mailbox 版）都出现同样的数字：

```
[fence wait] calls=24879 timeouts=17157   （69%）
             gpu wrote=6816 submitted=6817 completed=6816
[fence wait] outer waits=15833 us=5669289 longest=35722us
[scanout wait] calls=3559 timeouts=122 asked=500ms mean=500802us
[coherence]   slept=9049 spun=6
```

- fence 等待 69–74% 超时，但**总等待时间只有 5.7 s**（约 200 s 内），不是每帧 50 ms 的来源；
- `[scanout wait]` 有 **122 次 × 500 ms 超时**，合计约 61 s，这才是"卡"的大头；
- 帧间隔中位 49 ms，与 scanout 500 ms 超时和 20 fps 一致。

`[scanout wait]` 的代码不在 Adreno740 驱动里，在显示侧（t50 内核的显示驱动），本地没有它的源码。

**下一步**（需要受控 A/B）：同一镜像，分别测"静止"和"滑动 60 s"，用同一套 `fps-per-run.py` 算，才能排除滑动强度的影响。

## 3. 壁纸：PosterBoard 每次启动清空壁纸库，重建失败

日志（`logs/carve-wallnew/lscan.txt`）里的完整序列：

```
Data store migration initiated
current build version 21H461 vs stashed build version 21H461.
Reaping snapshots for reasons: language change
Error ... NSCocoaErrorDomain Code=260 ... No such file or directory     ← 文件被删掉
Reaped snapshot / Reaped gallery / Reaped descriptors / Reaped extension provider info
Data store migration finished (stashed 21H461 -> current 21H461)
Error Domain=com.apple.PosterBoard.generalErrorDomain Code=0
      "Data store could not be created for an unknown reason which evades explanation."
```

计数（这一次启动）：`for reasons: language change` **8 次**、`Data store migration initiated` 4 次、
`Data store could not be created` **5 次**、**`com.apple.migration.plist` 0 次**。

同时：`RelaunchingSpringBoard-reason: Language Change -requester: ... app<com.apple.Preferences`

### 结果

```
CSWallpaperComponent ... hidden: YES; alpha: 0.00     ×153（全部，从未出现 hidden: NO）
CSBackgroundContentComponent ... hidden: NO; alpha: 1.00
CSComplicationContainerComponent ... hidden: NO; alpha: 1.00
```

壁纸层被隐藏 → 黑壁纸；小部件组件正常 → 小部件能显示。

### 与之前结论的关系

- `CMPhotoCompressionSessionAddImage err -12782 (hvc1)`（每次启动约 43 次）属于
  **ChronoServices 的小组件快照**（`PhotosReliveWidget` / widgetkit-extension），**不是壁纸原因**；
- 壁纸更可能是"PosterBoard 数据存储建不起来"导致的，而其中一条触发因子是**语言变更**：
  每次启动都判断语言变了 → 清库 → 重建失败。

### 要继续查的三件事

1. 为什么语言状态没持久化（`com.apple.migration.plist` 从未出现，`AppleLanguages` 600 次引用）；
2. `PRBPosterExtensionDataStore/61/` 目录是否真的存在、权限如何（要读 Data）；
3. `Data store could not be created ... evades explanation` 来自哪条失败路径（不是常见的三条）。
