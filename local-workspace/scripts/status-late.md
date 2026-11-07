
### 深夜续战（22:00–23:10）——定位到 launchd 的启动进度

**已验证的事实链**

| 观察 | 数据 |
|---|---|
| 启动是否卡住 | 两次采样相隔 4 分钟：exec **158 → 158**（不再增长），swap 99000 → 115000（只有动画在跑） |
| SpringBoard | 有时启动（432 次 exec 时出现），**0 崩溃**；但**不创建场景**，画面仍是启动 logo |
| backboardd | 正常，正在创建 1125×2436 图层（`SWEET SURF: backboardd create id 3`） |
| 崩溃循环 | `bluetoothd` / `fairplayd.H2` / `driverkitd` 每 30 秒崩一次（无基带/无 SE），launchd 反复重启 |
| 禁用这些服务 | 改 root 里的 `/System/Library/LaunchDaemons/*.plist` **无效**——它们的任务来自 **SystemOS cryptex**，不是 root |

**结论**：卡点在 **launchd 的 boot task 完成**这一环，不是 GPU/显示/资产。
`bluetoothd`/`fairplayd` 的崩溃循环很可能是让 boot task 永远等不到完成的原因，
但禁用它们必须改 **cryptex 里的 launchd.plist**（`/private/preboot/...` 或 SystemOS 卷内），root 里的 plist 改名没用。

**明天第一件事（明确、可执行）**

1. 在 SystemOS cryptex 里找到 launchd 的 job 数据库/plist：
   - `System/Library/xpc/launchd.plist`（root 与 cryptex 各有一份）
   - 作者的工具改的是 root 的那份（`launchd.plist: 7 _PanicOnCrash renamed, 2 CommCenter jobs removed`）
   - 需要在 **SystemOS.dmg 挂出来的那份**里做同样的删除：`com.apple.bluetoothd`、`com.apple.fairplayd.H2`、`com.apple.driverkitd`
2. 或者在 `mkadt.py` 里加 `-noprogress` / 抑制 boot progress 的来源
3. 若 boot task 仍不完成：用 `sweetnull` boot-arg 把 SpringBoard 的 stderr 接进内核日志
   （作者的 `--posterboard-oslog` 就是同一机制的 PosterBoard 版本），看它在等什么

**保留的产物**

- `E:\DSH-Fuxi\iosroot-iphonex.img`（16 GB，iPhone X iOS 16.7.11 + tweaks + 禁用服务）
- `E:\DSH-Fuxi\fuxi-diag.img`（17 MB，当前可启动镜像）
- `E:\DSH-Fuxi\dump\ext-new3.json`（20 段 extents，与手机上镜像对应）
- 内核 artifact：CI run 40192757492（含 0111/0112/0114）
