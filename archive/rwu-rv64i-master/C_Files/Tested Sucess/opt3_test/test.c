/* test_simple_gpio.c
 * Simple optimization test program for RWU-RV64I
 * - No delay, no multiply/divide
 * - Prints 6 predictable GPIO values
 *
 * Expected GPIO output (decimal):
 *   200, 150, 50, 25, 75, 255
 */

#include "rwu-rv64i.h"


static inline void gout(uint8_t v) { rwu_print(v); }

int main(void)
{
    uint8_t a = 100;
    uint8_t b = 50;
    uint8_t c;

    gout(200);   // Start marker (0xC8)

    c = a + b;   // 100 + 50 = 150
    gout(c);     // → 150

    c = a - b;   // 100 - 50 = 50
    gout(c);     // → 50

    c = b / 2;   // 50 / 2 = 25
    gout(c);     // → 25

    c = a ^ b;   // 100 XOR 50 = 86 (0x56)
    c = c - 11;  // 86 - 11 = 75
    gout(c);     // → 75


    while (1) {
    	gout(255);
    }  // stop execution

    return 0;
}
