## 当前进度：UniXNU / iPadOS 17.7（2026-11-02）

小米 13 现在走的是 [UniXNU](https://unixnu.com/zh) 路线：系统用 ljhhkx529 的 t32 内核（iPadOS 17.7），我们往内核里注入代码补齐硬件支持。日常镜像刷在 boot_b，镜像文件不放进仓库。

| 功能 | 状态 |
| --- | --- |
| 进桌面、触摸 | ✅ |
| 帧率 | ✅ 约 60 帧（`sheng-fb-gpu=1 sheng-gpu-pause-us=100`） |
| 电源键 / 音量键 | ✅ 息屏、截图、关机滑块；音量键已送到 iOS，但没有音频，所以音量不变 |
| 亮度条 | ✅ 通过 DSI 发 DCS 0x51 给 OLED |
| 壁纸 | ❌ 黑屏：HEIC 壁纸没有硬件解码，需要 PNG 覆盖（在查） |
| 小部件 / 设置 | ⚠️ 小部件全白、设置加载慢：GPU 客户端名单只有 SpringBoard（在查） |
| 音频、Wi-Fi、蓝牙、相机 | ❌ |
| 120Hz、iPhone 布局、灵动岛 | 🔬 实验中 |

每天的记录（做法、诊断读数、脚本）：

- [progress/2026-11-02](progress/2026-11-02/README.md)：按键、亮度、打包陷阱（Data 种子藏在 FAT 空闲簇里）、壁纸 / GPU / iPhone 布局的调查
- [progress/2026-11-01](progress/2026-11-01/README.md)：触摸、进桌面、帧率、按键注入

下面是这个仓库原来的 iOS 16 路线说明，保留不动。

---

