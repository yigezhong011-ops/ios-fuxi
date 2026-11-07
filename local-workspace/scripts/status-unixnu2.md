
## 2026-10-25 21:40 —— UniXNU 完整链路打通，首次上机启动固件 ✅

### 今天完成的整条构建链

| 阶段 | 产物 | 状态 |
|---|---|---|
| format 2 配置 | board.toml + feeds.toml + fuxi_defconfig + dts/fuxi.dts | ✅ |
| 内核 | `kernel.macho` 49 MB（CI 构建，prelink 成功） | ✅ |
| payload | `payload.img` 192 MB FAT32，卷标 FUXIESP | ✅ |
| 固件 | `SILICIUM_UEFI.fd` 3 MB（本机 WSL 编 EDK2） | ✅ |
| 启动镜像 | `boot.img` 193 MB（BootShim+FD+DTB+payload） | ✅ |
| fastboot boot | ABL 接受并跳转 | ✅ |
| **UniXNU 菜单** | **实机显示 version 0.1.0 + 菜单** | ✅ |

### 本轮踩过的坑（都已解决）

1. `feeds.toml` 缺 SoC 源 → 加 sm8550 条目
2. 缺 `dts/fuxi.dts` → 按 sheng 模板写（12 GB 内存 + splash@0xb8000000）
3. defconfig 开关与组件不匹配 → 逐项关掉 BOOT_PROGRESS/SOURCE_CORECRYPTO14/MOCKFS/ADRENO/AES
4. macOS workflow 日志路径不匹配格式 2 → 改递归收集
5. 官方 workflow 不传内核 → fork 里加 1 天保留期的产物上传
6. panic_screen 需要固件 Font.h → 先关掉
7. EDK2 依赖 mu_nasm/iasl 走 Azure feed，mono 的 TLS 失败 → curl 下载到本地 feed + 改 yaml 源 + stuart_update
8. 直接 `build_uefi.py` 缺 PACKAGES_PATH → 改用 `unixnu build firmware`
9. FDF 重复 GUID → FuxiRamDiskDxe 已在 Include/DXE.inc 中，不要重复添加

### 当前卡点：`no boot entry found`

固件已经包含 `FuxiRamDiskDxe` + `Fat` + `DiskIoDxe`（在 Include/DXE.inc 里），
但菜单显示 `drivers 0 loaded / 0 failed`、`no boot entry found`。

驱动的逻辑（FuxiRamDiskDxe.c）：
- 扫描 UEFI 内存映射，找偏移 0x47 处卷标为 `FUXIESP` 的 FAT 引导扇区
- 或者用 DTB 地址作提示，向**下**探测 payload

payload 本身验证无误（FAT32、FUXIESP、393216 扇区）。
所以问题在：**ABL 把 ramdisk 放到了驱动扫描不到的内存区域**，或 DTB 与 payload 的相对位置不符合驱动的探测方向。

### 明天的切入点

1. 读 `FuxiRamDiskDxe.c` 的完整扫描逻辑（Scannable 的内存类型、hint 来源）
2. 确认 boot.img 里 DTB 与 ramdisk 的实际加载地址（ABL 日志/lk 配置）
3. 备选：不走 ramdisk，把 payload 放到真实 FAT 分区（userdata/ESP）让 BDS 直接枚举

### 关键文件

- `E:\DSH-Fuxi\unixnu-boot.img` —— 193 MB 可 `fastboot boot` 的镜像
- `E:\DSH-Fuxi\unixnu\` —— board.toml / feeds.toml / fuxi.dts / fuxi_defconfig / check-fuxi.py
- `E:\DSH-Fuxi\unixnu\payload\` —— kernel.macho + payload.img + payload.json
- WSL：`/root/UniXNU`（主仓）、`/root/UniXNU-fuxi`（设备仓）、`/root/uefi-fuxi`（固件，已打补丁）
- CI：fork `pyhs5g27vr-hue/UniXNU`，workflow 已加日志修复 + 产物上传
