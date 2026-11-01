# t32 在小米 13（fuxi）上的帧率实测（2026-11-01 晚）

基于 `boot-touch-t32.img`（内核 sha256 前缀 `c5abbe9de782c30e`，GPU 插件 `c268012b8f92aeba`），只改启动参数，`fastboot boot` 临时启动，读诊断页（`boot-progress=2`）。

## 结果

| 变体 | 改动（相对 t32） | SWAP / GPU | FB 复制 | 体感 |
|---|---|---|---|---|
| t32 原版 | — （`sheng-fb-gpu=0`） | — | CPU 复制 | 很卡，<10 fps |
| **t32-fast / fastdiag** | `sheng-fb-gpu=1` | `gpu offers=1261 done=1261`，滑动时约 23 swaps/s，GPUC 每次 ~1 ms | 只有开机 2 次 | **最流畅** |
| t32-perfdiag | 再加 `sheng-gpu-perf=8 sheng-gpu-dcvs-min=8` | GPU 全部接手，GPUC 每次 ~0.58 ms | — | 没有更流畅 |
| t32-diag / t32-max | 再加 `sheng-dpu-scanout=2 sheng-cpufreq=3` | **`gpu offers=0`**，GPUC 只有 1 次 | **CPU 复制 65–133 ms/帧** | 更卡，1–2 fps |

| **t32-pause** | t32-fast 再加 `sheng-gpu-pause-us=100` | — | — | **明显流畅，目测接近 60 fps** |

关闭诊断页（去掉 `-v boot-progress=2 armcpu-diagnostics=1`）体感也略有提升。
**最大的一步是 `sheng-gpu-pause-us=100`**：fence waiter 的轮询睡眠从默认 1000 µs 缩到 100 µs（ljhhkx529 BUILD-PROGRESS 记 fuxi 早期硬编码就是 100 µs）。

## 观察

1. **`sheng-fb-gpu=1` 在 t32 上可用且明显更好**，t32 里默认是 0。
2. **`sheng-dpu-scanout=2` 在 fuxi 上失败**，而且没有回退到 GPU 复制，而是回退成 CPU 复制（`gpu offers=0`，`copy_us` 65–133 ms）。
   文档写的是"任何失败都会回退到 GPU 复制"，fuxi 上不是这样。
3. GPU 不是瓶颈：680 MHz 下合成 ~0.6 ms/次，CPU idle 74–93%，三个 CPU 域都在最高非睿频。
   帧数低在送帧节奏（work-loop 定时器 / fence 等待 / scanout），参数调不出来。
4. 每次开机 `iconservicesagent` 反复 sig11（PC0，同一 LR），可能影响图标。
5. 日志常驻 `native-metal: no device answer … supportsConditionalLoadStore`，流畅的版本里也有，不是卡顿原因。
6. 面板：原厂设备树 `xiaomi m3 38 0c 0a sec cmd mode dsc dsi panel`，timing@0 60 Hz（`60 08`）、@1 120 Hz（`60 00`）、@2 90 Hz；
   ABL 点亮在 60 Hz，要上 120 Hz 需要通过 DSI 发 timing@1 的 switch command 并改 DPU 时序。完整节点见 `read/fuxi-panel-m3-timings.dts`。

## 按键（电源 / 音量）没反应

- t32 内核有 HID 侧的按键入口（`NativeHidInput::buttonsNotify`、`native_buttons_set_sink`），但没有读 PMIC 的按键源，
  也没有对应启动参数，所以电源键、音量键都没反应，也不能息屏。
- sheng 的设备记录写着按键已可用："Physical keys come from the SPMI PMIC arbiter (0xc400000 cnfg 0xc42d000, observer 0xc440000, EE 0)
  with PON ppid 0x013 and GPIO6 ppid 0x18d"。
- **fuxi 原厂设备树和 sheng 完全一致**（`fuxi-live.dts`）：
  - 电源键：PMK8550（SPMI sid 0）`pon_hlos@1300`，`qcom,pmk8350-pwrkey`，中断 `<0x00 0x13 0x07>` → ppid 0x013，RT_STS bit 7
  - 音量下：同一 PON，`qcom,pmk8350-resin`，中断 `<0x00 0x13 0x06>` → bit 6
  - 音量上：PM8550（sid 1）`pinctrl@8800` 的 GPIO 6，低有效（`gpio_keys/vol_up`，`gpios = <… 0x06 0x01>`）→ 0x8d00，ppid 0x18d
  - SPMI 仲裁器 `qcom,spmi@c42d000`，EE 0
- 所以把 sheng 的按键源（UniXNU-sheng / ShengHidInput 的 SPMI PON+GPIO 轮询）原样编进内核应该就能用。

## 建议的日常参数

t32 原参数 + `sheng-fb-gpu=1` + `sheng-gpu-pause-us=100`，去掉 `-v boot-progress=2 armcpu-diagnostics=1`；不要 `sheng-dpu-scanout`。
对应镜像 `t32-pause.img`。建议把 `sheng-gpu-pause-us` 的默认值改回 100 µs。
