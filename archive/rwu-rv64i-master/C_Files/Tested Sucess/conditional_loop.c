
#include <stdint.h>

#define GPIO_BASE 0x00010000UL
#define GPIO_OUT  (*(volatile uint8_t *)(GPIO_BASE + 4))

#define DMEM_BASE 0x00000000UL
#define DMEM_RESULT (volatile uint64_t *)(DMEM_BASE + 0x100)

int main(void) {
    volatile uint64_t *p = DMEM_RESULT;

    for (uint64_t i = 0; i < 10; i++) {
        if (i % 2 == 0){
            p[i] = i * 1;   // even: multiple of 10
        	GPIO_OUT = p[i];
        }
        else
        {
            p[i] = i * 10;  // odd: multiple of 100
            GPIO_OUT = p[i];
        }
    }

    while(1);
}

