# 给 ljhhkx529 的请求：fuxi 上 Metal 客户端的两个问题（2026-11-02）

> 可直接转发。我这边只做 `fastboot boot` 临时测试，不改你的仓库。

## 我们在跑什么

小米 13（fuxi，SM8550，Adreno 740），你的 t32 内核 + 我们注入的按键/亮度代码。
boot_b 日常版：`t32-bl-daily`（按键读 PMIC、亮度走 DSI0 DCS `51`），桌面约 60 帧。

## 现象（均为真机观察）

| 现象 | 说明 |
|---|---|
| 壁纸全黑 | iPadOS 17 默认壁纸 7570 是 HEIC；没有硬件 HEVC 解码器就画不出来。UniXNU 的 `make-wallpaper-overlay.py` 会做 PNG 覆盖（`/private/var/ngpu/wallpaper`），但 t32 的 GPU 附加包里没有这份 PNG |
| 小部件、图标白色 | `NativeAdrenoMetal.clients` 只有 `mediaserverd` 和 `SpringBoard` |
| 设置打开慢 | 同上；另外内核 `kClientWindows` 只有渲染服务 + 2 个客户端窗口 |
| `iconservicesagent` 崩溃 | 拿不到设备时的典型结果 |

我们做过的实验：把 `.clients` 改成 `SpringBoard,WidgetRenderer_Default,iconservicesagent,Preferences`
（等长原地重写，12,172,992 字节不变），镜像 `t32-gpu4` 已做好，等上机验证。

## 上游已经修了这些（分支 `fix/gpu-scheduling-and-metal`，比 main 多 13 个提交）

指向的驱动提交：

| 仓库 | 提交 | 内容 |
|---|---|---|
| `AdrenoMetal` | **`b82fa275`** | `Default every Metal client to single-sample rendering` |
| `AdrenoMetal` | `bc4e8b81` | `Correlate Metal surfaces, render paths and completed pixel samples` |
| `AdrenoMetal` | `b2af19a2` | `Verify shader-selected viewport and scissor arrays` |
| `Adreno740` | **`4db2aa75`** | `Document GPU frame trace and pixel export`（含双环调度） |
| `Adreno740` | `5106df65` | `Preserve GPU context and queue ordering across priority rings` |
| `Adreno740` | `c7b937d4` | `Reschedule priority work after switching and track global fence progress` |
| `Adreno740` | `49ec11a8` | `Add bounded GPU frame traces and completed pixel capture storage` |

分支里的集成提交：

- `5cf367ac` Integrate Metal interface and compiler fixes into normal builds
- `7f2c4c15` Integrate priority rings and shared shader caching into GPU builds
- `679c2033` Integrate frame diagnostics into Metal and Turnip builds
- `2585c0eb` Pin display fence completion and retry fix
- `5ec0fc64` Pin global single-sample rendering and exercise the default policy

完整子模块 pin（分支 HEAD `135b0dab`）：

```
drivers/Adreno740    4db2aa75415775667a8d1c03058053102183f7de
drivers/AdrenoMetal  b82fa2751d62d3b0a8b9330a58d1506d9cdf0963
kits/AirNir          b356371a74cd158c2902f4886f373ebb0f833a36
kits/AdrenoFirmware  20ad3d7aca14bd46aecab6335c780f5413fa054b
kits/AdrenoPM4       282606b528b2595bc4274ea7490b62b323f35a5f
```

## 想请你做的三件事

1. **用上面这组 pin 重编一次 GPU 插件和 Adreno740 驱动**（`NativeAdrenoMetal.bundle` + 内核里的 Adreno740/AdrenoMetal）。
   如果分支的 Metal 接口改动要求插件和驱动同时换，请一起换——我们两边版本不一致时插件会直接拿不到设备。
2. **确认单一采样默认值**（`b82fa275`）是否就是小部件变白的修复；如果还需要额外启动参数，请告诉名字。
3. 如果方便，**放宽客户端窗口数**：现在 `kClientWindows` 只有 2 个客户端槽位，名单里多出来的进程拿得到设备但没有专属窗口。
   可以是启动参数（例如 `sheng-gpu-clients=N`），也可以是固定的 4 个。

4. **壁纸 PNG 需要重建载荷才能加**（如果方便，请在你的下一次构建里带上）。
   情况是这样的：`make-wallpaper-overlay.py` 生成的覆盖文件我们已经在 macOS runner 上做好了
   （iPadOS 17.7.11 21H461 的 OS 卷，`7570.iPadOS_17_Flat`）：`J120.png` 5,389,045 B、
   `J120-Dark.png` 5,262,293 B、`main.caml` 105,940 B、`index.xml`、`assetManifest.caml`。
   转成 JPEG（2732×2732，q92）后是 362 KB + 332 KB，加上 `main.caml` 压缩后约 735 KB。
   但 t32 的附加包是 12,172,992 字节，**必须原地等长写入**（Data 种子在 FAT 空闲簇里），
   而可删的非必需条目只有约 27 KB，`libvulkan_freedreno.dylib`（3 MB）又不能删——
   `NativeAdrenoMetal` 里内置了 metal2vulkan，运行时要它。
   所以在 `--gpu-addon` 里加 `--wallpaper <dir>`（`make-gpu-addon.py` 支持）**必须重建整个载荷**，
   Data 种子随之重新生成。我们这边没有你的构建树，做不了。
   覆盖文件随时可以发给你，或者你自己用 iPad7,1 的 17.7.11 IPSW 跑一遍 `make-wallpaper-overlay.py`。

## 我们的限制

- 插件和驱动只能在 macOS 上编，我们编不了；只做 `fastboot boot` 临时启动，不刷分区。
- 我们可以在真机上跑任何版本并把日志/诊断行拍给你。需要的话我可以把 `t32-gpu4` 的名单实验先做完，把结果一并发你。

## 附：我们这边已验证的事实（供参考）

- 亮度：DCS `51` 经 DSI0 已通（`BL ga s4 q167 t25e l25e k167 f0 e0 c175 i500`，0 次失败）。
- 按键：PMIC 读取 → `native_buttons_set_sink` → report 2，已在真机验证 iOS 能收到（截图、关机滑块）。
- `sheng-backlight=1` 走 KTZ8866 I2C 在 fuxi 上会崩：fuxi 是 OLED，`i2c@a84000` 在原厂设备树里 disabled。
