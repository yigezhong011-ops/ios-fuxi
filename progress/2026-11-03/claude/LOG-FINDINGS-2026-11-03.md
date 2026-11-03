# 2026-11-03 第一次读出 sheng 日志：GPU 结论

## 怎么读的（可重复）

- 刷机包 `E:\iOS小米13\17系261005_Mi13_OS4.0.0.32_4e0b` 里的 `firmware-update\recovery.img` 是 skkk TWRP，没有内核。直接 `fastboot boot` 拼接镜像不行（`twrp-fuxi-tempboot.img`），bootloader 会退回 boot_b。
- 可行的办法：a 槽放 `boot.img`（安卓内核）和 `recovery.img`（TWRP）。这两个 2026-11-03 已经写好，iOS 只用 b 槽。
- 读一次日志的步骤：
  1. 进 fastboot，执行 `fastboot set_active a`，再执行 `fastboot reboot recovery`；
  2. 执行 `adb shell dd if=/dev/block/by-name/userdata of=/tmp/fuxi-log.bin bs=4096 skip=58731451 count=8192`，再 `adb pull`；
  3. 回到 bootloader，执行 `fastboot set_active b`（重试次数恢复到 7），再 `fastboot reboot`。
- 解码：`read-sheng-log.py --decode <bin> --out <dir>`（脚本在 `unixnu-build/fuxi/scripts/`），看 `latest.txt` 和 `slots.txt`。
- 日志区域只保留最近一次开机。这次读到的是 gpu7 那次开机：名单里有 iconservicesagent 和 Preferences。

## 结论

1. **GPU 客户端最多 4 个槽位**：s0 是 backboardd（渲染服务），s1 到 s3 是名单里排在前面的 3 个进程。第 4 个（iconservicesagent）被拒，返回 `e00002d5`，即 kIOReturnBusy。名单的顺序决定谁能拿到槽位，多写的进程没有作用。
2. **小组件和文字为什么空白**：metal2vulkan 反复报同一个错，"a 2D <格式> texture over a buffer … the buffer is a no-copy buffer, and the device makes no linear image"。
   - 报错的纹理有：
     - A8Unorm 的 70x41、128x29、160x29、208x41，像是文字字形；
     - BGRA8 的 600x600 和 532x150，像是小组件或快照；
     - RG8 的 15x15。
   - 这些纹理是"直接建在 buffer 上的纹理"。t32 的插件（metal2vulkan 加 Turnip）不支持这类纹理的线性图像，所以内容出不来，表现就是小组件白或黑。
   - 这是插件本身缺功能，改启动参数或 GPU 名单都修不了。
3. 其他信息，不是主要问题：
   - QuartzCore 的 default.metallib 二进制归档无效，只影响缓存；
   - `supportsConditionalLoadStore` 没有设备应答；
   - fence 等待超时次数多：轮询 13 万次，12 万次超时。

## 下一步

- 上游 `UniXNU/AdrenoMetal` main 分支 2026-11-02 合并了 `fix/gpu-scheduling-and-metal`，内容包括：
  - Poster 改为单采样渲染；
  - 壁纸在第一帧完成后冻结；
  - 补全资源接口；
  - 同一用户的客户端共享着色器缓存。
  
  要用这些修复，必须重新编译插件（macOS：`build-turnip-darwin.py --target ios` 加 `build-adreno-metal-plugin.py`），还要确认插件和 t32 内核驱动的 user-client ABI 版本对得上。
- 也可以把上面第 2 条连同证据一起交给 ljhhkx529，或者到上游提 issue，请他们支持"在 buffer 上建线性纹理"。
