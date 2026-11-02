# 2026-11-02：实体按键、亮度已通

> 更新（下午）：亮度已在真机上验证。`t32-bl1` 诊断行 `BL ga s4 q167 t25e l25e k167 f0 e0 c175 i500`：iOS 发来 0x167 次亮度请求，全部通过 DSI 写给屏幕，0 次失败。boot_b 现为 `t32-bl-daily`（按键 + 亮度）。见文末"下午的进展"。

设备：小米 13（fuxi，SM8550），系统用第三方 t32 内核（ljhhkx529）。脚本在 `scripts/wsl/`。不含任何镜像、内核、密钥和设备序列号。

## 结果

| 项目 | 状态 |
| --- | --- |
| 电源键单按 | 能息屏（桌面上） |
| 电源键 + 音量加 | 截图 |
| 电源键 + 音量减长按 | 出现"滑动来关机"（之后 iOS 会要求输一次密码，点"取消"即可） |
| 音量键单按 | iOS 已收到，但没有音频，所以音量不变、不弹音量条 |
| 控制中心亮度条 / 音量条 | 拉不动：没有亮度服务、没有音频 |

boot_b 已刷入 `t32-buttons-daily2`：t32-pause 的参数（`sheng-fb-gpu=1 sheng-gpu-pause-us=100`），加上下面的按键注入。

## 按键是怎么做的

t32 的 `native_buttons_set_sink` 是空函数（`ret`）。`NativeHidInput::start` 把按键回调交给它，但没有任何东西接收。`patch-t32-buttons.py` 做了三件事：

1. 把 `fuxi-buttons-blob.c` 编成无可写数据的独立代码，放进 `__TEXT_EXEC` 末尾的零字节空洞；
2. 把 `ret` 改成跳到这段代码；
3. 这段代码起一个内核线程，每 20 ms 通过 SPMI 仲裁器（v7，EE 0）读一次 PMIC：
   - 电源键：PMK8550 PON（ppid 0x013）RT_STS bit7；
   - 音量减：PON RESIN，bit6；
   - 音量加：PM8550 GPIO6（ppid 0x18d），bit0，低电平有效。

   按键状态一变，就作为 NativeHidInput 的 report 2（Consumer：bit1 电源、bit2 音量加、bit3 音量减）送出去。

**关键坑：线程必须开机后先等 60 秒再碰 SPMI。** 一开机就开始轮询的版本（`t32-buttons-daily`）卡在苹果标；所有能进桌面的版本都等了 60 秒。

## 诊断方法（`make-t32-buttons-diag.sh`）

把状态写进诊断页的 CPU 行（开机参数 `sheng-cpufreq=0`）。设备上的实测读数：

```
BTN s50 a300 p230 g247 r10 u1 m0 n29 e1 x0 o1 d8d k2d q0 c1
```

- `n`：读到的按键变化次数；
- `k`：`buttonsAction` 调用 `handleReport` 的次数，这里等于 n 加上 4 次自检；
- `q0`：`handleReport` 全部返回成功；
- `e1`：已找到 IOHIDEventDriver；
- `c1`：回调上下文就是 HID 设备对象。

所以整条链路都通了。没有音量反应是因为没有音频，不是按键的问题。

## 给 t32 作者（ljhhkx529）

你在 `old` 分支新加的 `FuxiButtons.cpp`，走的正是这条路：PMIC 读键，然后交给 `native_buttons_set_sink`，再变成 report 2。我们已在真机上验证 iOS 一侧可以接收（截图、关机滑块都能触发）。

有一点要注意：`sheng-backlight=1` 在 fuxi 上会崩溃重启。sheng 的 KTZ8866 I2C 背光不适用于 fuxi 的 OLED：`i2c@a84000` 在原厂设备树里是 disabled，`i2c@988000` 上只有 `fsa4480@42` 和 `rtc6226@64`。

## 亮度（进行中，尚未上机）

思路是复用 t32 里的 ShengBacklight 服务。它已经处理好了 AppleARMBacklight 伪装、backboardd 的 sandbox 授权，以及 IODisplayParameters 0..2047。我们只把它的硬件传输改成 DSI：

