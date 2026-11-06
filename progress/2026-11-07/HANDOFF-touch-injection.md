# 交接给 Claude：USB 触摸注入与串口计数（2026-11-07 凌晨）

前一晚的交接是 `交接-DeepSeek-20261106.md`。这一份只写昨晚到刚才的变化，重点两件：
**触摸注入做通了**，**串口打印通道也通了但计数地址有问题**。

## 一句话结论

1. **触摸注入可用**：一次启动里，锁屏 → 上滑解锁 → 桌面 → 点图标开地图，全部由 USB 命令触发，用户没碰手机。
2. **串口回传通道可用**：cave 里调 `printf` 能打印到 COM3（已实测出现 `FUXI120S ...` 行），
   但打印的计数器值不对，**地址/状态槽两个问题还没解决**（见「未解决」）。

## 手机状态

```
fastboot，b 槽，boot_b = t50-daily-usbstart.img（日用镜像 + 新固件，没动过）
本轮所有测试都是 fastboot boot 临时启动，没有刷任何分区
```

## 已实测通过的链路

```
fastboot boot t50-auto-touch3.img
  → 45 s COM3 出现
  → HELLO 握手（session 762a744a4fc9d591）
  → SCREENSHOT ×5：
       帧1 17,492 B  锁屏
       帧2 31,920 B  上滑解锁后
       帧3 89,736 B  桌面（小组件+17 图标）
       帧4 183,212 B 点中图标，地图启动
       帧5 183,212 B 同前
  → REBOOT，5 秒回 fastboot
```

证据图：`logs\shot-t50-auto-touch3-231134-{1..5}.png`，仓库 `progress/2026-11-07/shots/`。

## 触摸注入怎么做的

cave 放在 `_copyio_test` 后面的空白区（`_copyio_test + 0x1000`；该函数到下一个符号有
**19,620 字节**空白，之前的 1024 上限是保守估计）。入口是把
`_native_legacy_gop_mapping_checkpoint`（一个裸 `ret`）改成 `b <cave 入口>`。

`touch_entry` 注册截图 provider；**每次 SCREENSHOT 命令**先做手势，再回传帧：

- 第 1 次手势 = 上滑解锁：`(10160,19000) → (10160,6500)`，12 步 × 10 ms
- 之后轮流点三个位置（相机位 / 手电筒位 / 中心），再按需改成任何坐标

写入的是驱动自己的全局，顺序与 `TouchProbe.cpp` 的 `publish()` 一致：

```
seq++（奇数）→ dmb ish → count、xs/ys/ids → dmb ish → seq++（偶数）→ gTouchSink(gTouchSinkContext)
```

坐标 0..20319（0.1 px），**Y 要镜像**：`20319 - y`。

符号地址（来自 `llvm-nm --defined-only`）：

```
native_touch_seq    0xfffffff00c1846ec     gTouchSink         0xfffffff00c2324f0
native_touch_count  0xfffffff00c1846f0     gTouchSinkContext  0xfffffff00c2324e8
native_touch_xs     0xfffffff00c1846f4     native_touch_hid_reports 0xfffffff00c1846e4
native_touch_ys     0xfffffff00c184724     native_adreno_fence_wait 0xfffffff00c18044c
native_touch_ids    0xfffffff00c184754     native_adreno_submit_ibs 0xfffffff00c180420
_kprintf            0xfffffff00bfcdd10     _printf  0xfffffff00b8cc820  ← 控制台要用这个
```

## 未解决（两条，都有明确下一步）

### 1. 打印出的计数器是垃圾值

实测这一行：

```
FUXI120S p=64 hid=1362114104 calls=1362114032 to=199172488 sub=1362114128 done=201807120 ibs=15717
```

只有 `ibs=15717` 看着合理。`hid`/`calls`/`to` 明显不对（像代码字节）。

- 可能 1：这些符号虽然地址在 `0xc18xxxxx` 区，但驱动在本内核里**没有维护**它们（留的是别的内容）。
- 可能 2：符号表给的是 **kext 里的地址**，实际重定位后不同（触摸那几个是好的，所以存疑）。
- 下一步：先用一个**肯定被驱动更新**的量验证——例如打印 `native_touch_seq`（我们自己写，
  每次 publish +2）；若它也乱，就是地址问题；若正常，就是那几个统计量没维护。
  再不然改成读驱动自己的 stats 结构（`NativeAdrenoSubmit` 的 `stats_`，需要反查地址）。

