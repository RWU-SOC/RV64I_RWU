// 002_bss_zero.c
#include "rwu-rv64i.h"

uint64_t g_a;     // .bss → should be 0
uint64_t g_b;     // .bss
uint64_t g_sum;   // .bss

int main(void){
    rwu_dmem_reset();

    // Check bss is 0
    rwu_store64(g_a);            // expect 0
    rwu_store64(g_b);            // expect 0

    // Initialize in main and sum
    g_a = 10; g_b = 45; g_sum = g_a + g_b;   // 55
    rwu_store64(g_sum);          // expect 55

    rwu_print((uint8_t)g_sum);   // 0x37 for quick visual
    rwu_print(0xAB);             // PASS
    while(1);
}

