#include <stdio.h>
#include <stdlib.h>

int main()
{
  long long int gpioID;
  long long int *addrGpio;

  // set address of GPIO ID register
  addrGpio = (long long int*)0x0000000000000100;
  // read GPIO ID register
  gpioID = *addrGpio;
  // write GPIO ID register to GPIO
  addrGpio = (long long int*)0x0000000000000104;
  *addrGpio = gpioID;

  return 0;
}
