#!/usr/bin/env python3
"""Patch 0115: RPMh probe in the fuxi touch driver (cmd-db lookup + RSC dump)."""
import difflib, re, subprocess, tempfile, pathlib

SRC = pathlib.Path('/root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c')
text = SRC.read_text()

# ---- insertion 1: the probe code, before ft_thread ----
probe = r'''
/*
 * RPMh probe: the GT9916's iovdd (ldob12, 1.8 V) and avdd (ldom6, 3.2 V) are
 * RPMh VRM resources. The bootloader's cmd-db names them and the APPS RSC
 * carries the command. This prints what the tables actually contain before the
 * driver tries to talk to the controller.
 */
#define FUXI_CMD_DB_PHYS	0x81c60000UL
#define FUXI_CMD_DB_SIZE	0x20000UL
#define FUXI_APPS_RSC		0x17a00000UL
#define FUXI_RSC_SLOTS		0xd00UL
#define FUXI_RSC_SLOT_SIZE	0x2a0UL

struct fuxi_db_slave { uint16_t id, header_offset, data_offset, count, version, rsv[3]; };
struct fuxi_db_header { uint32_t version; uint8_t magic[4]; struct fuxi_db_slave slave[8]; uint32_t checksum, rsv; };
struct fuxi_db_entry { char id[8]; uint32_t prio[2]; uint32_t address; uint16_t length, offset; };

static uint32_t
fuxi_rpmh_lookup(const char *name)
{
	static const struct fuxi_db_header *db;
	char id[8] = {0};

	if (db == NULL) {
		db = (const struct fuxi_db_header *)ml_io_map_wcomb(FUXI_CMD_DB_PHYS, FUXI_CMD_DB_SIZE);
	}
	if (db == NULL) {
		return 0;
	}
	if (db->magic[0] != 0xdb || db->magic[1] != 0x30 || db->magic[2] != 0x03 || db->magic[3] != 0x0c) {
		return 0;
	}
	strlcpy(id, name, sizeof(id));
	for (unsigned s = 0; s < 8; s++) {
		const struct fuxi_db_slave *slave = &db->slave[s];
		const struct fuxi_db_entry *entry;

		if (slave->id == 0 || slave->count > 512) {
			continue;
		}
		entry = (const struct fuxi_db_entry *)((const uint8_t *)(db + 1) + slave->header_offset);
		for (unsigned i = 0; i < slave->count; i++) {
			if (memcmp(entry[i].id, id, sizeof(id)) == 0) {
				return entry[i].address;
			}
		}
	}
	return 0;
}

static void
fuxi_rpmh_probe(void)
{
	volatile uint32_t *rsc = (volatile uint32_t *)ml_io_map(FUXI_APPS_RSC, 0x4000);
	uint32_t iovdd = fuxi_rpmh_lookup("ldob12");
	uint32_t avdd = fuxi_rpmh_lookup("ldom6");

	printf("FUXI RPMH: iovdd(ldob12)=%#x avdd(ldom6)=%#x\n", iovdd, avdd);
	if (rsc != NULL) {
		volatile uint32_t *slot = (volatile uint32_t *)((volatile uint8_t *)rsc + FUXI_RSC_SLOTS);
		printf("FUXI RPMH: rsc drv cfg=%#x  slot0: %#x %#x %#x %#x %#x %#x %#x %#x\n",
		    rsc[0x00c / 4], slot[0], slot[1], slot[2], slot[3],
		    slot[4], slot[5], slot[6], slot[7]);
	} else {
		printf("FUXI RPMH: rsc map failed\n");
	}
}
'''

anchor = 'static void\nft_thread(void *arg, wait_result_t result)'
assert anchor in text, 'ft_thread anchor missing'
text = text.replace(anchor, probe + '\n' + anchor, 1)

# ---- insertion 2: the call, right after the startup line ----
call_anchor = '''	printf("FUXI TOUCH: starting in %u s (poll %u us active, %u us idle)\\n", delay_s,
	    poll_us, idle_us);
'''
assert call_anchor in text, 'startup printf anchor missing'
text = text.replace(call_anchor, call_anchor + '\tfuxi_rpmh_probe();\n', 1)

old = SRC.read_text()
pathlib.Path('/root/ios-fuxi/xnu/fuxi-h1/fuxi_touch.c').write_text(text)

diff = list(difflib.unified_diff(
    old.splitlines(keepends=True), text.splitlines(keepends=True),
    fromfile='a/bsd/dev/fuxi_touch.c', tofile='b/bsd/dev/fuxi_touch.c', n=3))

BASE = 560
out = [diff[0], diff[1]]
for line in diff[2:]:
    m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', line)
    if m:
        a, n_old, b, n_new = (int(x) for x in m.groups())
        start = BASE + a - 1
        out.append(f'@@ -{start},{n_old} +{start},{n_new} @@\n')
    else:
        out.append(line)
patch = ''.join(out)
pathlib.Path('/root/fuxi/0115-fuxi-rpmh-probe.patch').write_bytes(patch.encode())
print(patch[:1500])

# verify against the pristine file
work = pathlib.Path(tempfile.mkdtemp())
(work / 'bsd/dev').mkdir(parents=True)
(work / 'bsd/dev/fuxi_touch.c').write_text(old)
r = subprocess.run(['git', 'apply', '--check', '--verbose', '/root/fuxi/0115-fuxi-rpmh-probe.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check ===', 'rc =', r.returncode)
print(r.stdout.strip()[:200])
print(r.stderr.strip()[:300])
