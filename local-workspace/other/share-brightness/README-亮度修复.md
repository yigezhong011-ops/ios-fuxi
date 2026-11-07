# 小米 13（fuxi）亮度修复：ShengBacklight 改走 DSI

结论先说：没有用现成的库。做法是保留 t32 里 sheng 的 `ShengBacklight` 服务不动（系统侧都靠它），只把它往面板写亮度的方式从 I2C 换成 DSI 命令。写法参考了 houji（SM8650）的 `HoujiBacklightProtocol.h`，它的 DSI0 地址和 fuxi 一样。

已在 fuxi 真机上验证：
- t32 上：t32-bl1，359 次亮度请求，359 次 DCS 写入，0 次失败；
- t36 上：t36-bl2，iPhone 14 Pro 布局，亮度条可用。

## 1. 为什么 `sheng-backlight=1` 直接开会崩

- `ShengBacklight` 是给 sheng 写的。sheng 的背光芯片是 KTZ8866，挂在 I2C（GENI 引擎）上。`sheng_backlight_start()` 会映射 GCC 和两个 GENI 引擎，再通过 I2C 写背光芯片。
- fuxi 的屏幕是 `xiaomi m3 38 0c 0a sec cmd mode dsc dsi panel`，挂在 `mdss_dsi_ctrl0@ae94000` 上，没有单独的背光芯片，亮度直接用 DSI DCS 命令设置。
- fuxi 原厂 DT 里 `i2c@a84000` 是 disabled 的，去碰它很可能就是 `sheng-backlight=1` 开机崩溃的原因。

## 2. 面板这边

- 亮度命令是 DCS `set_display_brightness`（0x51），参数高字节在前，原厂 DT 里写的是 `51 07 ff`。
- 普通模式最大值 `0x7ff`，`0x0fff` 是 HBM。
- `ShengBacklight` 对外的范围正好是 0..2047（`IODisplayParameters`），所以不用换算，直接下发即可。
- 我们把下限钳在 8，避免完全熄屏。

## 3. DSI 怎么发一条命令（TPG 命令 DMA FIFO）

寄存器名来自 Qualcomm `dsi_ctrl_hw_cmn`，DSI0 基址为 `0xae94000`：

| 寄存器 | 偏移 |
| --- | --- |
| DSI_CTRL | 0x04 |
| DSI_STATUS | 0x08 |
| DMA_CTRL | 0x3c |
| DMA_LEN | 0x4c |
| DMA_TRIGGER | 0x90 |
| INT_CTRL | 0x110 |
| TPG_CTRL | 0x15c |
| TPG_FIFO | 0x17c |
| TPG_FIFO_RESET | 0x1ec |
| DMA_SCHEDULE | 0x390 |

一次发送的步骤：

1. 检查发送条件，不满足就放弃这次发送：
   - `DSI_CTRL & 5 == 5`，即控制器已开启、处于命令模式；
   - `DSI_STATUS bit1 == 0`，即命令 DMA 空闲；
   - `TPG_CTRL == 0`，即 FIFO 没有被别人占用；
   - `INT_CTRL` 没有错误位（bit24）。
2. 保存 `DMA_CTRL`、`DMA_SCHEDULE`、`DMA_LEN` 三个寄存器的原值。
3. 清中断状态。`INT_CTRL` 里混着写 1 清零的状态位和使能位，只有 `0x55115501` 这些位是状态位。
4. 写入 `TPG_CTRL = 0x30006`。
5. 往 `TPG_FIFO` 写入两个字（FIFO 按两个字一组收）：
   - 头字：`flags<<24 | type<<16 | 字节数`。长包为 `0xc0390003`，含义是 last、长写 0x39、3 个字节。
   - 数据：`51 hi lo`，不足的部分用 0xff 补齐，例如 `0xff000051 | lo<<16 | hi<<8`。
6. 依次写：
   - `DMA_CTRL = (原值 & 0x2bffffff) | 0x10000000`
   - `DMA_SCHEDULE &= ~2`
   - `DMA_LEN = 8`
   - `DMA_TRIGGER = 1`
7. 轮询 `INT_CTRL`，最多约 50 ms：bit0 置位表示 DMA 完成，bit24 置位表示出错。
8. 无论成功还是失败，都要恢复原状，否则显示流会一直停在 TPG 上：
   - 清中断；
   - `TPG_CTRL = 0`；
   - `TPG_FIFO_RESET` 先写 1 再写 0；
   - 写回第 2 步保存的三个寄存器。

## 4. 接到 ShengBacklight 上（二进制补丁做法）

我们没有源码，所以是在 t32 和 t36 内核里打补丁。内核尾部 `__hib_text` 后面有一段空白区域，补丁把编好的代码放在那里，然后改下面这几处：

| 位置 | 原来 | 改成 |
| --- | --- | --- |
| `sheng_backlight_start` | 映射 GCC 和两个 GENI | `b bl_start`：`ml_io_map(0xae94000, 0x1000)` 存进原来 `gGcc.map` 的那个全局变量，然后照原样创建服务（`alloc` → `init` → `attach(getPlatform())` → `startBacklight`） |
| `ShengBacklight::kick(engine)` | 往 I2C 引擎写 | `b bl_kick`：只处理 engine 0，读出目标亮度（对象 +0x184），钳到 8..2047 后用上面的方法发 0x51，再写回已写入的值（+0xd4） |
| `ShengBacklight::attachFired` | 挂 GENI 中断 | `ret`，因为没有 GENI 中断要挂 |
| `startBacklight+0x188`、`+0x1e4` | `bl geni_i2c_prepare` | `mov w0,#-1`，让两个引擎报告"不可用" |
| `startBacklight+0x218` | `tbz w8,#0,失败返回` | `nop`，这样服务会立刻发布 |

注意：
- `kick` 在第一次 publish 之前就会被调用一次。那时不要写面板，以免改动开机时的亮度。判断依据是对象 +0x1a1 这个"已发布"标志。
- 开机参数还是 `sheng-backlight=1`。

完整代码见同目录的 `fuxi-buttons-blob.c`（`#ifdef BACKLIGHT` 那一段）。打补丁的脚本是 `patch-t32-buttons.py`，它按符号名找位置，每一处都会先核对原来的指令，对不上就拒绝打补丁。同一套补丁在 t32 和 t36 内核上都能直接用。

## 5. 改进源码时的建议（给有源码的你）

在 sheng 的 `AppleARMBacklight.cpp` / `ShengBacklight` 里加一个板级传输选项，比如 `fuxi-backlight=dsi`：

- `sheng_backlight_start()`：fuxi 上不映射 GCC 和 GENI，只映射 DSI0；
- 把 `kick()` 里写 KTZ8866 的那部分换成上面的 `dsi_brightness(level)`；
- fuxi 上不挂 GENI 中断，引擎直接标记为不可用后发布。

这样就不需要二进制补丁了，以后每个版本都会自带亮度。

## 6. 顺带：按键

t36 的 `fuxi-buttons=1`（中断方式）在我们这台机器上没有按键事件。我们用的是 PMIC 轮询，代码在同一个 `fuxi-buttons-blob.c` 里，没有包在 `#ifdef BACKLIGHT` 中：
- 开机约 60 秒后开始工作，因为一开机就轮询会卡在苹果标志；
- 通过 SPMI v7 每 20 ms 读一次 PMIC，读到的状态作为 NativeHidInput 的 report 2 上报（Power、Vol+、Vol-）；
- 接在 `native_buttons_set_sink` 上。

t36-bl2 用的就是这套，电源键、音量键都有反应。音量条不出来是因为没有音频设备，和按键本身无关。
