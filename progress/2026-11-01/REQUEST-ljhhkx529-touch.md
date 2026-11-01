# 给 ljhhkx529 的请求草稿：fuxi 触控换成 ST FTS

> 发到：https://github.com/ljhhkx529/unixnu-fuxi （issue，或你们常用的联系方式）
> 方括号里的内容等 OddlyLabs 诊断镜像的结果出来后再填。

---

**标题：fuxi 触控是 ST FTM5，不是 Novatek —— 能否在 old 分支的内核里换成 OddlyLabs 的 FTS 探针？**

你好，我们在用你 `old` 分支做出来的镜像（作者内核 + 新 GPU 插件），小米 13 上已经能跑到 SpringBoard / 锁屏，GPU 合成全部成功，非常感谢！

现在唯一缺的是触控，想请你帮个忙。

## 现象

- 这台 fuxi 的触控芯片是 **ST FingerTip FTM5**（芯片 ID `36 40`），挂在 QUP1 SE4 SPI（`0xa90000`），复位 GPIO24、中断 GPIO25，供电 `ldob12` 1.8 V / `ldom6` 3.2 V。
  这些值来自原厂设备树和 Android 下的测量，见 OddlyLabs 的 `fuxi_touch_panel_porting.md`。
- 当前内核里的触控是 Novatek（`NvtTouchCore`、`sheng-touch*`），对应 sheng 的 NT36532E。
- 在作者内核上加 `sheng-touch=4 sheng-touch-hid=1 sheng-adsp=2`，或者只加 `sheng-backlight=1 sheng-backlight-control=1`，都会在同一个地址 data abort：`pc=0xfffffff00c02389c`。
- README 里 "Touch ✅ Novatek NT36532E" 这一行，我们猜是从 sheng 带过来的。

## 已有的 FTS 驱动

OddlyLabs 已经写好了 fuxi 的 FTS 驱动和探针：

- https://github.com/OddlyLabs/FuxiFtsTouch —— FTM5 协议（`FtsProtocol.c`、`FtsTouchCore.c`）
- https://github.com/OddlyLabs/unixnu-fuxi —— `package/FuxiTouchProbe.cpp`、`FuxiTouchBoard.h`、`QcomRpmh.*`、`SmmuBypass.h`，加上 `QcomGeniSpi` 组件

关键的一点：`FuxiTouchProbe.cpp` 的时钟、引脚、DMA、SMMU 部分沿用的是 sheng 的 `TouchProbe.cpp`（总线相同），**导出的 `native_touch_*` 符号和 sheng 版一致**，所以 sheng 的 HID 层（`HidInputProbe.cpp` / `ShengHidInput`）可以直接读。
它的启动参数是 `fuxi-touch=1..4`（4 = 上电、SPI、读 ID、接中断并发布触点），另有 `fuxi-touch-map`、`fuxi-touch-poll` 等。

**已经在真机上验证通过**：我们按你的 BUILD-PROGRESS 从源码编你的树（format 1，`fuxi_gpu_defconfig`），只把
`TouchProbe.cpp` + Novatek 换成 OddlyLabs 的 `FuxiTouchProbe.cpp` + `FtsProtocol/FtsTouchCore` + `QcomRpmh` + `QcomGeniSpi@eac47ba`，
启动参数 `fuxi-touch=4`：诊断页的触控测试框能跟着手指画出触点（照片附后）。改动在
https://github.com/yigezhong011-ops/unixnu-fuxi/tree/fts-touch （`97e5c01`、`7b490c6`，构建脚本只改了几行，
另加 `FuxiTouchCompat.c` 补 BootLog 读的三个统计变量）。我们这版内核停在 `PE_lockdown_iokit`（没有 trustcache/GPU 插件），
所以进不了桌面 —— 这就是想请你把同样的替换放进你能跑到 SpringBoard 的构建里的原因。

之前我们也试过直接跑 OddlyLabs 的内核：不论用他们自己 CI 编的 uefi-fuxi DEBUG 固件 + v0 镜像，还是用你这边的 Silicium 加载器，
内核都只画出入口探针的蓝条、品红条（MMU 打开前），之后在早期随机卡死（MMU 打开后 6 s 的复位探针能触发，再往后不稳定），
到不了 `bsd_init`，所以还没能读到芯片 ID。他们的 README 也写着 "No device boot evidence yet"。
而你的内核配置在这台机器上能一路跑到 SpringBoard，所以把 FTS 探针放进你的构建是目前最可行的办法。

## 想请你做的

在 `old` 分支编内核时，把 `package/TouchProbe.cpp`（Novatek）换成 OddlyLabs 的 `FuxiTouchProbe.cpp`，加上 `FuxiFtsTouch` 和 `QcomGeniSpi`，其他保持不变，编一版 kernel.macho（或者整份 payload）。我们来上机测试，把结果（照片、boot-log）反馈给你。

如果你更希望我们自己来编，能不能告诉我们 verified-root / owner-root 的 policy bundle 是怎么签的？我们按 BUILD-PROGRESS 从源码编你的树，内核能挂上 APFS 根卷，但最后停在 `bsd_init.c` 的 `rootvp not authenticated after mounting`（`owner_authorized` 没置位）。

## 顺便报告

BUILD-PROGRESS 里提到 `board.toml` 的 userdata `last_lba = 0x76923FA` 是错的（真机是 `0x3afc3fa`），而 `sheng-log=1`、`sheng-data-persist=2` 都会写"userdata 末尾"的窗口。
我们这台机器长时间跑这个镜像之后，slot a 出现了 `fastboot boot` 一律 `Load Error`、正常启动直接回 fastboot 的情况，切到 slot b 就正常了。不确定和这两个窗口有没有关系，供你参考。

谢谢！
