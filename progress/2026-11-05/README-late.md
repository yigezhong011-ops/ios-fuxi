# 2026-11-05 晚：120 帧的真因——GPU fence 等待全是 sleep

## 数据（`t50-mine-gpu-fix.img` 日常版，coherence ON）

```
[coherence] H d64/64 a1 r1024/0 w1024/1024 s0 k6 -> on
            | on=1 skipped map=163 unmap=30 submit=1238000 complete=415838
            | fence pauses slept=9049 spun=6

[fence wait] calls=24879 timeouts=17157 last timed-out fence=6817
             gpu wrote=6816 submitted=6817 completed=6816 no-job=938
[fence wait] outer waits=15833 us=5669289 pauses outside the lock=9046 longest=35722us

[scanout wait] calls=3559 timeouts=122 asked=500ms last=500871us min=500022us max=501043us mean=500802us
```

- **fence 等待 24879 次，17157 次超时（69%）**，最长一次 **35.7 ms**
- 等待时 **`slept=9049`、`spun=6`** —— 驱动基本不 spin，全用 sleep
- `[scanout wait]` 有 122 次整 **500 ms** 超时
- 帧间隔中位 49 ms，与"每次等待要走一次 sleep 调度"吻合

## 结论

120 帧的瓶颈是**内核 GPU 驱动的完成通知/等待路径**：
fence 很少在超时前完成，驱动以 sleep 轮询，每次等待付出一次调度延迟，
累加成每帧 ~50 ms。与 CPU 频率、coherence、Metal 插件都无关。

## 下一步可做的实验（每次只需启动 + 一次 TWRP 取日志）

逐项改 GPU 启动参数，比较 `[fence wait]` 的超时率与 `slept`：

1. 去掉 `sheng-gpu-pause-us=100`（日常版带着它）
2. `sheng-gpu-wc`（写合并，未验证过）
3. `sheng-gpu-coherent`（当前 coherence 已 ON）

判定标准：`timeouts` 占比下降、`slept` 明显变小、帧间隔中位向 8–16 ms 靠。

## 其他已确认

- EPSS：三频域全部 enable，2016 / 2707 / 2957 MHz，静态满频（两轮一致）。
- 壁纸：`CSWallpaperComponent` 153 条全部 `hidden: YES; alpha: 0.00`，小部件组件 `hidden: NO` —— 壁纸层被隐藏，缺 poster。
- `hvc1 / -12782`：ChronoServices 的小组件快照失败（`PhotosReliveWidget`），不是壁纸原因。
