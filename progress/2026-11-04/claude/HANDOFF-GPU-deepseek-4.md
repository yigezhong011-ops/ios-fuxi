# 交接给 DeepSeek：黑壁纸和白小组件（2026-11-04 夜）

把下面整份发给 DeepSeek。

你接手小米 13（fuxi，SM8550）UniXNU 移植的 GPU 和壁纸排查。工作目录 `E:\DSH-Fuxi`；WSL 用 `wsl -u root`；fastboot 和 adb 在 `E:\DSH-Fuxi\tools\platform-tools\`，不在 PATH 里。用中文和用户交流，每次只让用户做一件事。

## 硬性规则

- 只用 `fastboot boot` 临时启动。刷分区必须先问用户。
- 不要启动 iPad 身份的镜像（t32 系列），否则 Data 的身份缓存会被改写，然后黑屏。
- 不刷 userdata，不清 Data。
- 不要自行永久删除。Windows 上要删的文件移到 `E:\DSH-Fuxi\待删除`，由用户删。WSL 里的目录要用户明确同意才能删。
- 不往 C 盘写数据。
- 镜像、内核、IPSW、`token2.txt`、`keys\`、芯片 ID、序列号和手机原始数据都不能上传。`logs\data-raw.img`、`logs\data-list.txt`、`logs\carve-*` 都属于原始数据。
- 不 force push，不删改别人的文件。

## 当前状态

- 手机：fastboot，b 槽，重试次数 7。`boot_b` 是 `t50-mine-gpu-fix.img`，今晚没有刷分区。
- 今晚测试镜像 `t50-mine-gpu-wall.img` 启动过一次，它的 25 个 Bokeh 目录文件可能留在 Data 的 `/private/var/ngpu/wallpaper`，是否写入没验证。日常内核的第三个覆盖挂载目标不是 `/Library/Wallpaper`，而是 7570 的 `.ca` 路径（改动见 `make-t50-gpu-wall.sh` 第 57–60 行）。残留文件对日常启动有没有影响，没有验证。
- GPU 插件和驱动没有改动，没有跑 CI。
- 用户把 WiFi 放后了（`Kerfand/UniXNU-fuxi-wifi` 没有读），优先 GPU。

## E 盘：先处理

- 写这份交接时 E 盘只剩约 3.6 GB。`logs\data-raw.img` 占 16 GB。
- 已删 WSL 目录，内部占用从 64 GB 降到 30 GB，但 `ext4.vhdx` 没有变小。
- 压缩要 `wsl --shutdown` 再压缩 vhdx，还没做。**先问用户**，并确认没有任务在用 WSL。
- 分析完 `data-raw.img` 后，把它和 `dump\root-peek`（约 6 GB）移到 `待删除`。
- `/root/hakios-xnu-kernel`（8 GB，1 个未推送提交）和 `/root/build`（2.2 GB，有未提交修改）没有删，要用户决定。
- `/root/fuxi` 里最近脚本还在引用的目录也留着了，清单在 WSL 的 `/root/clean-keep.txt`。`dump\wsl` 里较旧的脚本可能引用已删目录，运行前先检查路径。

## 已确认的事实

1. **系统日志可以直接取。** adrenoprobed 的 `oslog.txt.gz` 不存在（原因没查）。改用 `dump\wsl\lscan-arm64`：在 TWRP 里解压 Data 的 LZ4 `bv41` 块并输出字符串。流程见 `dump\wsl\pull-wall.ps1`。
2. **隔离单次启动：** 日志混着多次启动，时钟是 1969 年，没有可用时间。比较启动前后两份 lscan 的块，见 `dump\wsl\read-wall1.py`。
3. **系统只有 iPad 壁纸目录。** 只有 `Collections~ipad.plist`、`DefaultWallpapers~ipad.plist`、`Wallpapers~ipad.plist`，没有 `~iphone` 版。代码用 `DefaultWallpapers~%@.plist` 查找。
4. **加 iPhone 目录后依然是黑的。** `make-t50-gpu-wall.sh` 把 Bokeh 5010 通过第三个覆盖挂载到 `/Library/Wallpaper`。日志里没有挂载状态，所以不知道挂载是否生效。这次结果不能排除目录问题。
5. **PosterBoard 大致每次启动报一次错。** `generalErrorDomain Code=0` 共 37 次，PosterBoard 进程号 33 个。4 次明文是 `Data store could not be created ... unknown reason`，其余原因是 `<private>`，不能确定都相同。
6. **选壁纸崩溃** 是 `dataStore != nil` 断言。两者的因果还没验证。
7. **小组件：** 当前启动有 43 次 `CMPhotoCompressionSessionAddImage err -12782 (codec hvc1)` 和 43 次 `unableToFinalizeImageDestination`。是否造成发白未证实。
8. **GPU 驱动：** 这次启动平均 5 ms，最长 38 ms，`[reset]` 为空，`coherence -> on`。PosterBoard 和壁纸进程没有申请 GPU。

## 只是推断

- `-[PBFPosterExtensionDataStore initWithURL:...]` 有三条失败路径。“could not setup data store” 和 “could not validate data store integrity” 两条日志的原因是公开字段，lscan 里没有；但 lscan 只能看到字符串参数，这不算严格证明。
- 第三条是数据库 `initWithURL:options:error:` 返回空（`0x1ca8350ac`），只记 `failed to setup database`。日志里没有针对它的 SQLite 错误。
- `options=1` 时的分支还没读完，我曾猜“文件不存在就失败”，读指令后没有证据，不要采信。
- 系统时钟 1969 年是否相关，未知。上游 asteroids 记录用 `QcomPmicRtc` 加 `/private/var/db/unixnu-rtc-offset` 修了时钟（同为 PMK8550，SoC 不同）。

## 第 1 步：看 Data 的真实文件

`logs\data-read.out.txt` 是校验和列表的结果，`read-data-raw.sh` 产生它：先确认 `hash OK`。如果 7z 没能列出文件，就说明这条路不通，要告诉用户，不要猜。

如果列出来了，回答三个问题：

1. `.../Library/Application Support/PRBPosterExtensionDataStore/61/` 里有没有数据库文件，大小和权限如何。容器是 `Containers/Data/Application/353FB615-9AD2-407D-B79C-EFF255D5432B`。
2. `/private/var/ngpu/wallpaper` 有没有写入。
3. `com.apple.migration.plist` 有没有被写回（这件事今天一直没验证）。

只读 `data-raw.img`，不要改它。

## 第 2 步：按结果选方向

- **数据库缺失或损坏：** 重建这个目录要改 Data，必须先问用户并备份。
- **数据库正常：** 继续读 `validateDatabaseWithError:` 和 `setup`。工具是 `dump\wsl\read-dsc-xref.py`、`read-dsc-build.py`，依赖 `dump\root-peek\dsc`。
- **数据存储修好后如果仍黑：** 再验证 iPhone 目录，并查 Poster 渲染。上游插件 `8c1ea13`（函数常量、Poster 单采样）和 `5a50581` 与我们的 `7e0d3d2` 有冲突，内核能否配合也没查，不要直接上。日志里 `pro24MainFragment`、`lightsMeshFragment` 因 `FunctionConstant` 被拒，它们是否属于壁纸还未确认。

## 线索来源

- `SadNutWall/unixnu-fuxi` 的 `b7fb7db`：同样指出 iPadOS 根卷没有 `~iphone` 壁纸。
- 上游 `alioth.toml`：u276 时渲染进程不再崩溃，壁纸依然不显示。
- `oosexgang/hakios-metal`：11-03、11-04 有壁纸冻结和状态栏白带修复，代码针对 Adreno 7c+ 和 iOS 16.5，不能直接用。

## 更正

- “4 个 GPU 槽位没有依据”说过头。上游记录提到四个槽位，也指出 Poster 被拒是因为每进程 8 次打开上限。我们这台的 `e00002d5` 还要单独确认。
- 我曾说这个错误“只在改语言时出现”，是错的。
