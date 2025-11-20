/* test.c
 * Square test: compute squares in a loop and print markers.
 */

#include "rwu-rv64i.h"
#include <stdint.h>

static int square(int x) {
    return x * x;
}

int main(void) {
    /* Start marker */
    rwu_print(0xA0);

    int sum = 0;
    for (int i = 1; i <= 5; i++) {
        int s = square(i);
        sum += s;
        rwu_print(0xA0 + i);   // 0xA1..0xA5
    }

    if (sum > 50)
        rwu_print(0xB0);
    else
        rwu_print(0xB1);

    int val = (sum ^ 0x55) & 0xFF;
    rwu_print(val);

    rwu_print(0xAF);
    while (1) {
        rwu_print(0xFF);
    }
    return 0;
}
