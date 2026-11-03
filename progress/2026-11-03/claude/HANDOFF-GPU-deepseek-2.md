# 交接给 DeepSeek：fuxi GPU（小组件、文字空白）——2026-11-03 深夜

## 提示词（整段复制发给 DeepSeek）

你接手小米 13（fuxi，SM8550）UniXNU 移植中的 GPU 部分。环境：
- 工作目录 `E:\DSH-Fuxi`；
- WSL 用 `wsl -u root`，工作目录 `/root/fuxi`；
- fastboot 和 adb 在 `E:\DSH-Fuxi\tools\platform-tools\`。

先读本文件，再读 `E:\DSH-Fuxi\LOG-FINDINGS-2026-11-03.md`。

**目标**：编出一个新的 GPU 附加包（NativeAdrenoMetal 插件），带上上游的 bridge 补丁 0020，让小组件和文字不再空白。然后把它放进日常镜像 `t36-bl2` 的卷里，临时启动测试。

硬性规则：
- 只能用 `fastboot boot` 临时启动。刷 boot_b 前必须问用户。
- **不要用任何 iPad 身份的镜像（t32 系列）开机。** 现在 Data 里的缓存是 iPhone 身份，用 iPad 镜像开一次就会被改回 iPad，而且会黑屏。
- 不刷 userdata，不清 Data，不做永久删除，不往 C 盘写数据。
- 镜像、内核、`token2.txt`、`keys\`、芯片 ID、序列号都不能进公开仓库。不要 force push。
- 用中文和用户交流，每次只让用户做一件事。

## 0. 2026-11-03 深夜更新：日常版换成 t50-mine，并且有 USB 日志了

- **boot_b 现在是 `E:\DSH-Fuxi\t50-mine.img`**，由 `dump/wsl/make-t50-mine.sh` 生成：作者新的 t50 内核（USB 调试串口可用，自带 DSI 亮度 `fuxi-backlight=dsi`），加上我们的 PMIC 按键（REPLACE_SINK，只打按键部分，blob 0x2ac 字节），unit-scale 3，`sheng-setup=0`。它的卷在 `/root/fuxi/t50-mine/vol.img`。
- **GPU 测试请以 t50-mine 为基础。** 第 5 节里的 "t36-bl2" 都换成 t50-mine；`repack-with-vol.py` 的第一个参数用 `t50-subtype2556-nodiag.img`。t50 的 GPU 附加包和信任列表与 t36 完全相同。t50 的内核是 11-03 新编的，接口版本要重新核对：t50 的 `NativeAdrenoABI` 可能已经比 793d6bddf7 更新，打包前先比对内核里的 Adreno740 符号或版本字符串。
- **有了 USB 实时日志**：开机约 40 秒后，电脑上出现 COM3（"USB 串行设备"，VID_1209&PID_316D，115200 8N1，打开 DTR），内核和 launchd 的日志会实时输出，不用再进 TWRP 读。PowerShell 读法见 `dump/wsl/` 里的记录：`System.IO.Ports.SerialPort 'COM3'`，`DtrEnable = $true`。

## 1. 手机现状（t36-bl2 那一版，已被 t50-mine 取代）

- boot_b 是 `E:\DSH-Fuxi\t36-bl2.img`：作者的 t36（iPhone 14 Pro 布局，带灵动岛），加上我们的 PMIC 按键和 DSI 亮度补丁，开机参数有 `sheng-setup=0`。
  - 它的卷在 `/root/fuxi/t36-bl2/vol.img`，由 `dump/wsl/make-t36-bl2.sh` 生成。
- a 槽是安卓 boot 加 skkk TWRP，专门用来读日志。读法见 `HANDOFF-USB-deepseek.md` 第 4 节，脚本是 `dump/wsl/decode-log.sh`。
- userdata 里是我们自己编的 iPadOS 17.7.11 UniXNU 根卷（`ux-out/fuxi/userdata/userdata-root.img`），加上按 iPhone 身份建好的 Data。

## 2. GPU 问题的根因

- 现象：小组件黑或白、部分文字空白、设置很慢、壁纸黑。
- 日志（`LOG-FINDINGS-2026-11-03.md`）里，metal2vulkan 反复报 "a 2D … texture over a buffer … the buffer is a no-copy buffer, and the device makes no linear image"。
- 上游 AdrenoMetal 的 `bridge/patches/0020-written-host-page-textures-in-place-at-any-size.patch` 和相关补丁处理的正是这个问题。
- t36 的 GPU 附加包和 t32 的完全一样（逐字节比对过），比 0020 旧。

## 3. 选定的版本（重要）

- t36 内核编于 "Sat Oct 31 12:22:41 CST 2026"，即 10-31 04:22 UTC。
- 对应 UniXNU **`793d6bddf7`**（10-30 20:12 UTC），其中 AdrenoMetal 为 `7e0d3d2eba`（已包含 0020），Adreno740 为 `759d646eca`。
- 内核和插件之间的接口头 `NativeAdrenoABI.h` 在这个版本，和 10-31 12:36 的 `359d77c082`，sha256 前缀都是 `58d0509ae8`，所以新插件和 t36 内核的接口应当一致。
- 更新的 UniXNU（11-01 之后）里 ABI 头已经变了，**不要用**。

## 4. CI（只编插件，不编内核）

- 仓库 `yigezhong011-ops/unixnu-ci` 的 `.github/workflows/fuxi-gpu.yml`，源文件在 `E:\DSH-Fuxi\ci\fuxi-gpu.yml`；推送用 `dump/wsl/push-ci-workflow.sh`。
- 触发命令：`bash /root/fuxi/dcr.sh 793d6bddf7 false`，即 `dump/wsl/dispatch-ci-ref.sh <UniXNU 版本> <build_kernel>`。最后一次是 run **41593554989**（https://github.com/yigezhong011-ops/unixnu-ci/actions/runs/41593554989，只编插件，UniXNU 793d6bddf7），请先看它的结果：`bash /root/fuxi/crst.sh 41593554989`。
- 看状态用 `dump/wsl/ci-run-status.sh <run>`，看失败原因用 `ci-run-log.sh`、`ci-fail-context.sh`。
- 793d6bddf7 这个版本里**没有** `build-boot-runtime.py`，所以 workflow 里是手动准备的：
  1. 拉 Mesa，按 `scripts/data/adreno-compiler-inputs.json` 里的 pin 和 patches 打补丁；
  2. 拉 metal2vulkan，按 `gpu-metal-vulkan-inputs.json` 的 translator pin；
  3. 建 venv；
  4. 运行 `build-turnip-darwin.py --target ios`；
  5. 运行 `build-adreno-metal-plugin.py`；
  6. 运行 `make-gpu-addon.py --publish`。
  
  可能出问题的地方：老版本的 `build-adreno-metal-plugin.py` 会调用 `gen-turnip-replay.py`，它需要宿主机抓的 rd dump；Rust 工具链版本由 `build-adreno-metal-bridge.py` 指定。出错就按报错一项项补。
- 产物用 age 加密后上传为 artifact `fuxi-gpu-encrypted`，私钥在 `E:\DSH-Fuxi\keys\fuxi-ci-age.key`。解密：`age -d -i keys/fuxi-ci-age.key fuxi-gpu.tar.gz.age | tar xz`。里面有 `gpuaddon.bin` 和 `cdhashes.txt`（每个可执行文件的 CDHash）。
- 不要再走"编整个内核"那条路：它卡在 archive-13 NativeLegacyDisplay 的编译错误（显示 ABI 分析只有种子哈希，生成的类不完整）。同为 SM8550 的 ishtar 也卡在这里。

### run 41593554989 的结果（先看这里）

- **Turnip 已经编成功**：Mesa pin 加补丁、venv、`build-turnip-darwin.py --target ios` 都通过了。
- 失败在 `build-adreno-metal-plugin.py` 内部调用的 `gen-turnip-replay.py` 上。它又调用了 `check-turnip-darwin-host.py`，这是一个用宿主机模拟抓 Turnip 首次提交的诊断回放，在 CI 上跑不过。之后 UniXNU 给插件构建加了 `--no-replay`，build-boot-runtime.py 的注释原文是："Replay is a diagnostic capture from a host GPU simulation, not a runtime dependency"。
- **下一步**：在 workflow 的 GPU addon 步骤里，调用插件构建之前，对 793d6bddf7 的 `scripts/build-adreno-metal-plugin.py` 打一个小补丁，跳过 `gen-turnip-replay.py`，并提供它本来要生成的 `build/turnip-smoke/TurnipReplay.h`。生成方式参考较新 UniXNU（例如 `359d77c082` 或 main）里 `build-adreno-metal-plugin.py --no-replay` 的处理：它不生成回放时会写出什么样的 TurnipReplay.h（空表或宏）。照那个格式写一个 stub 即可。然后用 `bash /root/fuxi/dcr.sh 793d6bddf7 false` 重新触发。
- 看失败原因：`bash /root/fuxi/cfe.sh <run>`（前 30 行，但会先碰到 brew 的无害报错 "Failed to load cask: blacktop/tap/ipsw"），或者 `grep -n Traceback /root/fuxi/ci-job.log`。

## 5. 把新插件装进镜像

1. 新 `gpuaddon.bin` 的大小和原来的 12172992 字节不一样。payload 卷里的文件只能用 `fat-inplace.py` 原地写，`--grow` 只能在原有簇链内变长。
   - 文件变小：可以按原大小末尾补零吗？不行，NGPUADD2 头里记录了总长度。正确做法是参考 `addon-set-clients.py --same-size` 的思路，用 filler 调整到原大小，或者先删掉不需要的条目（比如 bluetoothd 的 plist）。
   - 文件变大：簇链放不下。由于用的是持久化 Data（`sheng-data-persist=2`），种子被覆盖并不致命，可以用 mtools 的 `mcopy -o` 换文件，但会改到其他簇，**风险自己评估**。最好先尽量把大小对齐。
2. 信任列表 `Payloads/kernel.macho.trustcache` 不签名。第一个模块（owner 模块）里放着插件、Turnip、adrenoprobed 的 CDHash，格式见 `unixnu-build/unixnu/scripts/make-owner-trust-bundle.py`：版本 2，每条 24 字节，按升序排列。把旧的三个哈希换成 `cdhashes.txt` 里的新值，条目数不变，文件大小也就不变，可以用 `fat-inplace.py` 原地写。
3. 用 `dump/wsl/repack-with-vol.py t36-bl2.img <新卷> <输出.img>` 重新打包，这一步保留 t36 自己的 loader 和 DTB。
4. 临时启动，看小组件、文字、设置，然后用 TWRP 读日志，确认 "no linear image" 不再出现。

## 6. 注意事项

- 我们在内核里打的补丁（按键、亮度）放在 `__hib_text` 后面的空白区，**总共不能超过 0xa23 字节**，超过就无法开机。
- GPU 客户端最多 4 个槽：backboardd 加上名单里的前 3 个。
- 新 Data 第一次开机必须带 `sheng-setup=0`，t36-bl2 已经带上了。
