#include "lib/stdlib.h"
#include "lib/sys.h"
#include "lib/gfx.h"
#include "data/COLOR.h"


void testTiles(){
ASM("\
.dw 0 1 2 3;\
");
}

int main() 
{

    GFX_initVram(); // clear all VRAM
    GFX_copyPaletteTable((int)DATA_PALETTE_COLOR);
    GFX_copyPatternTable((int)DATA_PATTERN_COLOR);

    int y = 0;
    int c = 1;

    for (int x = 0; x < 5; x++)
    {
        GFX_printWindowColored(((int)testTiles) + 4, 4, GFX_WindowPosFromXY(x*4, y), x + 1);
        GFX_printBGColored(((int)testTiles) + 4, 4, GFX_BackgroundPosFromXY(x*4, y+2), x + 1);
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