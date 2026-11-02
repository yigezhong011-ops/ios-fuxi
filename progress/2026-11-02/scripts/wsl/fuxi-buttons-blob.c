/*
 * Power and volume buttons for the t32 kernel, injected into a code cave (patch-t32-buttons.py).
 *
 * t32's native_buttons_set_sink is a bare `ret`, so NativeHidInput::start hands its button sink to nothing. This blob takes its
 * place: it keeps the sink and starts a kernel thread that polls the PMIC every 20 ms and reports changes. The logic and register
 * facts are sheng's package/ButtonProbe.cpp and BootResetCore.h (UniXNU-sheng), which fuxi shares exactly (stock fuxi DT):
 *   power       PMK8550 PON  (SPMI SID 0, peripheral 0x13 -> ppid 0x013) RT_STS bit 7 (pwrkey)
 *   volume down same PON RESIN                                            RT_STS bit 6
 *   volume up   PM8550 GPIO 6 (SID 1, peripheral 0x8d -> ppid 0x18d)      RT_STS bit 0, active low
 * Only reads: no interrupt is armed and no PMIC register is written (sheng arms both edges and takes SPI 481; polling avoids that).
 * Report bits as NativeHidInput's report 2: 1 Power, 2 Volume Increment, 3 Volume Decrement.
 *
 * Freestanding, no writable data (it runs from the kernel's read-only text): state lives in IOMallocZero memory and on the stack.
 * Kernel functions are called at the addresses the patcher passes in (-D...).
 */
#include <stdint.h>

typedef void (*sink_fn)(void *, uint32_t);
typedef uint64_t (*ml_io_map_fn)(uint64_t phys, uint64_t size);
typedef void (*iosleep_fn)(uint32_t ms);
typedef void *(*iomalloczero_fn)(uint64_t size);
typedef int (*kts_fn)(void (*fn)(void *, int), void *param, void **thread);
typedef void (*tdealloc_fn)(void *thread);

#define ML_IO_MAP    ((ml_io_map_fn)ADDR_ML_IO_MAP)
#define IOSLEEP      ((iosleep_fn)ADDR_IOSLEEP)
#define IOMALLOCZERO ((iomalloczero_fn)ADDR_IOMALLOCZERO)
#define KTS          ((kts_fn)ADDR_KERNEL_THREAD_START)
#define TDEALLOC     ((tdealloc_fn)ADDR_THREAD_DEALLOCATE)

enum {
  CORE = 0xc400000, CNFG = 0xc42d000, OBSRVR = 0xc440000,
  APID_MAP = 0x2000, OBS_APID_STRIDE = 0x20, CMD = 0x00, STATUS = 0x08, RDATA0 = 0x18,
  PON_PPID = 0x013, GPIO_PPID = 0x18d, RT_STS = 0x10,
  POWER_BIT = 1u << 7, RESIN_BIT = 1u << 6, GPIO_BIT = 1u << 0,
  REPORT_POWER = 1u << 1, REPORT_VOLUME_UP = 1u << 2, REPORT_VOLUME_DOWN = 1u << 3,
};

struct state {
  sink_fn sink;
  void *context;
};

#if defined(DIAG_ROW) || defined(BL_DIAG_ROW)
/* Diagnostics on the live diagnostic page: the "CPU" row draws native_cpufreq_row (char[120]) while native_cpufreq_stage is
 * nonzero; booted with sheng-cpufreq=0 nothing else writes them. ADDR_DIAG_ROW / ADDR_DIAG_STAGE come from the patcher.
 * DIAG_ROW gives the row to the buttons, BL_DIAG_ROW to the backlight; one at a time. */
#define DIAG_ROW_BUF   ((volatile char *)ADDR_DIAG_ROW)
#define DIAG_ROW_STAGE ((volatile uint32_t *)ADDR_DIAG_STAGE)
static char *put_str(char *p, char *end, const char *s)
{
  while (*s && p < end)
    *p++ = *s++;
  return p;
}
static char *put_hex(char *p, char *end, uint32_t v)
{
  int started = 0;
  for (int sh = 28; sh >= 0; sh -= 4) {
    uint32_t d = (v >> sh) & 0xf;
    if (!d && !started && sh)
      continue;
    started = 1;
    if (p < end)
      *p++ = (char)(d < 10 ? '0' + d : 'a' + d - 10);
  }
  return p;
}
#endif

