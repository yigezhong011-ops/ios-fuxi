
## 2026-10-26 00:10 —— 暂停点（版本对齐 + 背光线索）

### 今晚做了什么

1. **怀疑用户态版本不匹配**，重建了与作者一致的 **iOS 16.7.16 (20H392)** root
   - 从 20H392 IPSW 解出 OS/SystemOS/AppOS → `mkiosroot.sh` → 16 GB
   - 补 keybag（`install -o 272` 那步在新镜像里同样失败）+ 诊断目录
   - `sweet-root-tweaks.py` 全部应用 ✓
   - 已推送到手机 `/data/fuxi/iosroot.img`，extents 在
     `C:\Users\USER\Desktop\小米13\ext1616.json`（22 段）

2. **发现新的关键线索：背光服务没有发布**
   - 日志：`IOK backboardd: matching IOPropertyMatch backlight-control -> 0 found`
   - `0109-fuxi-backlight.patch` 里的 `FuxiBacklight` 服务是**按需发布**的：
     `PE_parse_boot_argn("fuxibacklight", ...)`，opt-in 才注册
   - 我们的 cmdline 一直缺 `fuxibacklight=1`
   - 已加进 cmdline 并重新打包（`E:\DSH-Fuxi\fuxi-diag.img`，23:52）
   - **这一版还没刷**，是明天第一件事

### 明天第一件事（明确）

    fastboot boot E:\DSH-Fuxi\fuxi-diag.img     # 含 fuxibacklight=1
    # 挂监控：
    usbipd attach --wsl --busid 1-2
    python3 tools/fuxi-xnu-monitor.py --kernel ... --payload ... \
        --out /root/fuxi/mon38 --seconds 300 --reset-minutes 45 --framebuffer

**判定标准**：日志里应出现 `FUXI BACKLIGHT: published observation-only brightness ...`
且 `backboardd: matching ... backlight-control -> FuxiBacklight`（不再是 `0 found`）。
若成立，SpringBoard 的 UI 很可能就出来了。

### 若背光不是原因，备选顺序

1. `fuxibacklight=2`（logical power interest notifications）和 `=3`（OFF-only）
2. 检查 `backboardd` 的 IODisplay/IOMobileFramebuffer 匹配是否齐全
3. 用 `sweetnull` boot-arg 把 SpringBoard 的 stderr 接进内核日志，看它卡在哪个等待

### 当前文件状态

| 文件 | 说明 |
|---|---|
| `E:\DSH-Fuxi\fuxi-diag.img` | **待刷**：20H392 + fuxibacklight=1（23:52） |
| `E:\DSH-Fuxi\iosroot-1616.img` | 20H392 root 备份（16 GB） |
| `C:\Users\USER\Desktop\小米13\ext1616.json` | 手机上官镜像的 22 段 extents（沙箱策略变化后放在工作区） |
| `E:\DSH-Fuxi\STATUS.md` | 全部历史与根因 |
| 内核 artifact | CI run 40192757492（0111 zap + 0112 kick + 0114 cpu-copy） |

### 注意

- 沙箱策略今晚在 `workspace-write` 与 `danger-full-access` 之间切换过：
  - `workspace-write` 下 **WSL 无法访问 E:**（E_ACCESSDENIED），构建链全断
  - 需要在 `danger-full-access` 下跑 WSL 构建
- USB 监控设备（`1209:0001`）的 WSL 依附经常掉，`usbipd attach --wsl --busid 1-2` 重挂即可；
  重挂前先确认 WSL 在运行（否则报 "There is no WSL 2 distribution running"）
