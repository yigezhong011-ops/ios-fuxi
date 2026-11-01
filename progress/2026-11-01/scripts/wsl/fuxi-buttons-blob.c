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

#ifdef DIAG_ROW
/* Diagnostics on the live diagnostic page: the "CPU" row draws native_cpufreq_row (char[120]) while native_cpufreq_stage is
 * nonzero; booted with sheng-cpufreq=0 nothing else writes them. ADDR_DIAG_ROW / ADDR_DIAG_STAGE come from the patcher. */
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
/* "BTN s<stage> v<version> a<apids> p<pon apid> g<gpio apid> r<PON RT_STS> u<GPIO RT_STS> m<mask> n<reports> e<HID +0xe4> x<HID +0xe1>" */
static void diag_full(uint32_t stage, uint32_t version, uint32_t apids, int pon, int gpio, uint32_t rpon, uint32_t rgpio,
                      uint32_t mask, uint32_t reports, const volatile uint8_t *hid)
{
  char line[120];
  char *p = line, *end = line + sizeof line - 1;
  static const char *const names[] = {" s", " v", " a", " p", " g", " r", " u", " m", " n", " e", " x"};
  uint32_t vals[] = {stage, version, apids, (uint32_t)pon, (uint32_t)gpio, rpon, rgpio, mask, reports,
                     hid ? hid[0xe4] : 0xff, hid ? hid[0xe1] : 0xff};
  p = put_str(p, end, "BTN");
  for (int i = 0; i < 11; ++i) {
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
#define diag(...) ((void)0)
#define diag_full(...) ((void)0)
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
static void tap(struct state *s, uint32_t mask, unsigned times)
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
#ifdef SELF_TEST
  /* Self-test, readable on screen once SpringBoard is up: one volume-up step = this thread runs and its sink reaches iOS;
   * then one volume-down step = the arbiter and the PON APID were found, or N more volume-up steps = setup failed at step N. */
  IOSLEEP(60000);
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
