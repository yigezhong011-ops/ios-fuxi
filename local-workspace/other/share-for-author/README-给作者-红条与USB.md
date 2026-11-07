# 给 t36 作者：顶部红条 / 控制中心，以及 USB 调试口

以下内容基于 t36（`boot-phone-cache-miss-t36.img`）在小米 13 真机上的测试和日志。在 t36 上叠加 DSI 亮度和 PMIC 按键之后，日常版为 `t36-bl2`，iPhone 14 Pro 布局和灵动岛都正常。下面两个问题需要改源码，用二进制补丁做不了。

## 1. 顶部红条 "😳 rdar:45025538"，以及控制中心缩在屏幕中间

**原因**：这是 UIKit 的兜底状态栏（`_UIStatusBarFallbackItem`，`_create_label` 里写死了这段文字）。当屏幕的点尺寸对不上任何一款真 iPhone 时，UIKit 找不到状态栏的 visual provider，就会显示它。

- fuxi 的面板是 1080×2400，在 3 倍缩放下是 **360×800 pt**，没有哪款 iPhone 是这个尺寸。iPhone 14 Pro 是 393×852 pt，即 1179×2556 px。
- 控制中心缩在中间、四周一圈灰边，很可能是同一个原因：屏幕尺寸未知，只能套用兜底布局。

**别人的修法**：ios-sweet（Redmi Note 10 Pro，面板同样是 1080×2400）的 NOTES.md 第 0061 条写道："AppleCLCD now presents 1125x2436 (iPhone X) and shows the centered 1080x2400; touch mapped the same"。UniXNU 的 sirius 也在 `NativeLegacyDisplay::validateSwap` 里加了"接受更大的画布尺寸并缩放到面板"。

**建议改法**（GopFramebuffer/NativeLegacyDisplay，以及 GPU 出图）：
1. 在 `startHardware` 里，boot mode 报告 **1179×2556**（iPhone 14 Pro）。目前代码直接写的是 GOP 帧缓冲的 1080×2400，对应 `+0x16b0` 和 `+0x16b4` 这两个字段。
2. `validateSwap` 接受 1179×2556 的 surface，不再按 reason 3 拒绝。
3. 出图时缩放到 1080×2400：CPU 拷贝路径可以照 sirius 的最近邻 blit 来写；GPU/DPU 出图路径则用 SSPP 的 scaler，或者先做居中裁剪。
4. 触摸坐标按同样的比例或偏移换算。
5. 帧缓冲显存和控制台不能再按 boot mode 的尺寸去写面板，否则会越界。

**我们试过**：用二进制补丁只把 `+0x16b0`/`+0x16b4` 改成 1179/2556，结果开机就卡在三色条（`t36-canvas`）。这说明后面的出图和显存都要配合修改。

## 2. USB 调试口：电脑上枚举不出 COM 口

**已证实的根因**：`qcom_usb_debug_init`、`_poll`、`_get_status` 一进来都会检查 `cpu_number() == master_cpu`，不在启动 CPU 上就直接返回，反汇编可以确认这一点。

- 驱动文档 `docs/boundaries.md` 和 `integration.md` 的要求是："Call once on the boot CPU, after arm_vm_init and ExitBootServices, at or before PE_init_kprintf"。
- 而 `patches/xnu/zzzd-fuxi-usb-debug.patch` 是在 `bsd_init` 里、`load_init_program` 之前调用 `fuxi_usb_debug_start()` 的。这时已经多核在跑，线程不一定在启动 CPU 上。
- 实测日志里 `fuxi_usbdbg_phase = -1`，也就是 init 失败，内核没有拉高 D+，主机连"未知设备"都看不到。

**建议改法**：
1. 按 `patches/darwin22/0001`（console）和 `0002`（worker）的接入点，把 `qcom_usb_debug_init()` 移到启动 CPU 上的早期位置；worker 也要在启动 CPU 上轮询，例如绑定到 `master_processor`。
2. 固件这一侧：驱动只接管固件已经准备好的状态，即 **DEVICE role**、PHY/eUSB2 repeater、Type-C 的 DEVICE 路由。uefi-fuxi 目前加载了 `UsbKbDxe`/`UsbMassStorageDxe`，很可能处在 HOST 模式，或者在 ExitBootServices 时把控制器停掉了。可以参考 mouse233 的 fuxi 移植：他们的 UEFI USB 接收器用 `--try-usb-route --keep-phy` 保留了 Type-C 路由和 PHY，相关描述见 unixnu.com/zh/devices/fuxi-mouse233。
3. 我们这边在二进制补丁里试过让线程只在落到启动 CPU 时才调 init，还没能证实有效；而且补丁代码区（`__hib_text` 之后）超过 0xa23 字节就无法开机，空间不够用。

## 3. 附带：亮度和按键

请看另一份 `fuxi-brightness-fix.zip`。它包含 DSI DCS 0x51 亮度和 PMIC 轮询按键，t36 自带的 `fuxi-buttons=1` 在这台机器上没有按键事件。合进源码之后，就不需要我们的二进制补丁了。
