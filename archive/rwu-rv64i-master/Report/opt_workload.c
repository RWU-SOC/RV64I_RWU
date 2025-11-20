#include "rwu-rv64i.h"
#include <stdint.h>

/* alias for GPIO write */
static inline void gout(uint8_t v) { rwu_print(v); }

/* ------- small functions (candidates for inlining) ------- */
static uint32_t f_add(uint32_t a, uint32_t b) { return a + b; }
static uint32_t f_xor(uint32_t a, uint32_t b) { return a ^ b; }
static uint32_t f_rotl(uint32_t x, uint32_t r) {return (x << r) | (x >> (32 - r));}
static uint32_t f_mix(uint32_t x, uint32_t y) {
    uint32_t t = f_add(x, y);
    t = f_xor(t, (x << 3));
    t = f_rotl(t, 7);
    return t;
}

static uint32_t run_funcs(uint32_t seed, int rounds) {
    uint32_t acc = seed;
    for (int i = 0; i < rounds; ++i) {
        acc = f_mix(acc, (uint32_t)i);
    }
    return acc;
}

/* -loop-heavy workload (candidates for unrolling/strength-reduction) - */
static uint32_t loop_heavy(uint32_t n) {
    uint32_t s = 0;
    for (uint32_t i = 1; i <= n; ++i) {
        uint32_t mul3 = (i + i + i);
        s += (mul3 ^ (i << 2)) + ((i & 0xF) << 5);
    }
    return s;
}

/* ------- switch/table workload (branch vs jump-table) ------- */
static uint32_t switch_case(uint32_t x) {
    switch (x & 0xF) {
    case 0: return 0x1111u;
    case 1: return 0x2222u;
    case 2: return 0x3333u;
    case 3: return 0x4444u;
    case 4: return 0x5555u;
    case 5: return 0x6666u;
    case 6: return 0x7777u;
    case 7: return 0x8888u;
    case 8: return 0x9999u;
    case 9: return 0xAAAau;
    case 10: return 0xBBBbu;
    case 11: return 0xCCCCu;
    case 12: return 0xDDDDu;
    case 13: return 0xEEEEu;
    case 14: return 0xFFFFu;
    default: return 0x0000u;
    }
}

static uint32_t run_switch(uint32_t seed, int rounds) {
    uint32_t acc = 0;
    for (int i = 0; i < rounds; ++i) {
        acc ^= switch_case(seed + (uint32_t)i);
    }
    return acc;
}

/* ------- small memcpy-like routine (should remain simple) ------- */
static void mini_memcpy(uint8_t *dst, const uint8_t *src, uint32_t n) {
    for (uint32_t i = 0; i < n; ++i) {
        dst[i] = src[i];
    }
}

/* ------- top-level main: emit GPIO markers, run sections, output results ------- */
int main(void) {
    rwu_dmem_reset();

    /* START marker */
    gout(0xE0);

    /* Section 1: many small functions */
    gout(0xE1);
    uint32_t r1 = run_funcs(0x12345678u, 40);

    /* Section 2: loop heavy */
    gout(0xE2);
    uint32_t r2 = loop_heavy(200);

    /* Section 3: switch/jump-table */
    gout(0xE3);
    uint32_t r3 = run_switch(0x55AAu, 100);

    /* Section 4: memcpy-like (exercise data movement) */
    gout(0xE4);
    static uint8_t src[64];
    static uint8_t dst[64];
    for (uint32_t i = 0; i < sizeof(src); ++i) src[i] = (uint8_t)(i * 3 + 7);
    mini_memcpy(dst, src, sizeof(src));

    /* combine results to produce final bytes to GPIO */
    uint8_t out1 = (uint8_t)((r1 ^ r2) & 0xFF);
    uint8_t out2 = (uint8_t)((r3 >> 8) & 0xFF);
    uint8_t out3 = (uint8_t)((r3) & 0xFF);

    gout(out1);
    gout(out2);
    gout(out3);

    /* Store a 64-bit marker in DMEM for offline verification */
    rwu_store64( ((uint64_t)r1 << 32) ^ r2 ^ r3 ^ 0xDEADBEEFULL );

    /* Final markers */
    gout(0xE5);
    gout(0x0A);

    while (1) {
        gout(0xFF);
    }
    return 0;
}
