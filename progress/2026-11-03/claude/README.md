# 2026-11-03 进度：iPhone 14 Pro 布局、USB 调试口、日志

## 当前日常版：`t50-mine`（刷在 boot_b）

| 功能 | 状态 |
| --- | --- |
| iPhone 14 Pro 布局 + 灵动岛 | ✅ |
| 电源键、音量键 | ✅（我们的 PMIC 轮询补丁） |
| 亮度 | ✅（作者 t50 内核里的 DSI 亮度，`fuxi-backlight=dsi`） |
| USB 调试串口 | ✅（开机约 40 s 后出现 COM3，实时输出内核日志） |
| 顶部红条 "rdar:45025538" | ❌ 需要改显示驱动 |
| 小组件、文字空白（GPU） | ❌ 需要新的 NativeAdrenoMetal 插件 |

`t50-mine` = 作者的 t50 内核和卷，加上 `fuxi-buttons-blob.c` 的按键部分（`patch-t32-buttons.py`，REPLACE_SINK），再加上 unit-scale 3 和 `sheng-setup=0`。构建脚本是 `scripts/wsl/make-t50-mine.sh`。

## 今天的关键发现

1. **iPhone 布局**：userdata 用 iPadOS 17.7.11 恢复包重新编（`build-userdata.sh`），从 TWRP 分块写入并逐块校验（`push-userdata-chunks.sh`）。之后清空 Data 头，**第一次开机就用 iPhone 身份**，MobileGestalt 缓存才会按 iPhone 生成。如果先用 iPad 身份的镜像开过机，缓存会锁定成 iPad。
2. **全新 Data 黑屏**：每一帧都被 `verify_swap` 拒绝（设置向导的画布问题），加 `sheng-setup=0` 后解决。
3. **用 TWRP 读日志**：a 槽放安卓 boot 和 skkk TWRP；进 recovery 后从 userdata 末尾 32 MiB `dd` 出日志，用 `read-sheng-log.py` 解码。
4. **GPU**：日志显示 metal2vulkan 对 no-copy buffer 上的纹理报 "no linear image"，上游 AdrenoMetal 的 bridge 补丁 0020 修的就是这个；t36/t50 自带的插件比 0020 旧。GPU 客户端最多 4 个槽位。只编插件的 CI 已经走到 Turnip 编译成功，详见 `HANDOFF-GPU-deepseek-2.md`。
5. **USB**：`qcom_usb_debug_init`、`_poll`、`_get_status` 只能在启动 CPU 上执行，t36 却在 `bsd_init` 里调用 init，所以 init 被拒绝（phase -1）。作者在 t50 里修好了。
6. **红条**：屏幕 1080×2400 按 3 倍缩放是 360×800 pt，不是任何一款真 iPhone 的尺寸，UIKit 只能用兜底状态栏。修法是显示驱动报告 1179×2556 并缩放到面板（参考 ios-sweet 0061 和 sirius）。只改尺寸的二进制补丁（`patch-canvas.py`）会卡死开机。
7. **补丁空间**：t36 的 `__hib_text` 之后可用不到 0xa23 字节，超出就无法开机；`__KLD` 段开机后会被回收。

## 文件

- `LOG-FINDINGS-2026-11-03.md`：第一次读出的日志结论。
- `HANDOFF-GPU-deepseek-2.md`：GPU 交接（插件版本 793d6bddf7，CI 只编插件）。
- `HANDOFF-USB-deepseek.md`：USB 排查记录。
- `share-brightness/`：给作者的亮度和按键说明。
- `share-for-author/`：给作者的红条和 USB 说明。
- `ci/fuxi-gpu.yml`：macOS CI（产物用 age 加密；公钥在文件里，私钥不在仓库）。
- `scripts/wsl/`：今天用到的脚本。

镜像、内核、IPSW、私钥、芯片 ID、序列号都不在仓库里。
