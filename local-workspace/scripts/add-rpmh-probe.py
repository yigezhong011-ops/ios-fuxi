#!/usr/bin/env python3
"""Add an RPMh/cmd-db probe to the Fuxi loader, printed on the loader console."""
from pathlib import Path

F = Path('/root/ios-fuxi/shim/fuxi-loader/loader.c')
src = F.read_text()

if 'rpmh_probe' in src:
    print('already patched')
    raise SystemExit

decls = '''
/* ---- RPMh probe: the touch controller's LDOs are RPMh VRM resources ---- */
uint32_t probe_safe_rd32(uint64_t pa, uint32_t *faulted);
unsigned probe_safe_wr32(uint64_t pa, uint32_t value);

#define CMD_DB_PHYS	0x81c60000UL
#define APPS_RSC_PHYS	0x17a00000UL
#define RSC_SLOTS	0xd00UL
#define RSC_SLOT_SIZE	0x2a0UL

struct db_slave { uint16_t id, header_offset, data_offset, count, version, rsv[3]; };
struct db_header { uint32_t version; uint8_t magic[4]; struct db_slave slave[8]; uint32_t checksum, rsv; };
struct db_entry { char id[8]; uint32_t prio[2]; uint32_t address; uint16_t length, offset; };

static int rpmh_name_eq(const char *a, const char *b)
{
	for (int i = 0; i < 8; i++)
		if (a[i] != b[i])
			return 0;
	return 1;
}

/* The bootloader's cmd-db lists every RPMh resource by name; the address is the
 * argument of an RSC command. Safe reads: an unmapped page must not reset. */
static uint32_t rpmh_lookup(const char *name, uint32_t *faulted)
{
	struct db_header *db = (struct db_header *)CMD_DB_PHYS;
	uint32_t f = 0, magic;
	char id[8] = {0};
	unsigned count;
	struct db_entry *entries;

	for (int i = 0; i < 8 && name[i]; i++)
		id[i] = name[i];

	magic = probe_safe_rd32(CMD_DB_PHYS + 4, &f);
	if (f)
		return 0;
	if (((magic >> 24) & 0xff) != 0xdb)
		return 0;
	count = probe_safe_rd32(CMD_DB_PHYS + 0x0c, &f);
	(void)count;
	for (unsigned s = 0; s < 8; s++) {
		unsigned slave_count = probe_safe_rd32(CMD_DB_PHYS + 8 + s * 16 + 6, &f);
		unsigned hdr = probe_safe_rd32(CMD_DB_PHYS + 8 + s * 16 + 2, &f);
		unsigned slave_id = probe_safe_rd32(CMD_DB_PHYS + 8 + s * 16, &f);
		if (f || slave_id == 0 || slave_count > 512)
			continue;
		entries = (struct db_entry *)(CMD_DB_PHYS + 0x54 + hdr);
		for (unsigned i = 0; i < slave_count; i++) {
			struct db_entry *e = &entries[i];
			uint32_t addr = probe_safe_rd32((uint64_t)(uintptr_t)&e->address, &f);
			if (f)
				return 0;
			if (rpmh_name_eq((const char *)e->id, id))
				return addr;
		}
	}
	return 0;
}

static void rpmh_probe(void)
{
	uint32_t f = 0, magic = probe_safe_rd32(CMD_DB_PHYS + 4, &f);
	uint32_t a12 = rpmh_lookup("ldob12", &f);
	uint32_t am6 = rpmh_lookup("ldom6", &f);
	volatile uint32_t *rsc = (volatile uint32_t *)(APPS_RSC_PHYS + RSC_SLOTS);

	con_hex("cmddb magic", f ? 0xdead : magic);
	con_hex("ldob12 addr", a12);
	con_hex("ldom6 addr", am6);
	con_hex("rsc slot0 w0", probe_safe_rd32(APPS_RSC_PHYS + RSC_SLOTS + 0x00, &f));
	con_hex("rsc slot0 w1", probe_safe_rd32(APPS_RSC_PHYS + RSC_SLOTS + 0x04, &f));
	con_hex("rsc slot0 w2", probe_safe_rd32(APPS_RSC_PHYS + RSC_SLOTS + 0x08, &f));
	con_hex("rsc slot0 w3", probe_safe_rd32(APPS_RSC_PHYS + RSC_SLOTS + 0x0c, &f));
	con_hex("rsc slot0 w4", probe_safe_rd32(APPS_RSC_PHYS + RSC_SLOTS + 0x10, &f));
	(void)rsc;
}
'''

anchor = 'typedef void (*xnu_entry_t)(uint64_t boot_args_pa);'
assert anchor in src
src = src.replace(anchor, decls + '\n' + anchor, 1)

call_anchor = ''' con_clear(BLUE);
 con_str("FUXI", "XNU loader + USB monitor");'''
assert call_anchor in src
src = src.replace(call_anchor, call_anchor + '\n rpmh_probe();', 1)

F.write_text(src)
print('loader patched: rpmh_probe added')
