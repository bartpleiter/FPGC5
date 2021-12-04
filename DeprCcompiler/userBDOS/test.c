#include "lib/stdlib.h"
#include "lib/sys.h"


int main() 
{

    BDOS_PrintConsole("Running user program\n");

    while (1)
    {
        if (HID_FifoAvailable())
        {
            int c = HID_FifoRead();
            if (c == 27) // escape
            {
                return 'q';
            }
            if (c < 255)
            {
                BDOS_PrintcConsole(c);
            }
        }

        int *o = (int *) 0xC0273F;
        int *p = (int *) 0xC01600;
        *p = *o;
        *(p+1) = (*o) >> 8;

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