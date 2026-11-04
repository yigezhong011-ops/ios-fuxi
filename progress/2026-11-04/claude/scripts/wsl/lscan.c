// Read-only: finds LZ4 "bv41" blocks (unified log chunksets and others) in a raw range, inflates them and prints their printable strings to stdout.
// Opens the device O_RDONLY and writes nothing to disk. Usage: lscan <dev> <first 4K block> <blocks> [min string length]
// Each block prints "#C <absolute byte offset> <size>", then one string per line.
#define _FILE_OFFSET_BITS 64
#define _GNU_SOURCE
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BS 4096u
#define WINDOW (8u << 20)
#define OVERLAP (2u << 20)
#define MAX_RAW (2u << 20)

// Plain LZ4 block decoder with bounds checks. Returns the output length, or -1 when the input is not a valid block.
static long lz4(const uint8_t *in, size_t n, uint8_t *out, size_t cap) {
    const uint8_t *ip = in, *const ie = in + n;
    size_t o = 0;
    while (ip < ie) {
        const unsigned token = *ip++;
        size_t lit = token >> 4;
        if (lit == 15) {
            unsigned char c;
            do {
                if (ip >= ie) return -1;
                c = *ip++;
                lit += c;
            } while (c == 255);
        }
        if (lit > (size_t)(ie - ip) || lit > cap - o) return -1;
        memcpy(out + o, ip, lit);
        ip += lit;
        o += lit;
        if (ip == ie) return (long)o;
        if (ie - ip < 2) return -1;
        const size_t off = ip[0] | ((size_t)ip[1] << 8);
        ip += 2;
        if (!off || off > o) return -1;
        size_t len = token & 15;
        if (len == 15) {
            unsigned char c;
            do {
                if (ip >= ie) return -1;
                c = *ip++;
                len += c;
            } while (c == 255);
        }
        len += 4;
        if (len > cap - o) return -1;
        for (size_t i = 0; i < len; ++i, ++o) out[o] = out[o - off];
    }
    return (long)o;
}

static void strings(const uint8_t *b, size_t n, size_t min) {
    size_t start = 0;
    for (size_t i = 0; i <= n; ++i) {
        if (i < n && b[i] >= 0x20 && b[i] < 0x7f) continue;
        if (i - start >= min) {
            fwrite(b + start, 1, i - start, stdout);
            putchar('\n');
        }
        start = i + 1;
    }
}

int main(int argc, char **argv) {
    if (argc < 4) {fprintf(stderr, "usage: lscan <dev> <first> <blocks> [min]\n"); return 2;}
    const int fd = open(argv[1], O_RDONLY);
    if (fd < 0) {perror("open"); return 1;}
    const uint64_t first = strtoull(argv[2], 0, 0), blocks = strtoull(argv[3], 0, 0);
    const size_t min = argc > 4 ? strtoul(argv[4], 0, 0) : 6;
    uint8_t *win = malloc(WINDOW), *raw = malloc(MAX_RAW);
    if (!win || !raw) return 1;
    const uint64_t start = first * BS, end = (first + blocks) * BS;
    const size_t step = WINDOW - OVERLAP;
    uint64_t found = 0, bad = 0, total = 0;
    for (uint64_t at = start; at < end; at += step) {
        const size_t want = end - at < WINDOW ? (size_t)(end - at) : WINDOW;
        if (pread(fd, win, want, (off_t)at) != (ssize_t)want) {fprintf(stderr, "read error at %llu\n", (unsigned long long)at); return 1;}
        // A hit is handled in the window where it starts before the step boundary, so overlapping windows don't print it twice.
        const size_t limit = want == WINDOW ? step : want;
        const uint8_t *p = win, *const e = win + limit;
        while ((p = memmem(p, (size_t)(e - p), "bv41", 4))) {
            const size_t pos = (size_t)(p - win);
            p += 4;
            if (want - pos < 12) break;
            uint32_t rawSize, packed;
            memcpy(&rawSize, win + pos + 4, 4);
            memcpy(&packed, win + pos + 8, 4);
            if (!rawSize || rawSize > MAX_RAW || !packed || packed > OVERLAP - 12 || pos + 12 + packed > want) continue;
            const long got = lz4(win + pos + 12, packed, raw, rawSize);
            if (got != (long)rawSize) {++bad; continue;}
            ++found;
            total += rawSize;
            printf("#C %llu %u\n", (unsigned long long)(at + pos), rawSize);
            strings(raw, rawSize, min);
        }
    }
    printf("#END blocks %llu rejected %llu inflated bytes %llu\n", (unsigned long long)found, (unsigned long long)bad, (unsigned long long)total);
    return 0;
}
