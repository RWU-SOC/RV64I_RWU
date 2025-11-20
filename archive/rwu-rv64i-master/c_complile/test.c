#include "rwu-rv64i.h"

uint64_t a;
const uint64_t b=5;

int main(void) {
    rwu_dmem_reset();
    uint64_t c = 10;
    uint64_t d = 20;

    a = 20;

    while (1){
    	if((a+c) > (b+d)){
    		rwu_print(0x0F);  //TURN ALL LED ON
    	}
    	else{
    		rwu_print(0x03);  //TURN FIRST 2 LED ON
    	}
    }
}
