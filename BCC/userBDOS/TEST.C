#define word char

#include "LIB/MATH.C"
#include "LIB/STDLIB.C"
#include "LIB/SYS.C"

int main() 
{

  BDOS_PrintConsole("Running user program\n");

  while (1)
  {
    if (HID_FifoAvailable())
    {
      word c = HID_FifoRead();
      if (c == 27) // escape
      {
        return 'q';
      }
      if (c < 255)
      {
        BDOS_PrintcConsole(c);
      }
    }

  }

  return 'q';
}

// timer1 interrupt handler
void int1()
{
   timer1Value = 1; // notify ending of timer1
}

void int2()
{
}

void int3()
{
}

void int4()
{
}