#ifdef DIAG_ROW
/* NativeHidInput's own counters (HidInputProbe.cpp native_hid_input_observed): event 2 = start done, 3 = a tick that found no
 * IOHIDEventDriver below the device, 4 = buttonsAction called handleReport (results[4] its IOReturn). */
#define HID_EVENTS  ((const volatile uint32_t *)ADDR_HID_EVENTS)
#define HID_RESULTS ((const volatile int32_t *)ADDR_HID_RESULTS)
#define HID_OBJECT  ((const volatile uint64_t *)ADDR_HID_OBJECT)
/* "BTN s<stage> a<apids> p<pon apid> g<gpio apid> r<PON RT_STS> u<GPIO RT_STS> m<mask> n<reports> e<HID +0xe4> x<HID +0xe1>
 *  o<start events> d<no-driver ticks> k<button handleReports> q<last handleReport result> c<1: sink context is the probe's HID object>" */
static void diag_full(uint32_t stage, uint32_t version, uint32_t apids, int pon, int gpio, uint32_t rpon, uint32_t rgpio,
                      uint32_t mask, uint32_t reports, const volatile uint8_t *hid)
{
  char line[120];
  char *p = line, *end = line + sizeof line - 1;
  static const char *const names[] = {" s", " a", " p", " g", " r", " u", " m", " n", " e", " x", " o", " d", " k", " q", " c"};
  (void)version;
  uint32_t vals[] = {stage, apids, (uint32_t)pon, (uint32_t)gpio, rpon, rgpio, mask, reports,
                     hid ? hid[0xe4] : 0xff, hid ? hid[0xe1] : 0xff,
                     HID_EVENTS[2], HID_EVENTS[3], HID_EVENTS[4], (uint32_t)HID_RESULTS[4],
                     hid ? (uint32_t)(*HID_OBJECT == (uint64_t)(uintptr_t)hid) : 2};
  p = put_str(p, end, "BTN");
  for (int i = 0; i < 15; ++i) {
    p = put_str(p, end, names[i]);
    p = put_hex(p, end, vals[i]);
  }
  *p++ = 0;
  for (int i = 0; i < p - line; ++i)
    DIAG_ROW_BUF[i] = line[i];
  *DIAG_ROW_STAGE = 1;
}
#define diag(st, v, a, p, g, r, u, m, n) diag_full(st, v, a, p, g, r, u, m, n, 0)
#else
/* No diagnostic row: a no-op that still takes the values, so the poller's bookkeeping compiles the same in both builds. */
static inline void diag_full(uint32_t stage, uint32_t version, uint32_t apids, int pon, int gpio, uint32_t rpon, uint32_t rgpio,
                             uint32_t mask, uint32_t reports, const volatile uint8_t *hid)
{
  (void)stage, (void)version, (void)apids, (void)pon, (void)gpio, (void)rpon, (void)rgpio, (void)mask, (void)reports, (void)hid;
}
#define diag(st, v, a, p, g, r, u, m, n) diag_full(st, v, a, p, g, r, u, m, n, 0)
#endif

static void poll_thread(void *param, int wait_result);

/* First byte of the blob: native_buttons_set_sink branches here with the same arguments. */
__attribute__((section(".text.a_entry"), used))
void buttons_set_sink(sink_fn sink, void *context)
{
  diag(sink ? 0x10 : 0x11, 0, 0, -1, -1, 0, 0, 0, 0);   /* s10: set_sink called with a sink, s11: called with NULL */
  if (!sink)        /* NativeHidInput::stop: keep polling; the HID service is not stopped before shutdown */
    return;
  struct state *s = IOMALLOCZERO(sizeof *s);
  if (!s)
    return;
  s->sink = sink;
  s->context = context;
  void *thread = 0;
  if (KTS(poll_thread, s, &thread) == 0)
    TDEALLOC(thread);
}

