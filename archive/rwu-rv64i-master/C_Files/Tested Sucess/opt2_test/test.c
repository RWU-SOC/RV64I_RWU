#include "rwu-rv64i.h"

static int square(int x)
{
    return x * x;
}

int main(void)
{
    // Start marker
    rwu_print(0xA0);

    int sum = 0;
    int i;

    // Basic arithmetic and loop (compiler can unroll/optimize this)
    for (i = 1; i <= 5; i++) {
        int s = square(i);
        sum += s;
        rwu_print(0xA0 + i);   // 0xA1, 0xA2, 0xA3, 0xA4, 0xA5
    }

    // Conditional section (compiler may branch-optimize)
    if (sum > 50)
        rwu_print(0xB0);
    else
        rwu_print(0xB1);

    // Bitwise and arithmetic mix
    int val = (sum ^ 0x55) & 0xFF;
    rwu_print(val);  // Outputs lower 8 bits of computed value

    // End marker
    rwu_print(0xAF);
    while(1){
    	rwu_print(0xFF);
    }
    return 0;
}
