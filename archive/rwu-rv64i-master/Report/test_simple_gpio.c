/* test_simple_gpio.c
 * Simple optimization test program for RWU-RV64I
 * Expected GPIO output (decimal): 200,150,50,25,75,255...
 */

#include "rwu-rv64i.h"
#include <stdint.h>

static inline void gout(uint8_t v) { rwu_print(v); }

int main(void) {
    uint8_t a = 100;
    uint8_t b = 50;
    uint8_t c;

    gout(200);   // Start marker (0xC8)

    c = a + b;   // 150
    gout(c);

    c = a - b;   // 50
    gout(c);

    c = b / 2;   // 25
    gout(c);

    c = a ^ b;   // 86
    c = c - 11;  // 75
    gout(c);

    while (1) {
        gout(255);
    }
    return 0;
}
