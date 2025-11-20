#include "rwu-rv64i.h"

int main(void) {
    rwu_dmem_reset();

    uint64_t sum = 0;
    for (int i = 1; i <= 10; i++) sum += i;

    rwu_store64(sum);   // DMEM @ _user_dmem_start (0x100): 55
    rwu_print(55);      // GPIO = 0x37

    while (1);
}

