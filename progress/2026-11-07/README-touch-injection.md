# 2026-11-07 凌晨：USB 触摸注入做通了

## 结论

通过 USB 控制通道触发手势**已经可用**，全自动闭环打通：
`fastboot boot → COM3 → 上滑解锁 → 点图标 → 截图 → 读图 → REBOOT 回 fastboot`。

一次启动的实测（`t50-auto-touch3.img`，5 张截图，每张前先做一次手势）：

| 帧 | 编码大小 | 内容 |
| --- | --- | --- |
| 1 | 17,492 B | 锁屏（1:09，黑壁纸） |
| 2 | 31,920 B | 上滑解锁后，搜索栏出现 |
| 3 | 89,736 B | 桌面（天气/日历小组件 + 17 个图标） |
| 4 | 183,212 B | 点中图标，**地图 App 启动** |
| 5 | 183,212 B | 同上（第二下点在地图内容区，无变化） |

图片：`logs\shot-t50-auto-touch3-231134-{1..5}.png`

## 做法

- cave 放在 `_copyio_test` 开头（和 `shot-cave.c` 同一位置），入口从
  `_native_legacy_gop_mapping_checkpoint`（一个裸 `ret`）改成 `b touch_entry`。
- `touch_entry` 注册截图 provider；每次 SCREENSHOT 命令先做手势，再回传帧。
- 手势第一帧是上滑解锁（`(10160,19000) → (10160,6500)`，12 步 × 10 ms），之后轮流点三个位置。
- 触摸写入的是驱动自己的全局（和 `TouchProbe.cpp` 的 `publish()` 一样）：

```
native_touch_seq    0xfffffff00c1846ec     gTouchSink         0xfffffff00c2324f0
native_touch_count  0xfffffff00c1846f0     gTouchSinkContext  0xfffffff00c2324e8
native_touch_xs     0xfffffff00c1846f4     native_touch_ys    0xfffffff00c184724
native_touch_ids    0xfffffff00c184754
```

顺序：`seq++`（奇数）→ `count`、`xs/ys/ids` → `dmb ish` → `seq++`（偶数）→ 调 sink。
坐标 0..20319（0.1 px），**Y 要镜像**：`20319 - y`。

## 文件

- `dump\wsl\touch-cave.c`：手势 + 截图 cave（`-Oz` 编，940 字节，上限 1024）。
- `dump\wsl\make-t50-touch.sh <输出名> [秒]`：编 cave、打内核补丁、出镜像。
- `dump\wsl\ctl-shot2.ps1 -Name <镜像> -At "100,108,116" -Timeout 260`：
  启动 → 按秒数截图 → 自动 REBOOT 回 fastboot → 解码。
  **注意**：`-At` 必须带引号传字符串（PowerShell 的 `-File` 不接受 `100,108` 这种写法）。
- `dump\wsl\ctl-attach.ps1 -Count 5 -Gap 8`：**不重启**，直接对运行中的系统连拍。
- `dump\wsl\qud-reboot.ps1`：控制通道 REBOOT，实测 5 秒回 fastboot。
- `dump\wsl\decode-shot.py <base>`：`base.bin` + `base.txt`（SCREENSHOT 回复行）→ PNG。
- `dump\wsl\decode-touch3.sh`：把 5 帧的元数据补齐再解码的例子。

## 坑

1. `qud-shot.ps1` 在这台机器上拿不到 HELLO 回复（原因没查清）；自己写的
   `ctl-shot2.ps1` / `ctl-attach.ps1` 正常。**这两个脚本已验证可用。**
2. `decode-shot.py` 需要同名的 `.txt`，里面是 SCREENSHOT 的回复行
   （`width/height/bytes/encoded/crc32/encoding`）。
3. cave 上限 **1024 字节**（`_copyio_test` +0x400 起是窗口表和名单，不能覆盖）。
   超了就用 `-Oz` 并减少函数层级。
4. 截图读的是 GOP 帧缓冲，`sheng-fb-gpu=1` 才有真实画面；`frame=` 是 DPU 帧号。
5. 手势参数：`TAP_HOLD_MS`（默认 40）、`SWIPE_STEPS`（12）、`SWIPE_STEP_MS`（10），
   都在 `touch-cave.c` 顶部；改完要重编镜像。

## 下一步

1. **手势参数化**：现在坐标是编译期常量、靠“第几次截图”轮换。
   要按需指定坐标，可以约定用截图命令的次数编码（或另找一条命令通道），再扩 cave。
2. 用这套跑全自动用例：解锁 → 打开设置 → 检查项 → 截图判断。
3. 把“本轮没触摸”的判断做成脚本（COM3 里没有 `NativeHidInput open` 之类的信号还没有，
   交接文档说要从 Data 日志看，尚未搬过来）。
