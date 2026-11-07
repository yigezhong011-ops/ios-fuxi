
## 2026-10-25 14:40 —— UniXNU 构建闯关记录（结论：需要 format 2 迁移）

### 五次构建，四道门，逐层暴露

| # | run | 失败原因 | 处理 |
|---|---|---|---|
| 1 | 40160775459 | `Boot progress requires the audited UFS/owner-root, Virtio and source-corecrypto build` | pre_build 关掉 CONFIG_XNU_BOOT_PROGRESS |
| 2 | 40161764780 | pre_build 的 sed 路径带字面引号 -> No such file | 去掉引号 |
| 3 | 40162428107 | sed 改了设备仓库，但配置已在更早步骤生成到 out/fuxi/.config | pre_build 里改完再跑 ./unixnu defconfig |
| 4 | 40163598716 | test -f "$CRYPTO_ARCHIVE" failed（缺 corecrypto 归档） | 关掉 CONFIG_XNU_SOURCE_CORECRYPTO14 |
| 5 | 40164270409 | `ArmCpu bring-up requires the real source provider and a real platform driver` | **循环依赖**：ArmCpu 依赖 source crypto，而 source crypto 的归档步骤没跑出来 |

### 根因

`hanzi123-bilp/unixnu-fuxi` 的 `configs/fuxi_defconfig` 是几天前的旧结构（"Stage 2a: console only"），
跟不上 UniXNU main 的组件依赖图。逐个关开关会掉进循环依赖，**只能按 format 2 迁移**
（即 unixnu.com/zh/porting/migration 那份文档）。

### macOS workflow 的正确用法（已摸清）

- 输入：device_repository、defconfig、steps、xcode=26.6、ipsw_url、pre_build
- pre_build 在 UniXNU 工作区执行，$DEVICE_DIR 指向设备仓库
- macOS 的 sed 需要 -i ''；路径不要加引号（JSON 转义会引入字面量）
- **官方只上传文本日志**，内核/payload 一律不传（"derive from Apple software"）

### 明天的工作顺序

1. **迁移 unixnu-fuxi 到 format 2**：参照 UniXNU-sm8550-common + profiles/arch/arm64/profile.toml，
   把组件声明成 include = ["ArmDTPlatform","ArmCpu",...] 而不是手写 archives
2. 用私有仓库跑构建并导出产物（公开仓库不宜分发 Apple 衍生文件）
3. 准备设备输入：unique chip id、trust cache（从 iPadOS 17.7.11 IPSW 提取）、Data seed
4. 打 boot.img（DarwinBoot + DTB + payload），用已验证可显示的 Mu-fuxi UEFI 启动

### iOS 线（今天上午）的成果仍然成立

- 显示链路打通（CTL0 START kick + cache flush）
- 卡点：CA 不渲染（缺 IOAcceleratorES，GPU zap=0xf07 自检失败）
- 镜像：E:\DSH-Fuxi\dump\iosroot-metal.img
