# 2026-11-04：卡顿、颜色、自带应用、壁纸排查

镜像、内核、IPSW、密钥和手机原始数据都不在仓库里。

## 已确认

- **GPU 颜色正常。** `t50-mine-gpu-fix`（UniXNU 793d6bddf7 + Turnip GMEM memory-side swap 补丁 + prime list）已刷入日常槽。
- **卡顿由每次开机的 `[coherence]` 探测决定。** 探测通过（如 `d64/64 -> on`）时提交到完成 5–8 ms；失败（`d0/64 a8 -> off`）时每次提交都做缓存维护，测到 43 ms。14 次不同的开机里失败 1 次，重启可恢复。探测还没有加固。
- **自带应用已装上（用户确认）。** 分两步：
  1. `sheng-staged-apps=1`：内核把 OS 卷的 `/private/var/staged_system_apps` 复制进 Data。日志显示前 8 秒 Data 增长约 400 MiB，并在 Data 里读到了 Music、Weather 应用自带的文件内容。
  2. Data seed 的 `com.apple.migration.plist` 里 `LastSystemVersion` 等于当前版本，系统跳过数据迁移，`SystemAppMigrator` 不运行。删除这个文件后迁移运行，应用出现在桌面。
- 迁移测试镜像只改内核里 `sheng-setup=1` 路径的两个字符串（共 45 字节），让它删除 migration plist 而不是 Setup 标记。它每次开机都会删除，所以只能临时启动。
- **添加壁纸无反应的直接原因。** 反汇编 `-[PBFModalRootViewController initWithScene:dataStore:behaviorAssertionProvider:]` 的崩溃点，触发的是 `dataStore != nil` 断言。`dataStore` 来自一个单例（`[... sharedInstance].dataStore`）。

## 未解决

- 壁纸仍然黑、小组件仍然白。应用装上后没有恢复，所以“缺宿主应用”最多只是小组件问题的一部分。
- `dataStore` 为什么为空，只靠静态分析分不出来。日志里 PosterBoard 反复出现 `no system container path found`，这只是线索，还没有证明因果。
- 复制是否 100% 完整、迁移文件是否写回，都还没有确认。
- 米标偶发卡死：多个镜像都出现过，还没抓到卡死那次的日志。

## 工具

- `scripts/wsl/dscan.c`：TWRP 下只读扫描 Data，统计 APFS 对象并找 4K 对齐的 gzip 头。
- `scripts/wsl/carve-oslog.ps1`：从 Data 里取回 adrenoprobed 写的系统日志，还没有在手机上运行过。
- 在 Data 原始数据上按文件名搜索不可靠：`_CodeSignature` 搜不到，但文件内容能搜到。

## 更正

- 之前写“GPU CI 被 macOS 分钟数额度卡住”是错的。`unixnu-ci` 是公开仓库，没有分钟数限制；15 分钟被取消是 `job was not acquired by Runner`，即 macos-26 机器排不上。
- 之前说 iPadOS 没有健康、天气等应用，要 iOS 根卷，也是错的：它们就在 `staged_system_apps` 里，共 28 个，其中没有 Watch。