- `sheng_backlight_start` 换成 `bl_start`：只映射 DSI0（`0xae94000`），不碰 GCC 和 I2C；
- `ShengBacklight::kick` 换成 `bl_kick`：通过 DSI0 的 TPG 命令 DMA FIFO 发 DCS `51 <hi> <lo>`，做法照搬 houji（小米 14）的 `HoujiBacklightProtocol.h`；
- `attachFired` 直接 `ret`；两次 `geni_i2c_prepare` 视为失败，让服务直接发布。

fuxi 屏幕"m3 38 0c 0a sec cmd mode dsc"：`51 07 ff` 是正常亮度上限，`51 0f ff` 是 HBM。所以 0..2047 可以一一对应。

## 注意：A/B 槽重试次数

iOS 从不把启动槽标记为成功，每次开机都会消耗一次重试次数。减到 0 后，正常开机会进 fastboot，`fastboot boot` 报 "Load Error"。用 `fastboot set_active b` 可以恢复（重试次数回到 7）。之前以为"a 槽坏了"，实际就是这个原因。

## 下午的进展

### 亮度（已通）
- `make-t32-bl.sh`：日常版，按键加亮度；`make-t32-bl-diag.sh`：带 BL 诊断行的版本。
- 亮度命令只在 iOS 发布亮度服务之后才发。如果在开机初期就发 DCS 命令，系统会崩。

### 打包陷阱：Data 种子藏在 FAT 的"空闲"簇里
- 载荷配置是 `packed_data_ramdisk`：Data 卷的初始数据就放在载荷 FAT 卷的空闲簇里，由引导程序填写 `/chosen/memory-map/PackedRAMDisk`。
- 后果一：如果把空闲空间清零，镜像会小 6.5 MiB，但种子被擦掉，开机就卡在米标或者过了色条后黑屏。对照实验：`t32-bl-daily-z` 和能开机的 `t32-bl-daily` 只差清零这一步，结果开不了机。
- 后果二：替换载荷里的文件时，大小必须和原来完全相同，原地覆盖。`addon-set-clients.py --same-size` 就是这样替换 GPU 附加包的。

### 黑壁纸、白色小部件（在查）
- **壁纸：** iPadOS 17 默认壁纸是 HEIC 格式，没有硬件解码器就画不出来。t32 内核支持 `/private/var/ngpu/wallpaper` 覆盖，但 t32 的 GPU 附加包里没有这份 PNG。参考 UniXNU 的 `make-wallpaper-overlay.py`。
- **小部件和设置：** t32 的 `NativeAdrenoMetal.clients` 只列了 `mediaserverd` 和 `SpringBoard`。内核的 `kClientWindows` 只有渲染服务加两个客户端窗口。参考其他机型的名单：
  - uke：`iconservicesagent, PosterBoard, WidgetRenderer_Default, CollectionsPoster, AegirPoster, KaleidoscopePoster`
  - pong：`SpringBoard, CollectionsPoster, WidgetRenderer_Default`

### iPhone 布局、灵动岛（在查）
- pong 先在 ADT 里换成 iPhone 身份（机型 `iPhone17,1`，`artwork-device-subtype 2622`，`/buttons` 写明没有 Home 键，主板保留 OS 原来的 J171），再清掉 MobileGestalt 缓存，界面就变成了手机布局。
- 灵动岛另需一个用户态 hook：`MGGetBoolAnswer` 对 `YlEtTtHlNesRBMal1CqRaA` 返回真，并修补状态栏的 provider（`userland/ui_compat18.c`）。
- 我们这边：`make-t32-iphone.sh`（iPhone 15 Pro，`iPhone16,1`，2556，保留 J120）。前一轮测试被上面的清零问题干扰，作废，重新测试中。

## 参考

- ljhhkx529/unixnu-fuxi `old`：`FuxiButtons.cpp`、`HidInputProbe.cpp`、`AppleARMBacklight.cpp`
- UniXNU 设备记录 oneplus13t：键盘集合放在描述符最前之后，电源键可以息屏
- lonzzi/UniXNU-houji：`HoujiBacklight.inc`、`HoujiBacklightProtocol.h`
- Chengdong-Yu/UniXNU-pong：`services70`，音量键可以到达 SpringBoard，但没有音频时无效