/* The APID serving ppid: the first mapping, replaced by one execution environment 0 owns (as the mainline driver picks it). */
static int find_apid(volatile uint32_t *core, volatile uint32_t *cnfg, uint32_t apids, uint32_t ppid)
{
  int found = -1;
  for (uint32_t i = 0; i < apids; ++i) {
    uint32_t map = core[(APID_MAP + 4 * i) / 4];
    if (!map || ((map >> 8) & 0xfff) != ppid)
      continue;
    if (found < 0 || (cnfg[i] & 7u) == 0)
      found = (int)i;
  }
  return found;
}

/* One register byte through EE 0's observer channel; 0 on success. */
static int read8(volatile uint32_t *obs, int apid, uint8_t addr, uint8_t *value)
{
  volatile uint32_t *ch = obs + (OBS_APID_STRIDE * (uint32_t)apid) / 4;
  ch[CMD / 4] = (1u << 27) | ((uint32_t)addr << 4);
  for (unsigned n = 0; n < 100000; ++n) {
    uint32_t st = ch[STATUS / 4];
    if (st & 1u) {
      if (st & 0xeu)
        return 2;
      *value = (uint8_t)ch[RDATA0 / 4];
      return 0;
    }
  }
  return 1;
}

/* A synthetic press of the given report bits, for the self-test below (seen as the volume HUD). */
__attribute__((unused)) static void tap(struct state *s, uint32_t mask, unsigned times)
{
  for (unsigned i = 0; i < times; ++i) {
    s->sink(s->context, mask);
    IOSLEEP(150);
    s->sink(s->context, 0);
    IOSLEEP(400);
  }
}

static void poll_thread(void *param, int wait_result)
{
  (void)wait_result;
  struct state *s = param;
  diag(0x20, 0, 0, -1, -1, 0, 0, 0, 0);                    /* s20: the thread runs */
  /* Stay off the SPMI arbiter until boot has settled: every build that reached the desktop waited here 60 s (for the self-test),
   * while t32-buttons-daily, which mapped and polled at once, stopped at the Apple logo. */
  IOSLEEP(60000);
#ifdef SELF_TEST
  /* Self-test, readable on screen once SpringBoard is up: one volume-up step = this thread runs and its sink reaches iOS;
   * then one volume-down step = the arbiter and the PON APID were found, or N more volume-up steps = setup failed at step N. */
  tap(s, REPORT_VOLUME_UP, 1);
  IOSLEEP(1500);
#endif
  int fail = 0;
  volatile uint32_t *core = (volatile uint32_t *)ML_IO_MAP(CORE, 0x3000);
  volatile uint32_t *cnfg = (volatile uint32_t *)ML_IO_MAP(CNFG, 0x4000);
  volatile uint32_t *obs = (volatile uint32_t *)ML_IO_MAP(OBSRVR, 0x8000);
  uint32_t version = 0, apids = 0;
  int pon = -1, gpio = -1;
  if (!core || !cnfg || !obs) {
    fail = 1;
  } else {
    version = core[0];
    apids = core[1] & 0x7ffu;
    if (version < 0x70000000u || version >= 0x80000000u || !apids || apids > 1024)
      fail = 2;
  }
  if (!fail) {
    pon = find_apid(core, cnfg, apids, PON_PPID);
    gpio = find_apid(core, cnfg, apids, GPIO_PPID);
    if (pon < 0)
      fail = 3;
  }
  diag(fail ? 0x30 + (uint32_t)fail : 0x40, version, apids, pon, gpio, 0, 0, 0, 0);   /* s31..s33 failed step, s40 ready */
#ifdef SELF_TEST
  if (fail)
    tap(s, REPORT_VOLUME_UP, (unsigned)fail);
  else
    tap(s, REPORT_VOLUME_DOWN, 1);
#endif
  if (fail)
    return;
  uint32_t reports = 0, rounds = 0;
  uint32_t last = 0;
  for (;;) {
    uint32_t mask = 0, rpon = 0x100, rgpio = 0x100;     /* 0x100 = read failed */
    uint8_t v = 0;
    if (!read8(obs, pon, RT_STS, &v)) {
      rpon = v;
      if (v & POWER_BIT) mask |= REPORT_POWER;
      if (v & RESIN_BIT) mask |= REPORT_VOLUME_DOWN;
    }
    v = 0xff;
    if (gpio >= 0 && !read8(obs, gpio, RT_STS, &v)) {
      rgpio = v;
      if (!(v & GPIO_BIT))
        mask |= REPORT_VOLUME_UP;
    }
    if (mask != last) {
      last = mask;
      s->sink(s->context, mask);
      ++reports;
    }
    if ((++rounds & 7) == 0)                            /* every ~160 ms */
      diag_full(0x50, version, apids, pon, gpio, rpon, rgpio, mask, reports, (const volatile uint8_t *)s->context);
    IOSLEEP(20);
  }
}

