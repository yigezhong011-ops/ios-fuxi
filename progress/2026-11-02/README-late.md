# 2026-11-02 深夜：GPU 名单实测结果（白 → 黑）

> 只改附加包里的 `.clients`，其余一律不动：同一份日常版载荷（`t32-bl-daily.img` 的卷）、
> 同样的 43 个启动参数、同一个内核、附加包 12,172,992 字节等长替换、卷差异 1 个区间。

## 结论表

| 名单 | 开机 | 现象 |
|---|---|---|
| `mediaserverd,SpringBoard`（日常版） | ✅ | 小部件**白色** |
| `SpringBoard,Preferences` | ✅ | **没有变化** |
| `SpringBoard,WidgetRenderer_Default` | ✅ | 小部件**白色 → 黑色** |
| 4 个客户端（含填充行） | ❌ 卡米标重启 | 内核崩 |

## 白 → 黑说明什么

- **白色** = `WidgetRenderer_Default` 拿不到 GPU 设备，小部件根本没画。
- **黑色** = 设备拿到了、渲染也开始了，但**画面到不了屏幕**。

原因是内核的 `kClientWindows` 只有渲染服务 + **2 个**客户端窗口：
`SpringBoard` 和 `WidgetRenderer_Default` 正好占满，没有第三个窗口。

内核里没有可调的开关：`sheng-gpu-*` 共 21 个
（metal、metal-opens、addon、perf、selftest、bringup、wc、coherent、pool、bank、asid、sid、zap、cmddb-version…），
**没有窗口数或客户端数相关的**。

所以"放宽客户端窗口数"是唯一挡住小部件和设置的最后一道门，已写进给作者的请求。

## 这一轮用的工具

- `addon-clients-exact.py`：名单换成**等压缩桶**的名字（零填充、不删条目）。
  `SpringBoard,Preferences` 文本 24 字节、压缩 32，正好落在原条的桶里。
- `addon-clients-trim.py`：名单变长时，从 `primelist` 删几行（着色器预载列表，删了只影响首次启动速度）
  把总长补回来。`SpringBoard,WidgetRenderer_Default` 需要删 2 行。
- `make-t32-addon-variant.sh`：从日常版镜像取出载荷卷，只替换 addon，参数与内核一字不动。

## 镜像

| 文件 | 说明 |
|---|---|
| `t32-gpu5.img` | `SpringBoard,Preferences`（无变化） |
| `t32-gpu6.img` | `SpringBoard,WidgetRenderer_Default`（**白→黑**） |
| `t32-gpu4.img` | 4 个客户端 + 填充（崩，仅留作对照） |

三个镜像都是 100,683,776 字节，与日常版一致。
