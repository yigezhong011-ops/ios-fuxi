// Read-only scanner for the raw Data area, run in TWRP. Opens the device O_RDONLY and never writes to it.
// dscan scan <dev> <first 4K block> <blocks>   prints valid APFS object counts, superblocks, and 4K-aligned gzip heads
// dscan dump <dev> <4K block> <blocks> <file>  copies a range to a file under /tmp
#define _FILE_OFFSET_BITS 64
#define _GNU_SOURCE
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BS 4096u
#define GROUP 256u

static uint64_t fletcher(const uint8_t *b) {
    const uint32_t *w = (const uint32_t *)(b + 8);
    uint64_t s1 = 0, s2 = 0;
    for (unsigned i = 0; i < (BS - 8) / 4; ++i) {
        s1 = (s1 + w[i]) % 0xffffffffull;
        s2 = (s2 + s1) % 0xffffffffull;
    }
    uint64_t c1 = 0xffffffffull - (s1 + s2) % 0xffffffffull;
    uint64_t c2 = 0xffffffffull - (s1 + c1) % 0xffffffffull;
    return (c2 << 32) | c1;
}

static int scan(int fd, uint64_t first, uint64_t blocks) {
    static uint8_t buf[GROUP * BS];
    static uint64_t counts[4][64];   // storage class (ephemeral, physical, virtual, other) by subtype
    uint64_t used = 0, objects = 0;
    for (uint64_t at = 0; at < blocks; at += GROUP) {
        const unsigned want = blocks - at < GROUP ? (unsigned)(blocks - at) : GROUP;
        if (pread(fd, buf, want * BS, (off_t)((first + at) * BS)) != (ssize_t)(want * BS)) {
            printf("read error at block %llu\n", (unsigned long long)(first + at));
            return 1;
        }
        for (unsigned i = 0; i < want; ++i) {
            const uint8_t *b = buf + i * BS;
            const uint64_t *q = (const uint64_t *)b;
            if (!(q[0] | q[1] | q[2] | q[3] | q[4] | q[5])) {
                int zero = 1;
                for (unsigned k = 6; k < BS / 8; ++k) if (q[k]) {zero = 0; break;}
                if (zero) continue;
            }
            ++used;
            const uint64_t block = first + at + i, rel = at + i;
            if (b[0] == 0x1f && b[1] == 0x8b && b[2] == 8)
                printf("GZ rel=%llu abs=%llu flags=%u os=%u\n", (unsigned long long)rel, (unsigned long long)block, b[3], b[9]);
            uint32_t type, sub;
            memcpy(&type, b + 24, 4);
            memcpy(&sub, b + 28, 4);
            if ((type & 0xffff) == 0 || (type & 0xffff) > 0x30 || sub > 0x3f || fletcher(b) != q[0]) continue;
            ++objects;
            const unsigned cls = (type >> 28) == 8 ? 0 : (type >> 28) == 4 ? 1 : (type >> 28) == 0 ? 2 : 3;
            ++counts[cls][sub];
            if (!memcmp(b + 32, "NXSB", 4) || !memcmp(b + 32, "APSB", 4)) {
                uint64_t xid, flags = 0;
                memcpy(&xid, b + 16, 8);
                if (b[32] == 'A') memcpy(&flags, b + 264, 8);
                printf("%.4s rel=%llu xid=%llu fs_flags=0x%llx name=%.32s\n", b + 32, (unsigned long long)rel, (unsigned long long)xid,
                       (unsigned long long)flags, b[32] == 'A' ? (const char *)b + 704 : "");
            }
        }
    }
    printf("used 4K blocks %llu, valid objects %llu\n", (unsigned long long)used, (unsigned long long)objects);
    static const char *const names[4] = {"ephemeral", "physical", "virtual", "other"};
    for (unsigned c = 0; c < 4; ++c)
        for (unsigned s = 0; s < 64; ++s)
            if (counts[c][s]) printf("%s subtype 0x%x: %llu\n", names[c], s, (unsigned long long)counts[c][s]);
    return 0;
}

static int dump(int fd, uint64_t first, uint64_t blocks, const char *path) {
    if (strncmp(path, "/tmp/", 5)) {fprintf(stderr, "output must be under /tmp\n"); return 2;}
    int out = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (out < 0) {perror("open output"); return 1;}
    static uint8_t buf[GROUP * BS];
    for (uint64_t at = 0; at < blocks; at += GROUP) {
        const unsigned want = blocks - at < GROUP ? (unsigned)(blocks - at) : GROUP;
        if (pread(fd, buf, want * BS, (off_t)((first + at) * BS)) != (ssize_t)(want * BS)) {perror("read"); close(out); return 1;}
        if (write(out, buf, want * BS) != (ssize_t)(want * BS)) {perror("write"); close(out); return 1;}
    }
    close(out);
    return 0;
}

// The first 4K of every absolute block listed in the text file, concatenated, for the host to test each gzip head.
static int heads(int fd, const char *list, const char *path) {
    if (strncmp(path, "/tmp/", 5)) {fprintf(stderr, "output must be under /tmp\n"); return 2;}
    FILE *in = fopen(list, "r");
    int out = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (!in || out < 0) {perror("open"); return 1;}
    static uint8_t buf[BS];
    unsigned long long block;
    while (fscanf(in, "%llu", &block) == 1) {
        if (pread(fd, buf, BS, (off_t)(block * BS)) != BS || write(out, buf, BS) != BS) {perror("heads"); return 1;}
    }
    close(out);
    return 0;
}

int main(int argc, char **argv) {
    if (argc == 5 && !strcmp(argv[1], "heads")) {
        int fd = open(argv[2], O_RDONLY);
        if (fd < 0) {perror("open"); return 1;}
        return heads(fd, argv[3], argv[4]);
    }
    if (argc < 5) {fprintf(stderr, "usage: dscan scan <dev> <first> <blocks> | dscan dump <dev> <first> <blocks> <file> | dscan heads <dev> <list> <file>\n"); return 2;}
    int fd = open(argv[2], O_RDONLY);
    if (fd < 0) {perror("open"); return 1;}
    const uint64_t first = strtoull(argv[3], 0, 0), blocks = strtoull(argv[4], 0, 0);
    if (!strcmp(argv[1], "scan")) return scan(fd, first, blocks);
    if (!strcmp(argv[1], "dump") && argc == 6) return dump(fd, first, blocks, argv[5]);
    return 2;
}
