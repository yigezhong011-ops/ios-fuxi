# 2026-11-04 夜：壁纸和小组件排查

镜像、内核、IPSW、密钥和手机原始数据都不在仓库里。今晚没有刷分区，GPU 插件和驱动没有改动，没有跑 CI。

## 结果

- **黑壁纸和白小组件都还没修好。**
- 加入 iPhone 壁纸目录的测试镜像启动后依然是黑的。日志里没有挂载状态，所以不知道挂载是否生效，这次结果不能排除目录问题。

## 已确认

- **系统日志可以直接从 Data 取。** 用 `lscan.c` 在 TWRP 里解压 LZ4 `bv41` 块。比较启动前后两份输出，能隔离单次启动。
- **系统只有 iPad 壁纸目录**：`Collections~ipad.plist`、`DefaultWallpapers~ipad.plist`、`Wallpapers~ipad.plist`，没有 `~iphone` 版。
- **PosterBoard 大致每次启动报一次错。** `generalErrorDomain Code=0` 共 37 次，进程号 33 个。其中 4 次明文是 `Data store could not be created`，其余原因被标为 `<private>`。
- **小组件相关：** 当前启动有 43 次 HEVC 编码失败和 43 次 `unableToFinalizeImageDestination`。是否造成发白未证实。
- **GPU 驱动：** 这次启动平均 5 ms，最长 38 ms，没有 GPU 重启。

## 还没证实

- 数据存储失败的原因。反汇编把嫌疑缩小到数据库初始化，但日志里没有直接证据。
- 系统时钟停在 1969 年是否相关。
- `oslog.txt.gz` 为什么没有写出。

## 更正

- “4 个 GPU 槽位没有依据”说过头：上游记录提到四个槽位，也指出 Poster 被拒是因为每进程 8 次打开上限。
- 我曾说 PosterBoard 的错误“只在改语言时出现”，是错的，之前只数到了明文那几条。

## 工具

- `scripts/wsl/lscan.c`：只读解压 Data 里的 LZ4 块，输出字符串。
- `scripts/wsl/read-lscan*.py`、`read-wall1.py`、`read-wall2.py`：搜索日志、隔离单次启动。
- `scripts/wsl/read-dsc-build.py`：按调用的选择子定位 PosterBoard 框架代码。
- `scripts/wsl/make-t50-gpu-wall.sh`：iPhone 壁纸目录测试镜像，只能临时启动。

交接文档：`HANDOFF-GPU-deepseek-4.md`。
