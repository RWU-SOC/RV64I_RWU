
#include <stdint.h>

#define GPIO_BASE 0x00010000UL
#define GPIO_OUT  (*(volatile uint8_t *)(GPIO_BASE + 4))
/* Symbol provided by the linker: first safe user DMEM address */
extern unsigned char _user_dmem_start;

int main(void)
{
    /* Use the linker-provided safe base. This is a DMEM address (0x0000_0100 by default). */
    volatile uint64_t *p = (volatile uint64_t *)&_user_dmem_start;


    uint64_t a = 25, b = 7;
    p[0] = a + b;   // 32
    GPIO_OUT = p[0];
    p[1] = a - b;   // 18
    GPIO_OUT = p[1];
    p[2] = a * b;   // 175
    GPIO_OUT = p[2];
    p[3] = a / b;   // 3 (integer division)
    GPIO_OUT = p[3];

    while(1);
}



