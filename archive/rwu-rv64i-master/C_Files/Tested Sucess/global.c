#include "rwu-rv64i.h"

/* Uninitialized globals (in .bss) */
uint64_t g_a;   // defaults to 0 at reset
uint64_t g_b;
uint64_t g_c;
uint64_t g_sum;

int main(void) {
    rwu_dmem_reset();   // start DMEM logging from 0x100

    // Initialize inside main
    g_a = 10;
    g_b = 20;
    g_c = 25;

    // Compute sum
    g_sum = g_a + g_b + g_c;

    // Store results into DMEM
    rwu_store64(g_a);
    rwu_store64(g_b);
    rwu_store64(g_c);
    rwu_store64(g_sum);

    // Send sum on GPIO for TB visibility
    rwu_print((uint8_t)g_sum);   // expect 55

    while (1);
}