#ifdef BACKLIGHT
/*
 * Panel brightness through t32's ShengBacklight service (sheng-backlight=1), with its transport moved from sheng's KTZ8866 I2C
 * engines to the fuxi panel's DSI link. ShengBacklight keeps everything on the OS side: the AppleARMBacklight impersonation that
 * CoreBrightness looks for, backboardd's sandbox grant, IODisplayParameters 0..2047, FadePeriod fades on its work loop. The
 * patcher replaces three things (patch-t32-buttons.py, BACKLIGHT=1):
 *   sheng_backlight_start  -> bl_start: map DSI0 instead of the GCC and the two GENI engines (fuxi's i2c@a84000 is disabled, and
 *                             touching it is the likely panic of the plain sheng-backlight=1 boot), then create the service as before
 *   ShengBacklight::kick   -> bl_kick: each new level becomes one DCS set_display_brightness (0x51, high byte first)
 *   ShengBacklight::attachFired -> ret: no GENI interrupts to attach
 * and startBacklight's two geni_i2c_prepare calls report failure, so both engines are "started, not usable" and the service
 * publishes at once (begin -> publishFirst).
 * fuxi panel (stock DT, "xiaomi m3 38 0c 0a sec cmd mode dsc dsi panel" on mdss_dsi_ctrl0@ae94000): 51 07 ff is the normal
 * maximum (hbm-off), 51 0f ff HBM, so ShengBacklight's 0..2047 is the panel's normal range as it is.
 * DSI command: one long write through the controller's TPG command-DMA FIFO, as houji (SM8650, same DSI0 address) does in
 * HoujiBacklightProtocol.h; register names from Qualcomm dsi_ctrl_hw_cmn.
 * native_backlight_stats as used here: [0]/[1]/[3]/[4] ShengBacklight's own (stage, requests, engine reads), [2] last level sent,
 * [5] failed sends, [9] last failure (1 not command mode, 2 DMA busy, 3 TPG in use, 4 DSI error before, 5 error after, 6 timeout),
 * [12] bl stage (10 mapped, -11 map failed, -12 alloc, -13 init/attach/start, -20 stopped after an uncertain transfer),
 * [13] DSI_CTRL at start, [14] sends done, [15] INT_CTRL after the last send.
 */
typedef void (*iodelay_fn)(uint32_t us);
typedef void *(*getplatform_fn)(void);
typedef int (*startbl_fn)(void *self, const uint8_t *usable);
#define IODELAY      ((iodelay_fn)ADDR_IODELAY)
#define GETPLATFORM  ((getplatform_fn)ADDR_GETPLATFORM)
#define START_BL     ((startbl_fn)ADDR_START_BACKLIGHT)
#define BL_STATS     ((volatile int32_t *)ADDR_BL_STATS)
#define DSI_SLOT     ((volatile uint64_t *)ADDR_DSI_SLOT)   /* gGcc.map of AppleARMBacklight.cpp: unused once bl_start replaces it */
#define BL_META      ((void *)ADDR_BL_METACLASS)

