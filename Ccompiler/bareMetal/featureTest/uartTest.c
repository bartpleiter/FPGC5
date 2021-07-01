#include "lib/gfx.h"
//#include "data/tables.h"

void delay(int ms)
{

    // clear result
    int *o = (int *) 0x4C0000;
    *o = 0;

    // set timer
    int *p = (int *) 0xC02739;
    *p = ms;
    // start timer
    int *q = (int *) 0xC0273A;
    *q = 1;

    // wait until timer done
    while (*o == 0);
}

int c = 3;

int main()
{

 //   GFX_initVram();
 //   GFX_copyPaletteTable((int)DATA_PALETTE_DEFAULT); // add offset to data
 //   GFX_copyPatternTable((int)DATA_ASCII_DEFAULT); // add offset to data

    // note that a line in background is 64 tiles, while in window it is just 40
    GFX_printWindowColored((int)"hallo", 5, GFX_WindowPosFromXY(5,2), 2); // pos 4, line 2
    GFX_printBGColored((int)"BACKGROUND", 10, GFX_BackgroundPosFromXY(7,2), 1); // pos 2, line 2


    delay(100);

    int *p = (int *)0xC01420;

    int i = 0;
    while (1)
    {
        for (int j = 512; j < 800; j++)
        {
            *(p+j) = c;
        }
        
        i++;

        if (i > 128)
        {
            i = 0;

            //int *f = (int *)0xC02723;   // address of UART TX
            //*f = 65;            // write char over UART
        }
    }

    return 65;
}
// timer1 interrupt handler
void int1()
{
    int *p = (int *) 0x4C0000; // set address (timer1 state)
   *p = 1; // write value
}

void int2()
{
}

void int3()
{
    // read byte
    int *p = (int *)0xC02722;   // address of UART RX
    int b = *p;                 // read byte from UART

    int *f = (int *)0xC02723;   // address of UART TX
    *f = b;            // write char over UART
}

void int4()
{
    c++;
}