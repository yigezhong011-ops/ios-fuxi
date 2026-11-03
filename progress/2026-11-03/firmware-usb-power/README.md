# fuxi 固件：给 USB 控制器上电（内核 USB 调试串口的前提）

## 一句话

fuxi 的 UEFI 固件只加载 UFS 需要的 vendor 栈，**不给 USB 控制器上电**；
内核里的 `QcomXnuUsbDebug` 依赖"固件已准备好的 USB 状态"，
所以手机开机后主机看不到任何串口（`COM3` / `ttyACM*` 都不出现），
拿不到内核日志。这个补丁在固件里加一个 `UsbPwrEnablerDxe`，只上电，不碰显示。

## 证据链

1. `platforms/Xiaomi/fuxiPkg/fuxi.dsc` 里两个开关写明取舍：
   ```
   FUXI_VENDOR_HW = 0   # 0 = 只用 Mu 驱动，不加载任何 vendor 栈
   FUXI_UFS_STACK = 1   # 1 = 只加载 UFS 需要的 vendor 栈，without Display/USB/charger
   ```
2. `UsbPwrEnablerDxe` 在此之前**只出现在 `ginkgoPkg` 和 `willowPkg` 的 fdf** 里，
   fuxi 从来没有加载过它。
3. 内核侧确实有完整的 USB 调试栈（`QcomXnuUsbDebug`，CDC ACM），
   但它的 `acquire_vbus()` 需要控制器已上电并有 VBUS，否则不做 D+ 上拉。
4. 作者驱动文档 `xiaoleGun/QcomXnuUsbDebug/docs/boundaries.md` 明确写：
   **"固件需要完成 USB 供电、时钟和 PHY 初始化"**，
   消费者必须提供"供电、父时钟、PHY/repeater、Type-C DEVICE 路由"。

## 补丁（`0001-fuxi-usb-power.patch`）

两处改动，都在 `Platforms/Xiaomi/fuxiPkg/`：

- `fuxi.dsc`
  - 新增开关 `FUXI_USB_POWER = 1`（紧挨 `FUXI_UFS_STACK`）
  - `[Components]` 加 `NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf`
- `Include/DXE.inc`
  - 末尾加
    ```
    !if $(FUXI_USB_POWER) == 1
      INF NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf
    !endif
    ```

默认打开；想回退就 `FUXI_USB_POWER = 0`。

## 怎么构建

```sh
cd UniXNU
./unixnu build firmware -D ../<device-repo> \
  --uefi ../uefi-fuxi --target DEBUG
# 输出: <uefi>/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
```

**注意（Linux 主机）**：构建树必须放在 WSL 原生文件系统（`/root/...`），
放在 `/mnt/e`（9p）会在 `git fetch` 阶段报
`index.lock write error: Bad file descriptor`；`out/feeds` 里残留的脏 checkout
会让 `git fetch` 报 `untracked working tree files would be overwritten`，先删掉 `out/feeds` 即可。

本机构建实测：
- `SILICIUM_UEFI.fd` = **3,145,728 字节**（= `FD_SIZE 0x300000`）
- `FV/Ffs/` 里确认出现 `UsbPwrEnablerDxe` 和 `UsbPwrCtrlDxe`：

```
Build/fuxiPkg/DEBUG_CLANGPDB/FV/Ffs/a83c9d29-dbf5-49fa-b818-fbb38076d148UsbPwrEnablerDxe
Build/fuxiPkg/DEBUG_CLANGPDB/FV/Ffs/11FAED4C-B21F-4D88-8E48-C4C28A1E50DFUsbPwrCtrlDxe
```

（同时 `DXE.inc` 里本来就有 `UsbInitDxe` / `UsbConfigDxe` / `UCDxe`，
说明 USB 初始化链一直在，只是缺"上电"这一步。）

## 怎么验证

1. 用新 FD + 现有载荷打包启动镜像（`BootShim.bin` 192 B + FD 3,145,728 B + payload）。
2. **开机时 USB 线必须插着**（VBUS 要在初始化时可见）。
3. 主机上应有 CDC ACM 串口：
   - Linux: `ttyACM*`，描述符 `QcomXnuUsbDebug`
   - Windows: `USB\VID_1209&PID_316D\FUXIXNUUSBDEBUG` → `COMx`
4. 有串口后用作者的采集器读日志：
   ```sh
   python3 scripts/collect-xnu-usb.py --serial QcomXnuUsbDebug --output tmp/run/capture --wait 120
   ```
   第一行应能看到 `FUXI USB: qcom_usb_debug_init ok`。

## DEBUG 构建的额外依赖（可选）

`--target DEBUG` 会带上 `AdvancedLogDxe`（Tools 菜单里的二维码日志）。
如果所用 UniXNU 检出没有日志套件，需要先按 `ljhhkx529/unixnu-log-kit` 的
`integration/UniXNUPkg.dec.snippet` 补齐：

```
[LibraryClasses]
  AdvancedLogViewLib|Include/Library/AdvancedLogViewLib.h
[Protocols]
  gUniXNUMenuPluginProtocolGuid = { 0x1a9b2c4d, ... }
  gUniXNULogFlushProtocolGuid   = { 0x8c3f7d12, ... }
```

并把 `Uefi/Common/AdvancedLogViewLib`、`Uefi/Common/AdvancedLogDxe`、
`Uefi/Common/Include/*.h` 放进 `UniXNUPkg` 对应目录。
**只做 USB 修复的话用 RELEASE 构建即可，不需要这些。**
