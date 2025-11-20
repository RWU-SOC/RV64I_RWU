/* fact_store.c
 * Compute factorial(5) and write result to DMEM (via rwu_store64)
 * and indicate low byte on GPIO (via rwu_print).
 *
 * Uses rwu-rv64i.h header (must be in include path).
 */


#include "rwu-rv64i.h"

/* Compute factorial iteratively (safe for embedded / small stacks) */
static uint64_t factorial(uint64_t n)
{
    uint64_t r = 1;
    for (uint64_t i = 2; i <= n; ++i) {
        r *= i;
    }
    return r;
}


int main(void)
{
    /* Make sure DMEM writer points to the user-safe base (from linker) */
    rwu_dmem_reset();

    /* compute factorial and store the 64-bit result in DMEM (user area) */
    uint64_t res = factorial(5);    /* 5! = 120 */
    rwu_store64(res);               /* stored at _user_dmem_start (DMEM_USER_BASE) */

    /* optional: also output low 8 bits to GPIO so TB can check quickly */
    rwu_print(res);   /* expected 120 = 0x78 */


    /* Write canonical pass marker if your TB expects 0xAB on GPIO */
    rwu_print(0xAB);

    /* Halt */
    while(1){

    }
    return 0;
}

