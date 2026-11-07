
## 2026-10-25 17:50 —— 大佬线索：xnuloader（hackios 自研 EFI 加载器）

### 大佬（Acacius）原话

> 我没有用 unixnu，我用的是 **xnuloader**
> 你 **ufs 修了吗**
> 目前没有 unixnu 在小米 13 上正常启动到用户态的先例，得你自己查查看
> 可以问问 **BAIZI_R980**

### 已确认：xnuloader 就在 `oosexgang/hackios-xnu-kernel` 仓库里

    xnuloader/
      build.sh          freestanding AArch64 UEFI 应用（clang --target=aarch64-unknown-windows + lld-link）
      loader.c          150 KB，/base:0xA1000000
      mkpayload.py      生成 "XNUP" 容器：magic XNUP + 若干 name/size/data 条目（kernel、adt、cmdline…）
      identity.h / mkidentity.py   设备身份

与 UniXNU 的差异：

| | UniXNU | hackios / xnuloader |
|---|---|---|
| 内核来源 | 源码编译 XNU（预链接） | Apple 的 kernelcache（xnu-8796.121.2 / iOS 16.5） |
| 加载方式 | UEFI 菜单 → UniXNURamDiskDxe → FAT 卷 → DarwinBoot | xnuloader 直接读 XNUP payload |
| 用户态 | iPadOS 17.7.11 IPSW | iOS 16.5 IPSW + APFS 镜像 |
| 实机进度 | fuxi 无先例 | redwood（POCO X5 Pro）到桌面 |
| UI 渲染 | 依赖 GPU/Mesa | **Adreno + Mesa/freedreno（OpenGL ES 供 CoreAnimation）** |

### 对 fuxi 的意义

1. **xnuloader 不是公开独立项目**，随 hackios 仓库发布；它面向 redwood，loader.c 内含设备相关逻辑，
   直接搬到 fuxi 需要改内存图/UART/显示等。
2. hackios 能让 iOS 界面真正渲染起来，靠的是 **Adreno + Mesa (freedreno) 给 CoreAnimation 提供 GLES**。
   这与我们 iOS 线（bangprovn）卡在 “CA 不渲染、backboardd 找不到 IOAcceleratorES” 是同一件事。
3. 所以两条线的**最终瓶颈都是 GPU 栈**：
   - iOS 线：需要 FuxiMetal/Turnip（metal lane）真正工作
   - hackios 线：需要 Adreno 740 的 freedreno/Mesa 驱动

### 当前 UniXNU 线的状态（今天推到的最远处）

- 内核 49 MB、payload 192 MB、固件 3 MB、boot.img 193 MB：**全部构建成功**
- UniXNU 固件能启动并显示菜单（调试版还能输出完整 SEC/DXE 日志）
- **卡在 `no boot entry found`**：固件找不到 payload FAT 卷
  - 已排除：payload 结构（FUXIESP + EFI/UniXNU/unixnu.toml 正确）
  - 已排除：固件缺驱动（官方 UniXNURamDiskDxe + Fat + DiskIoDxe 已在 FV 中）
  - 已知：ABL 把 kernel 放在 0xA7000000 的 4 MB 窗口（xbl_config_a: 0xA7000000,0x400000,"UEFI FD"）
  - 已做：shim 现在保留 x0；SEC 改成扫描 0xA7000000 窗口找 DTB 魔数；DTB 里写了
    `/chosen/linux,initrd-start=0xA8000000`、`end=0xB4000000`
  - **待验证**：SEC 是否真的找到追加的 DTB、驱动是否发布成功（需要串口或 halt 版固件再拍一次）

### 明天/下一步建议

1. 问 BAIZI_R980：
   - xnuloader 是否有公开仓库/文档？
   - 他在小米 13 上的 ADT、内存图、UART 是怎么来的？
   - “ufs 修了”具体指什么（UniXNU 的 ShengUfs 移植？还是 APFS 分区挂载？）
2. 继续 UniXNU 线：用 halt 版固件确认 SEC 的 `SEC: appended DT found at 0x...` 打印
3. 或者回到 iOS 线（bangprovn）：那条线已经能到 SpringBoard，只差 GPU 加速器；
   参考 hackios 的 Adreno+Mesa 方案
