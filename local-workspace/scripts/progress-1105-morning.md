# 2026-11-05 上午进度

全部是临时启动用的镜像，没有刷分区。今天的新镜像都还没上机，下面的修复效果都没有验证。

## 已确认

- **Data 副本能读了。** APFS 容器从副本的第 1153 个 4K 块开始，所以 7z 打不开。`dump/wsl/apfs-read.py` 可以只读列目录、取文件。
- **PosterBoard 存储是空的。** `PRBPosterExtensionDataStore` 下只有 `59/`，里面的 `Extensions/`、`GalleryCache/` 都是空的。没有 `61/`，没有数据库。原因未查明。
- **日志的私有参数可以打开。** `libsystem_trace` 从 `Logging/Subsystems/<名字>.plist` 读 `Default-Privacy-Setting` 和 `Enable-Private-Data`，解析代码里没看到内部版本的判断。实际效果要上机才知道。
- **覆盖挂载是 `MNT_UNION`。** 下层文件仍可见，所以只需加几个 plist。
- **`vsync sent=0 arms=0` 是正常现象。** CoreAnimation 按 `IOMFBDisplayRefresh` 自己定节拍，系统层已报 120。面板切换是剩下的问题。
- **`AGXDeviceUserClient` 的沙盒拒绝不足以解释白组件。** `backboardd` 也有这个拒绝，但它照常绘制。

## 插件移植

- CI run `41941266963` 成功。`AdrenoMetal 7e0d3d2` 加上 `8c1ea13`、`5a50581` 和 translator 补丁 `0025`（来自 `de4c1ee`）。
- `0025` 不需要 `0021`–`0024` 就能打上，工作流把它加到构建脚本的补丁列表末尾。
- `8c1ea13` 调用了 `69efcdc` 的共享着色器缓存函数。我们不需要这个功能，把调用和 include 去掉了。
- 补丁在 `yigezhong011-ops/unixnu-ci` 的 `ci/patches/adrenometal-poster-7e0d3d2.patch`，工作流输入 `plugin_patch`。

## 自动回 fastboot

`sheng-autoreset` 需要 `sheng-log=1`，在日志写入线程里写 SDAM 再做 PSCI 重置。这条路在 fuxi 上没有验证过。`t50-auto150` 启动后没有回 fastboot，电脑上也看不到手机。可能是 bootloader 不认这个原因，重启进了日常系统，也可能是参数被截断，都还没证实。

## 待测镜像

| 镜像 | 内容 |
| --- | --- |
| `t50-auto200p` | 私有日志 + 自动重启 |
| `t50-auto-120clock-p` | 120 Hz + 时钟校准 + 私有日志 + 自动重启 |
| `t50-auto-plugin-p` | 新插件 + 私有日志 + 自动重启 |

## 没有解决

- 黑壁纸、白组件、120 Hz 都还没有上机验证。
- `chronod` 有 43 次 HEVC 编码失败（`hvc1`，-12782），`ChronoServices` 里有 `heic`、`jpeg`、`png` 三种格式。是否造成发白未证实，要看私有日志。
