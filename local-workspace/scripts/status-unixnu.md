
## 2026-10-25 15:45 —— UniXNU 线：fuxi 内核首次编译成功 ✅

### 里程碑

    Build kernel: success
    prelink.log: Experimental candidate: 51843072 bytes
    kernel.macho 49.44 MB

路径：`E:\DSH-Fuxi\unixnu\kernel\ipados-17.7.11-21H461\fuxi\kernel\kernel.macho`

### 做对的关键改动（相对 hanzi 的原始仓库）

1. **board.toml 升到 format 2**：`schema_version=2`、`soc_source="sm8550"`、
   `os_profile="ipados-17.7.11-21H461"`、`[components] include`、`[device_tree]`、
   `config_fragments`、`patch_series`
2. **feeds.toml 补上 SoC 源**（hanzi 的版本只有 IOStorageFamily，缺 sm8550 → 报
   `feeds.toml needs a source with kind = "soc" and name = "sm8550"`）
3. **新增 dts/fuxi.dts**（hanzi 仓库根本没有 dts 目录）：SM8550 dtsi + 12 GB 内存 +
   splash_region@0xb8000000 + ufs/gpu 使能
4. **defconfig 逐项关掉未构建组件的开关**：
   - `CONFIG_XNU_BOOT_PROGRESS=n`（需要 UFS/owner-root/virtio/corecrypto 全开）
   - `CONFIG_XNU_SOURCE_CORECRYPTO14=n`（避免 corecrypto 归档循环依赖）
   - `CONFIG_XNU_SOURCE_MOCKFS=n`（os profile 默认开启，缺 mockfs 归档会链接失败）
   - `CONFIG_XNU_NATIVE_ADRENO=n`（soc 片段默认开启，缺 Adreno740 归档会链接失败）
   - `CONFIG_XNU_NATIVE_AES=n`（组件 SoftwareAES 在 runner 的 catalog 里不存在）

### workflow 侧的两处修改（fork 里）

1. 日志收集改为递归 `out/*/logs` + `out/*/*/*/logs`（格式 2 输出路径变了，
   否则失败时拿不到 kernel.log）
2. 增加 1 天保留期的 `unixnu-fuxi-build` 产物上传（官方 workflow 明确不上传内核）

### 设备输入

- `unique chip id`：`0x0000043716e79b62`（来自 `/sys/devices/soc0/serial_number`，
  soc_id 519 / KALAMA）
- 已作为 secret `UNIXNU_UNIQUE_CHIP_ID` 加入 fork

### 下一步

1. payload 构建（进行中）：产出 `payload.img`（含 kernel.macho + ADT）
2. 固件：需要编 `uefi-fuxi`（EDK2），workflow 不代劳 → 在本机 WSL 或另配 workflow
3. `unixnu bootimg`：BootShim + 固件卷 + DTB + payload → 可 `fastboot boot` 的镜像
4. 上机：fuxi 的 UniXNU 从未启动过，预计要调 CPU/GIC/串口
