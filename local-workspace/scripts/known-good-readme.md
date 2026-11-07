# 能进 iOS 锁屏的那版固件（备份）

本目录保存"能启动到 iOS 锁屏界面 + 触控可用"那一版的关键文件。

## 文件

| 文件 | 说明 | SHA256 |
|---|---|---|
| `kernel.development.fuxi` | XNU 内核（CI run 40258554835，含 0111 zap、0112 kick、0114 cpu-copy 三个补丁，已移除 0110 每帧调试日志） | `becb095764c59db9537f9e005d70e783476a0c2e628df16fe50b788b54343c44` |
| `payload-diag.bin` | SWEETXNU 载荷（内核 + ADT + cmdline） | `3ff867e1dabd61b2ba6b93cae328dd79f5e86c9e148081716c5b6e3369a8e13b` |
| `fuxi.adt` | 生成的 Apple Device Tree | — |
| `boot-current.img` | 可直接 `fastboot boot` 的镜像（17 MB，header v3） | — |

## 能进锁屏的关键条件（缺一不可）

1. **内核**：上面的 `kernel.development.fuxi`
2. **root**：iPhone X iOS 16.7.16 (20H392) 的 HFS+ 镜像（16 GB，`mkiosroot.sh` 构建
   + `sweet-root-tweaks.py` 基础集），放在 `/data/fuxi/iosroot.img`，
   用 `fiemap_bytes` 算出 extents 后写进 ADT
3. **cmdline**（这一版实际使用的）：

```
debug=0xc serial=3 cpus=6 keepsyms=1 -noprogress rd=ufsroot0 fuxi_ufs_probe=1
ufsroot=userdata ufsrw=1 rootrw=1 unentitled_ios_sim_launch=1 ignition_level=1
wdt_test=no_user_checkin launchd_unsecure_cache=1 wdt=-1 sweetlog=0
sweetfb_noconsole=1 sweetnoexec=bluetoothd,fairplayd.H2 fuxigpu=1 fuxiperf=1
sweetsample=backboardd,Preferences,PosterBoard sweetscan=PosterBoard,Preferences
fuxigpuabi=1 fuxiprivs=1 fuxisbpath=1 fuxidbgflush=1 fuxigpuscanout=1
fuxibacklight=1 fuxitouch=1 sweetfb_hz=30 -enable_kprintf_spam fuxi_unixnu_diff=1
```

4. **loader**：`shim/fuxi-loader`，其中：
   - `start.S` 追加了关闭 MMU 的序列
   - `loader_main` 调用了 `probe_touch_up()`（来自 `fuxi-probe/probe.c` 的
     `touch_power(9)`，它会向 RPMh 投票 ldob12=1.8V / ldom6=3.2V 并复位触摸 IC）

5. **触摸供电**必须由 loader 做，内核驱动明确不碰 RPMh（见 `fuxi_touch.c` 头注释）

## 已知限制

- 帧率约 1.6 fps：CoreAnimation 走纯 CPU 软件渲染（1125×2436）
- GPU 路径（FuxiMetal）已能通过准入门，但卡在 CA 请求私有格式 550（XR10）——
  需要实现扩展色域支持才能继续，见 `docs-lanes/metal-m9n.md`
- 120 Hz 从未在该类移植上实现过，面板时序仍是 ABL 设的 60 Hz

## 恢复方法

```sh
adb reboot bootloader
fastboot boot boot-current.img
```

不写任何分区；长按电源 12–15 秒即回 Android。