enum {
  DSI0 = 0xae94000, DSI_CTRL = 0x04, DSI_STATUS = 0x08, DSI_DMA_CTRL = 0x3c, DSI_DMA_LEN = 0x4c, DSI_DMA_TRIGGER = 0x90,
  DSI_INT_CTRL = 0x110, DSI_TPG_CTRL = 0x15c, DSI_TPG_FIFO = 0x17c, DSI_TPG_FIFO_RESET = 0x1ec, DSI_DMA_SCHEDULE = 0x390,
  DSI_INT_ERROR = 1u << 24, DSI_INT_DMA_DONE = 1u << 0,
  PANEL_MAX = 2047, PANEL_MIN = 8,
  /* ShengBacklight layout (t32 disassembly): target level, engine 0's written level, published flag */
  SB_TARGET = 0x184, SB_WRITTEN0 = 0xd4, SB_PUBLISHED = 0x1a1,
};
/* DSI_INT_CTRL mixes W1C status bits with enables; only these are status (houji's mask, MiCode's controller). */
#define DSI_STATUS_BITS 0x55115501u

typedef uint64_t (*vfn)(void *, void *);   /* every virtual called here takes this plus at most one pointer */
static vfn vcall(void *obj, unsigned offset) { return *(vfn *)(*(uint8_t **)obj + offset); }

static uint32_t dr(uint64_t base, unsigned reg) { return *(volatile uint32_t *)(base + reg); }
static void dw(uint64_t base, unsigned reg, uint32_t value)
{
  __asm__ volatile("dmb oshst" ::: "memory");
  *(volatile uint32_t *)(base + reg) = value;
  __asm__ volatile("dsb osh" ::: "memory");
}

#ifdef BL_DIAG_ROW
/* "BL g<bl stage> s<sheng stage> q<requests> t<target> l<last level> k<sends> f<failures> e<last failure> c<DSI_CTRL> i<INT_CTRL>" */
static void bl_diag(uint32_t target)
{
  char line[120];
  char *p = line, *end = line + sizeof line - 1;
  static const char *const names[] = {" g", " s", " q", " t", " l", " k", " f", " e", " c", " i"};
  uint32_t vals[] = {(uint32_t)BL_STATS[12], (uint32_t)BL_STATS[0], (uint32_t)BL_STATS[1], target, (uint32_t)BL_STATS[2],
                     (uint32_t)BL_STATS[14], (uint32_t)BL_STATS[5], (uint32_t)BL_STATS[9], (uint32_t)BL_STATS[13],
                     (uint32_t)BL_STATS[15]};
  p = put_str(p, end, "BL");
  for (int i = 0; i < 10; ++i) {
    p = put_str(p, end, names[i]);
    p = put_hex(p, end, vals[i]);
  }
  *p++ = 0;
  for (int i = 0; i < p - line; ++i)
    DIAG_ROW_BUF[i] = line[i];
  *DIAG_ROW_STAGE = 1;
}
#else
static inline void bl_diag(uint32_t target) { (void)target; }
#endif

