# fuxi 触控调试记录（2026-11-01 下午）

接 `HANDOFF-2026-11-01.md`。目标：让 OddlyLabs 的 FTS 触控内核在真机上跑到 `native_touch_probe`。

## ✅ 20:32 进桌面 + 触控（第三方 t32）

- `boot-touch-t32.img`（另一位作者，`third-party\t32\`，sha256 `9D56196E…`）已刷进 **boot_b**，活动槽位 b：
  进 iPadOS 桌面，触控可用，平板布局（用户态是 iPad7,1 / iPadOS 17.7.11）。
- 与 t31 的区别：AKS 参数改回 `sheng-aks=1`（t31 的 `sheng-aks=2 sheng-aks-sls=3` 导致开机要求输密码）。
- 仍带 `sheng-log=1 sheng-data-persist=2`；去掉后界面起不来（`t31-safe.img`：swap 几乎全被拒）。
- slot a 仍坏，未修。

## ✅ 20:12 触控在真机上通了

- 镜像 `E:\DSH-Fuxi\unixnu-fts-own.img`（slot b `fastboot boot`）：我们自己的 format-1 树
  （`yigezhong011-ops/unixnu-fuxi` 分支 `fts-touch`，unixnu-ci 分支 `old-tree`，run 41294613121），
  Novatek 探针换成 OddlyLabs 的 FTS 探针，`fuxi-touch=4`，去掉 `sheng-log` / `sheng-data-persist`。
- 诊断页的触控测试框跟着手指画出红色触点 → 上电、SPI、芯片、中断、上报全通。
- 系统停在 `PE_lockdown_iokit`（procs=0，payload 没有 trustcache / GPU 插件），所以没有桌面。
- 打包：`dump/wsl/pack-fts-own.sh`（内核检查 + `pack-payload.sh`）。
- 注意：`fts-touch` 上有一个别的会话（git 身份 `dsh`）18:34 提交的 `691a765`（改 `fuxi-link-stubs.patch`），也在这次构建里。

## 之前的结论

- **作者内核（user-boot.img）不可能有触控**：只有 Novatek 驱动；`gpuaddon` 是用户态 Metal 包（`NGPUADD2`），装不了内核驱动。
- **OddlyLabs 触控内核在我们的加载器上启动早期随机卡死**：蓝条 + 品红条（MMU 前）都出，MMU 打开没问题（fts5 两次都在色条后正好 6 s 复位），之后卡住。
  同一个镜像有时能过（fts6、fts9b 第一次），有时卡（fts9b 第二次、7a、8b、10、11），所以按函数二分的结果不可靠。
- **OddlyLabs 移植从没在真机启动过**（`porting.toml`："No device boot evidence yet"），它配的是自己的固件
  `OddlyLabs/uefi-fuxi` + header v0 容器 + `FuxiBootMemoryDxe`；我们用的是 user-boot.img 里的 Silicium 加载器（`body.bin`）。
- 换成能让我们自己内核走到 `bsd_init` 的 ADT（adtmatch，arm-io `0x17000000`）也卡在色条（fts14b）。

## ⚠ slot a 坏了

- 17:23 起 slot a 上 `fastboot boot` 任何镜像（含 user-boot.img）都是 `Load Error`，正常启动 4 s 内回 fastboot。
- 16:49 之前正常；期间只有 user-boot.img（作者系统，`native-fuxi-ufs-root=1 sheng-data-persist=2`，会写 UFS）跑过。怀疑它写坏了 slot a 的启动分区（vendor_boot_a 最可疑，未验证；ABL 不支持 `fetch`）。
- `fastboot set_active b` 后 slot b 正常（17:42 user-boot.img、17:46 fts14b 都能加载）。**当前活动槽位：b**。
- 修复：用 `backup\vendor_boot_a.img`（10-24 原厂）刷回，未执行。在查清之前别让 user-boot.img 长时间运行。

## 镜像（E 盘根）

| 镜像 | 内容 | 结果 |
|---|---|---|
| unixnu-fts3 | CI 内核 + CI 配套 ADT | 只到绿条 |
| unixnu-fts4 | + panic 屏补丁（本地打） | 蓝 + 品红条后卡 |
| unixnu-fts5 | + MMU 后 6 s 复位 | 6 s 复位（两次） |
| unixnu-fts6/7a/8b/9a/9b | `--reset-after` 二分 | 结果不稳定，见上 |
| unixnu-fts10/11 | `_serial_init` 改成直接返回 | 卡色条（串口不是原因） |
| unixnu-fts14b | 触控内核 + adtmatch ADT + panic 屏 | 卡色条 |

## 脚本（`dump\wsl\`）

- `patch-panic-fts4.sh <out> [probe args]` — 给触控内核打入口探针 / panic 屏（`patch-xnu-entry-probe.py`；panic 屏和复位探针放不下同一块空隙）
- `build-fts3.sh <kernel> <out> [adt]` — 打 boot.img（`VOL_MIB` 改卷大小；ARM64 头 text_offset 置 0，加载器自己搬到 0xa7100000）
- `build-reset-after.sh` / `build-stub-reset.sh` — 二分镜像
- `list-arm-init-calls.sh`、`show-probe-cave.sh`、`patch-serial-init-ret0.py`
- `adt-tree.py`、`adt-node-props.py`、`adt-uart-nodes.py`、`extract-boot-adt.py`、`bootimg-info.py`

## 下一步

1. 按 OddlyLabs 原设计在 CI 编 `uefi-fuxi` 固件 + v0 boot 镜像（`./unixnu build firmware --uefi ../uefi-fuxi`、`./unixnu bootimg`），再在 slot b 上 `fastboot boot`。
2. 修 slot a（先确认是哪个分区）。
