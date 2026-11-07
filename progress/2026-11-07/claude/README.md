# 2026-11-07 Claude：USB 手势带坐标、自动解锁、壁纸

测试用 `fastboot boot` 临时启动。最后经用户同意刷了 boot_b。

## 结果

- **日用镜像已刷入 boot_b：** `t50-daily-gpu7.img`（73948d996622540b，gpu7 + 手势命令 + 新固件，不带自动重启），读回校验一致。正常启动 30 秒出 COM3，脚本解锁进桌面（1 次）。备份 `logs\boot_b-before-gpu7-001515.img` 留在本地。设置 → 墙纸在这个镜像上没试过。REBOOT 叫回也没在它上面试过。

- **自动解锁成功（1 次）：** 脚本发一条命令，从小白条下方上划进桌面，用户也看到了。截图 `shots/desk-after-unlock.png`。
- **gpu7 底子有壁纸：** 锁屏和桌面都能看到地球壁纸。`shots/lock-wallpaper.png`。之前的黑壁纸来自不带 GPU 补丁的底子。
- **命令带坐标：** 新增 `TAP-xxxx-yyyy` 和 `SWP-xxxx-yyyy-xxxx-yyyy-mmmm`（十六进制）。挂在唯一一处 `bl _sxnu_control_parse_verb` 上，CRC、序号、回复都走原路径。
- **串口计数正常：** `hid` 和 `seq` 与手势次数完全对得上（上划 17 个报告，点击 6 个）。
- **回落自动处理：** `ctl-run.ps1` 握手后发一个角落点击，日用镜像不回复就算回落，叫回后重跑，最多两次。

## 没解决

- **点击“设置”没有打开（1 次）：** `tap 225 300` 送达了，画面没变。原因没查。可能是 X 换算不准，也可能是别的。
- **X 换算只有一个数据点：** `x=10160` 打开了约 307 pt 的地图，由此推出满量程约 11790。上划和点击都没有验证它。
- **卡米标频繁：** `t50-auto-gpu7tap` 8 次启动回落 3 次，原因没查。
- **卡顿：** 没有动。

## 更正之前的说法

1. **打印垃圾值不是地址问题。** cave 按 ELF 编译，可变参数在寄存器里；XNU 的 `printf` 按 Darwin 规则全部从栈上读。`p=64` 其实是 `ibs`，其余是栈内容。还多传了一个参数。修法：声明 7 个占位寄存器参数，把真实值压到栈上。
2. **`p=64` 不是相位槽被覆盖。** 新 cave 不再用相位，邮箱放在触摸数组第 10、11 槽，驱动最多写 10 根手指。
3. **“上滑解锁”不准确。** `touch3` 的上划其实是向下划。Y 被 cave 又镜像了一次，只有屏幕正中那个点不受影响。用户从屏幕上发现了方向反了。
4. **之前的上划扫描作废。** 那 12 组都是从顶部往下划。末尾 `hid` 比手势数多，可能是有人碰了屏幕，没查证。
5. **`qud-shot.ps1` 拿不到 HELLO：** 11-06 的 5 次重复启动里它工作正常，交接里这条不一定成立。
6. **COM3 日志里有 `NativeHidInput ... open`。** 之前的 60 秒日志搜不到，可能只是时间太短。所以可以用 COM3 判断这次有没有触摸，还没实现。

## 坐标

脚本用屏幕点（360×800）。y 从顶部算，`Hex-Y` 换算成 `(800 - y) × 25.4`，cave 再镜像一次。x 乘以 `11790 / 360`。

## 用法

```
ctl-run.ps1 -Name t50-auto-gpu7tap -Steps "at 110; home; wait 3; shot desk; tap 225 300; wait 4; shot next"
```

步骤：`at`、`wait`、`shot`（传图，约 24 秒）、`probe`（只看编码大小和 CRC，约 0.1 秒）、`tap`、`swipe`、`press`、`home`。

REBOOT 回 `state=nohook` 表示启动后太早，钩子还没装好（95 秒时见过一次），脚本会重试。

## 上游（2026-11-07 09:40 查）

`ljhhkx529/unixnu-fuxi` 的 `V2` 分支 11-05 到 11-06 有 14 个新提交，`old` 分支没动。我们按规则用 `old`，所以只作参考，没有合入。没有涉及触摸、壁纸、GPU、卡米标的提交。

- **复位（2988fa8）：** 作者也发现 `PE_halt_restart` 的卸载路径在这个 UFS 驱动上回不来，改成直接固件复位。和我们的 `patch-t50-usbfast.py` 结论一致。
- **panic 回 fastboot（8a8f13d、4e39610）：** 启动参数 `fuxi-panic-fastboot=30`。我们的 panic 路径还没验证，可以参考。写 PMIC SDAM 字节 0x48（bootloader = 2）后 PSCI 复位。
- **串口常驻（a92aed5）：** `scripts/fuxi-usb-debug.sh`，手机重启后自动重连。只支持 macOS 的 `/dev/cu.usbmodem*`，思路可借鉴。
- **控制台（673ce1c）：** 去掉 `-enable_kprintf_spam`，否则 CDC 丢行。我们的参数本来就没有它。
- **文档：** `patches/manual/README.md` 说明了驱动端 4 个补丁。

其他参考仓库（GopFramebuffer、QcomXnuUsbDebug 两份、SadNutWall、Kerfand wifi）这次 fetch 没有新提交。`UniXNU/UniXNU` fetch 失败，没查到。

## 下一步

1. 查点击为什么没打开设置，校准 X。
2. 自动进设置 → 墙纸，确认不闪退。
3. 查卡米标为什么变频繁。