/* One DCS long write 51 <hi> <lo>; 0 when the panel link took it. */
static int dsi_brightness(uint64_t base, uint32_t level)
{
  if ((dr(base, DSI_CTRL) & 5u) != 5u)            /* controller enabled, command mode */
    return 1;
  if (dr(base, DSI_STATUS) & 2u)                  /* command DMA busy */
    return 2;
  if (dr(base, DSI_TPG_CTRL))                     /* the TPG FIFO belongs to someone else */
    return 3;
  if (dr(base, DSI_INT_CTRL) & DSI_INT_ERROR)
    return 4;
  uint32_t dma = dr(base, DSI_DMA_CTRL), schedule = dr(base, DSI_DMA_SCHEDULE), length = dr(base, DSI_DMA_LEN);
  dw(base, DSI_INT_CTRL, (dr(base, DSI_INT_CTRL) & ~DSI_STATUS_BITS) | DSI_INT_DMA_DONE);
  dw(base, DSI_TPG_CTRL, 0x30006);
  dw(base, DSI_TPG_FIFO, 0xc0390003u);            /* last, long packet, DCS long write (0x39), 3 bytes */
  dw(base, DSI_TPG_FIFO, 0xff000051u | ((level & 0xff) << 16) | ((level >> 8) << 8));
  dw(base, DSI_DMA_CTRL, (dma & 0x2bffffffu) | 0x10000000u);
  dw(base, DSI_DMA_SCHEDULE, schedule & ~2u);
  dw(base, DSI_DMA_LEN, 8);
  dw(base, DSI_DMA_TRIGGER, 1);
  int rc = 6;
  uint32_t status = 0;
  for (unsigned n = 0; n < 5000; ++n) {           /* up to ~50 ms */
    status = dr(base, DSI_INT_CTRL);
    if (status & DSI_INT_ERROR) { rc = 5; break; }
    if (status & DSI_INT_DMA_DONE) { rc = 0; break; }
    IODELAY(10);
  }
  /* Give the FIFO and the DMA settings back as they were, also after a failure, so the display stream is not left on the TPG. */
  dw(base, DSI_INT_CTRL, (status & ~DSI_STATUS_BITS) | DSI_INT_DMA_DONE);
  dw(base, DSI_TPG_CTRL, 0);
  dw(base, DSI_TPG_FIFO_RESET, 1);
  dw(base, DSI_TPG_FIFO_RESET, 0);
  dw(base, DSI_DMA_CTRL, dma);
  dw(base, DSI_DMA_SCHEDULE, schedule);
  dw(base, DSI_DMA_LEN, length);
  BL_STATS[15] = (int32_t)dr(base, DSI_INT_CTRL);
  return rc;
}

/* Replaces ShengBacklight::kick(unsigned): called for engines 0 and 1 on every new level; engine 0 sends it to the panel. */
void bl_kick(void *self, uint32_t engine)
{
  uint8_t *o = self;
  if (engine || !o[SB_PUBLISHED] || BL_STATS[12] < 0)   /* begin() kicks before the first publish: leave the boot level alone */
    return;
  uint32_t target = *(volatile uint32_t *)(o + SB_TARGET);
  volatile int32_t *written = (volatile int32_t *)(o + SB_WRITTEN0);
  if (*written == (int32_t)target)
    return;
  uint32_t level = target > PANEL_MAX ? PANEL_MAX : target < PANEL_MIN ? PANEL_MIN : target;
  int rc = dsi_brightness(*DSI_SLOT, level);
  *written = (int32_t)target;
  if (rc) {
    BL_STATS[5] = BL_STATS[5] + 1;
    BL_STATS[9] = rc;
    if (rc >= 5)                                  /* an uncertain transfer: no more writes this boot */
      BL_STATS[12] = -20;
  } else {
    BL_STATS[14] = BL_STATS[14] + 1;
    BL_STATS[2] = (int32_t)level;
  }
  bl_diag(target);
}

/* Replaces sheng_backlight_start(): the service as before, on DSI0 instead of the I2C engines. */
void bl_start(void)
{
  uint64_t base = ML_IO_MAP(DSI0, 0x1000);
  if (!base) { BL_STATS[12] = -11; bl_diag(0); return; }
  *DSI_SLOT = base;
  BL_STATS[13] = (int32_t)dr(base, DSI_CTRL);
  BL_STATS[12] = 10;
  void *self = (void *)vcall(BL_META, 0x68)(BL_META, (void *)0); /* OSMetaClass::alloc */
  if (!self) { BL_STATS[12] = -12; bl_diag(0); return; }
  const uint8_t usable[2] = {1, 1};
  if (!(vcall(self, 0xa8)(self, (void *)0) & 1) ||                /* init(nullptr) */
      !(vcall(self, 0x360)(self, GETPLATFORM()) & 1) ||           /* attach(IOService::getPlatform()) */
      !(START_BL(self, usable) & 1))
    BL_STATS[12] = -13;
  vcall(self, 0x28)(self, (void *)0);                             /* release: the registry holds it */
  bl_diag(0);
}
#endif