### 2. 手势相位存在 `native_touch_xs[1]`，会被驱动覆盖

相位槽用 `xs[1]`（一根手指时不会填）当计数器，但**驱动 publish 时会写满自己的槽**，
所以 `p=64` 是残留坐标而不是次数。下一步：换成一个驱动绝不碰的全局（例如
`native_touch_extent[3]` 之类，需确认没被维护），或者把相位做成「根据已发命令数」由主机侧编码。

## 帧率怎么读（现状）

- **面板帧率**：SCREENSHOT 回复里自带 `frame=<DPU 帧号>`，两次截图做差 / 时间差即可，
  实测 120 Hz 时 `frame` 增长与时间一致。
- **应用帧率（swap 间隔）**：仍然只能进 TWRP 从 Data 的 sheng log 读（`read-cadence.py`）。
  昨晚的结论没变：卡顿来自 `[scanout wait]` 500 ms 超时（322 秒里约 275 秒在等），
  不是 CPU、不是 coherence、不是插件。

## 脚本（都在 `dump\wsl`）

| 用途 | 命令 |
| --- | --- |
| 编触摸 cave + 出镜像 | `make-t50-touch.sh <输出名> [秒]` |
| 打包成自动回 fastboot 的镜像 | `make-t50-auto.sh <工作目录> <秒> <输出名>`（**要单独跑**，`make-t50-touch.sh` 末尾那步在这台机器上不生效） |
| 启动 → 定时截图 → 自动 REBOOT → 解码 | `ctl-shot2.ps1 -Name <镜像> -At "100,108,116" -Timeout 260` |
| 不重启，对运行中的系统连拍 | `ctl-attach.ps1 -Count 5 -Gap 8` |
| 只叫回 fastboot | `qud-reboot.ps1`（实测 5 秒） |
| 解码一帧 | `decode-shot.py <base>`，需要同目录 `<base>.bin` + `<base>.txt`（SCREENSHOT 回复行） |

**坑**：

1. `qud-shot.ps1` 在这台机器上**拿不到 HELLO 回复**（原因没查清）；用 `ctl-shot2.ps1` / `ctl-attach.ps1`。
2. PowerShell `-File` 传 `-At 100,108` 会当成一个字符串，必须加引号：`-At "100,108"`。
3. `decode-shot.py` 必须有同名的 `.txt`（含 `width/height/bytes/encoded/crc32/encoding`）；
   `ctl-shot2.ps1` 目前**不写** `.txt`，要补（`ctl-attach.ps1` 已写）。
4. cave 里只能有 `.text` + `.rodata`（用 `llvm-objcopy -j .text -j .rodata`），
   **普通字符串常量会进 `.rodata`**，漏掉就打印出乱码。
5. 串口打印用 `printf`（0xfffffff00b8cc820），`kprintf` 不出现在 COM3 上。
6. 编 cave 用 `-Oz`；`SWIPE_STEPS`/`SWIPE_STEP_MS`/`TAP_HOLD_MS` 在 `touch-cave.c` 顶部。

## 现有镜像

```
t50-auto-touch3.img   触摸可用版（上滑解锁 + 三点轮换），已验证 5 帧
t50-auto-touch4.img   加了串口打印（kprintf，不输出）
t50-auto-touch5.img   打印改用 printf，能在 COM3 看到 FUXI120S（计数是垃圾）
```

## 按优先级建议的下一步

1. 验证 `native_touch_seq` 是否被正确读取（判断是地址问题还是统计量没维护）；
2. 修相位槽（换全局或主机侧编码），让「点哪个坐标」可以由命令参数决定；
3. 给 `ctl-shot2.ps1` 补写 `.txt`；
4. 用这套跑自动化用例：解锁 → 设置 → 逐项检查 → 截图判断；
5. 帧率/卡顿继续等作者对 `[scanout wait]` 的回复（请求文件：
   `REQUEST-ljhhkx529-120fps-wallpaper-2026-11-05.md`）。
