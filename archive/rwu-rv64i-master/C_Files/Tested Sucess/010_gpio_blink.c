// 010_gpio_blink.c
#include "rwu-rv64i.h"

static inline void delay(uint64_t val)
    {
	val = val * 10;
    for(uint64_t i=0;i<val;i++);
    }

int main(void)
{
	GPIO_REG_OUT = 0x0F;
	delay(10000);
	GPIO_REG_OUT = 0x00;
	delay(25000);
    while(1)
    {
    	//LED 0
        GPIO_REG_OUT |= (1<<0); //ON
        delay(25000);
        GPIO_REG_OUT &= ~(1<<0); //OFF


    	//LED 1
        GPIO_REG_OUT |= (1<<1);  // ON
        delay(25000);  // ON
        GPIO_REG_OUT &= ~(1<<1);  // OFF


    	//LED 2
        GPIO_REG_OUT |= (1<<2); // ON
        delay(25000);
        GPIO_REG_OUT &= ~(1<<2); // OFF

    	//LED 3
        GPIO_REG_OUT |= (1<<3); // ON
        delay(25000);
        GPIO_REG_OUT &= ~(1<<3); // OFF

        //ALL ON
    	GPIO_REG_OUT = 0x0F;
    	delay(25000);

    	//ALL OFF
    	GPIO_REG_OUT = 0x00;
    	delay(25000);
    }
}
