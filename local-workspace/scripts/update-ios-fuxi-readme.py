#!/usr/bin/env python3
"""Rewrite only the top "当前进度" part of ios-fuxi's README.md (everything before the line that starts the original
iOS 16 description), leaving the rest byte for byte. Usage: update-ios-fuxi-readme.py <repo>"""
import sys
from pathlib import Path

p = Path(sys.argv[1]) / 'README.md'
text = p.read_text(encoding='utf-8')
marker = '下面是这个仓库原来的 iOS 16 路线说明，保留不动。'
at = text.index(marker)
head = '''# ios-fuxi

## 当前进度：UniXNU / iPadOS 17.7，iPhone 14 Pro 布局（2026-11-03）

小米 13 现在走的是 [UniXNU](https://unixnu.com/zh) 路线：系统是 iPadOS 17.7.11，机型身份是 iPhone 14 Pro，内核用 ljhhkx529 的 t50，再注入我们的按键补丁。日常镜像 `t50-mine` 刷在 boot_b，镜像文件不放进仓库。

| 功能 | 状态 |
| --- | --- |
| 进桌面、触摸 | ✅ |
| iPhone 14 Pro 布局 + 灵动岛 | ✅ |
| 电源键 / 音量键 | ✅ PMIC 轮询注入；没有音频，所以音量条不出现 |
| 亮度条 | ✅ 作者内核自带的 DSI 亮度（DCS 0x51） |
| USB 调试串口 | ✅ 开机约 40 秒后电脑出现 COM3，实时输出内核日志 |
| 顶部红条 "rdar:45025538"、控制中心缩在中间 | ❌ 屏幕 360×800 pt 不是真 iPhone 尺寸，需要改显示驱动 |
| 小组件 / 文字空白、壁纸黑 | ❌ GPU 插件缺 bridge 补丁 0020；壁纸需要 PNG 覆盖 |
| 音频、Wi-Fi、蓝牙、相机 | ❌ |

每天的记录（做法、诊断读数、脚本）：

- [progress/2026-11-04](progress/2026-11-04/README-gpu-ci.md)：GPU 插件 CI（只编插件，UniXNU 793d6bddf7）
- [progress/2026-11-03](progress/2026-11-03/claude/README.md)：iPhone 14 Pro 布局、USB 调试口、TWRP 读日志、红条和 GPU 的根因；同一天的[壁纸实验（重建载荷）](progress/2026-11-03/README.md)和 [USB 固件补丁](progress/2026-11-03/firmware-usb-power/README.md)
- [progress/2026-11-02](progress/2026-11-02/README.md)：按键、亮度、打包陷阱（Data 种子藏在 FAT 空闲簇里）、壁纸 / GPU / iPhone 布局的调查
- [progress/2026-11-01](progress/2026-11-01/README.md)：触摸、进桌面、帧率、按键注入

'''
p.write_text(head + text[at:], encoding='utf-8')
print('README head rewritten,', len(head), 'chars')
