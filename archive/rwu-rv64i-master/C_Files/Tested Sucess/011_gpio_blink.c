// 011_gpio_blink.c
#include "rwu-rv64i.h"

static inline void delay(uint64_t val)
    {
	val = val * 10;
    for(uint64_t i=0;i<val;i++);
    }

int main(void)
{
    while(1)
    {
    	GPIO_REG_OUT = 0x0F;
    	delay(10000);
    	GPIO_REG_OUT = 0x00;
    	delay(10000);
    }
}

