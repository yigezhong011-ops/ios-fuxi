# 交接给 DeepSeek：fuxi USB 调试串口（2026-11-03 晚）

把"提示词"那一段整个发给接手的模型，后面的内容作为背景资料。

## 提示词

你接着做小米 13（fuxi，SM8550）的 UniXNU 移植，目标是让 USB 调试串口工作。具体来说，内核里的 `QcomXnuUsbDebug`/`FuxiUsbCompat` 要在电脑上枚举出一个 CDC ACM 串口（Windows 上叫 COMx）。

环境：
- 工作目录 `E:\DSH-Fuxi`；
- WSL 用 `wsl -u root`，工作目录 `/root/fuxi`；
- fastboot 和 adb 在 `E:\DSH-Fuxi\tools\platform-tools\`。

先读本文件，再读 `E:\DSH-Fuxi\PATCH-fuxi-usb-power\README.md`（你上次写的根因分析）。

硬性规则：
- **只能用 `fastboot boot` 临时启动。刷 boot_b 之前必须先问用户。**
- **不要启动任何 iPad 身份的镜像，也就是 t32 系列，包括 `t32-usb.img`。** 现在的 Data 是按 iPhone 14 Pro 身份建的，用 iPad 镜像开机会把 MobileGestalt 缓存改回 iPad，还会黑屏。测试镜像一律以 t36 为基础，做法见第 3 节。
- 不刷 userdata，不清 Data，不做永久删除，不往 C 盘写数据。
- 不把镜像、内核、`token2.txt`、`keys\`、芯片 ID、fastboot 序列号放进公开仓库，也不 force push。
- 用中文和用户交流。每次只让用户做一件事，并说清楚要观察什么。

## 00. 2026-11-03 深夜：已证实的根因和做到哪一步（先读这一节）

- 内核里的 USB 初始化没有成功。证据：`fuxi_usbdbg_phase = -1`，由 `t36-usbdiag` 打印到日志的 `[clocks]` 行，读法是 `dump/wsl/usbdiag-rows.sh`。
- 失败的原因已经证实：`qcom_usb_debug_init`、`_poll`、`_get_status` 一开头都会检查 `cpu_number() == master_cpu`，不是启动 CPU 就直接返回，这一点反汇编可以看到。作者的 `zzzd-fuxi-usb-debug.patch` 把 `fuxi_usb_debug_start()` 放在 `bsd_init` 里调用，那时已经多核运行，线程不一定在启动 CPU 上。驱动文档的要求是："Call once on the boot CPU … at or before PE_init_kprintf"。
  **正确的修法是改作者的源码**：把 init 放到启动 CPU 上的早期位置（参照 `patches/darwin22/0001`、`0002` 的接入点），worker 也要在启动 CPU 上轮询。这件事请作者来做最稳。
- 我在二进制补丁里试过的办法：
  - `thread_bind(cpu_to_processor(master_cpu))` 加 `thread_block`：开机卡在绿条，后来确认真正原因是 blob 太大，见下一条；
  - 每次醒来只在恰好落到启动 CPU 时才执行：`t36-usbcpu0e` 跑了 100 秒，一行诊断都没写出来，可能是从没轮到启动 CPU，也可能是 init 卡住了；
  - `t36-usbcpu0f` 加了不分 CPU 的计数行，镜像已经编好，**还没读到结果**。
- **blob 大小有上限**：t36 内核 `__hib_text` 后面的空白区不是全都能用。0x68c 和 0xa23 字节能开机，0xaeb 字节在内核控制台出来之前就崩了（"Recursive exception occurred while dumping the CPU state"）。`__KLD` 段开机后会被回收，不能放代码。补丁要控制在 0xa23 以内。

## 0. 新发现：根因多半不是"没上电"（2026-11-03 晚补充）

读了 `QcomXnuUsbDebug/docs/boundaries.md`、`architecture.md`、`porting-other-socs.md`，再对照 fuxi 的 `Include/DXE.inc`，得出下面几点。

1. **fuxi 固件本来就加载了高通完整的 USB 驱动链。**
   - 第 78~88 行：`FUXI_UFS_STACK == 1` 时会加载 `UsbPwrCtrlDxe` 和 `UsbfnDwc3Dxe`。
   - 第 110~116 行：无条件加载 `UsbBusDxe`、`UsbKbDxe`、`UsbMassStorageDxe`、`UsbDeviceDxe`、`UsbConfigDxe`、`UsbInitDxe`、`UCDxe`。
   - 所以"固件从不给 USB 上电"这个结论不成立。`UsbPwrEnablerDxe`（SM6115 的驱动）大概率是多余的。
2. **QcomXnuUsbDebug 的前提条件。** 它只接管固件已经准备好的状态：供电、五个 USB 时钟、复位、**DEVICE role**、PHY/eUSB2 repeater、Type-C 的 DEVICE 路由；父时钟、稳压器、PHY 的冷启动它都不做。文档原话："现有实现依赖……固件准备好的 DEVICE 模式 USB"。
   fuxi 固件加载了 `UsbKbDxe` 和 `UsbMassStorageDxe`，说明 UEFI 阶段很可能把控制器设成了 **HOST** 模式；另外，高通的 `UsbConfigDxe` 在 ExitBootServices 时可能会把控制器停掉或复位。两种情况都会让 `qcom_usb_debug_init()` 的资格检查失败，而失败后内核不会拉高 D+，所以主机上连"未知设备"都看不到，和实测结果一致。
3. **版本问题。** `QcomXnuUsbDebug` 自带的补丁只针对 Darwin22（iOS 16，XNU 8796）。fuxi 用的是 Darwin23（iPadOS 17，xnu-10063），由作者自己的 `patches/xnu/zzzd-fuxi-usb-debug.patch` 和 `package/FuxiUsbCompat.c` 接入。t36 内核里已经有 `FuxiUsbCompat`、`QcomXnuUsbDebug`、`acquire_vbus` 这些符号。
4. **初始化结果其实有记录，但我们没读到。** `FuxiUsbCompat.c` 把阶段写在 `fuxi_usbdbg_phase` 里：1 表示进入，-1 表示 init 失败，2 表示成功，3 表示 worker 已启动，-2 表示开机参数没开；同时会 kprintf `FUXI USB: qcom_usb_debug_init failed`。可惜 msgbuf 只保留最后 128 KB，这几行早就被覆盖了。

**建议的下一步：**
- 先取到 `fuxi_usbdbg_phase` 和 qualify 失败的原因。办法有两个：
  - 在我们的 blob（`fuxi-buttons-blob.c`）里定期把 `fuxi_usbdbg_phase` 和 `fuxi_usbdbg_result` 拷进 sheng 日志会导出的统计区；
  - 或者想办法让早期 kprintf 留在日志里。
- 固件方面：查 `UsbConfigDxe`/`UCDxe` 选择 role 的方式（PCD、Type-C、配置表），让它在 UEFI 结束时把控制器留在 DEVICE 模式且不复位；并在 ExitBootServices 之后核对 `DSTS.DEVCTRLHLT` 的要求。参考 `architecture.md` 的"控制器交接"一节和 Mu-Silicium/Aloha 平台上 `UsbfnDwc3Dxe` 的用法。

## 1. 已经测过的结果

| 镜像 | 内容 | 结果 |
| --- | --- | --- |
| `t36-bl2-usb.img` | 日常版 t36-bl2 的内容 + 你的 `t32-usb.img` 里的新 UEFI 引导程序 + `qcom-usb-debug=1`（缺 `serial=3`） | 能进桌面。电脑上没有手机的 USB 设备，也没有 COM 口。中途拔过线，这次结果不算数 |
| `t36-bl2-usb2.img` | 同上，另外加回了 `serial=3` 和 `debug=0x14e`，与 t32 原来的参数一致 | 能进桌面。线一直插着，等了约 4 分钟，**仍然没有任何手机 USB 设备**，Windows 设备管理器里也没有未知设备 |

所以：固件补丁加上内核开关都打开了，主机这边还是什么都看不到，连枚举失败的未知设备都没有，说明 D+ 根本没有被拉高。

## 2. 补丁本身需要改的地方（`0001-fuxi-usb-power.patch`）

1. `fuxi.dsc` 里的中文注释是乱码（UTF-8 被当成 GBK 重新编码过了），有一行还把两行粘在了一起。请改成英文注释。
2. DSC 的 `[Components]` 无条件加了 `UsbPwrEnablerDxe.inf`，FDF 里却用 `FUXI_USB_POWER` 包着。两边要用同一个开关。
3. `UsbPwrEnablerDxe` 来自 `NicobarPkg`（SM6115）。它在 SM8550 上具体做了什么，要读源码确认：它通过哪个 protocol 或 PMIC 接口给哪个控制器上电？fuxi 的 USB 控制器、PHY、VBUS 和 Type-C 是否都在它的覆盖范围内？它有没有真正运行？可以用 UEFI 菜单里 Tools 下的 Advanced Logger 加二维码抓固件日志，方法见 unixnu.com/zh/porting/log-capture。

## 3. 怎样做测试镜像（必须以 t36 为基础）

- 当前的日常版是 boot_b 里的 `E:\DSH-Fuxi\t36-bl2.img`，它的卷在 `/root/fuxi/t36-bl2/vol.img`。
- `dump/wsl/make-t36-usb.sh [输出名]`：用 `t32-usb.img` 里的引导程序，配上 t36-bl2 的卷，参数加上 `qcom-usb-debug=1` 和 `serial=3`，然后用 `repack-with-vol.py` 打包。脚本里写死了 `t32-usb.img`，换成新的引导程序时改那一行即可。
- 引导程序是 boot 镜像 kernel 段里 FAT 卷之前的那部分，用 `compare-loaders.py` 可以对比。t32 和 t36 原来的引导程序完全相同，DeepSeek 的 USB 版只换了这一段，大小也一样（3145920 字节）。
- 卷里的文件只能用 `fat-inplace.py` 原地改写，而且必须保持原大小，因为 Data 种子放在 FAT 的空闲簇里。`unixnu.toml` 里还有空余：菜单标题已经改短成 "fuxi"。

## 4. 怎样读日志

日志区在 userdata 末尾 32 MiB，内核开了 `sheng-log=1` 就会写。读法：

1. 在 fastboot 里依次运行 `fastboot set_active a` 和 `fastboot reboot recovery`。a 槽里是 TWRP。
2. 运行 `adb shell "dd if=/dev/block/by-name/userdata of=/tmp/l.bin bs=4096 skip=58731451 count=8192"`，再用 `adb pull` 取回电脑。
3. 解码：`read-sheng-log.py --decode`（在 `unixnu-build/fuxi/scripts/`），也可以用 `dump/wsl/log-usb.sh`。
4. 读完一定要运行 `fastboot set_active b`。
5. 测试开机后，要直接长按进 fastboot 再去读，中间不能先回 iOS，否则日志会被覆盖。
6. 注意：msgbuf 只保留最后 128 KB，这次 USB 测试只剩下 80 秒以后的内容，USB 驱动在开机早期打出的那几行已经被冲掉了。要看早期输出，可以把开机参数 `boot-ui-focus4` 去掉，减少日志量；也可以在快照行里找 USB 相关的统计。

## 5. 当前手机状态

- boot_b：`t36-bl2.img`，iPhone 14 Pro 布局，带灵动岛，按键和亮度可用。
- a 槽：安卓的 boot 加上 skkk TWRP，用来读日志。
- userdata：iPadOS 17.7.11 的 UniXNU 根卷，加上一份按 iPhone 身份建好的 Data。
- 新 Data 开机必须带 `sheng-setup=0`，否则每一帧都会被 `verify_swap` 拒绝，屏幕黑屏。t36-bl2 已经带上了这个参数。
