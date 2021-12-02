#include "lib/stdlib.h"
#include "lib/sys.h"
#include "lib/gfx.h"
#include "data/TESTIMAGE.h"





void testCard()
{
    GFX_initVram(); // clear all VRAM
    GFX_copyPaletteTable((int)DATA_PALETTE_COLOR);
    GFX_copyPatternTable((int)DATA_PATTERN_COLOR);

    for (int y = 0; y < 25; y++)
    {
        GFX_printWindowColored(((int)tileColor0) + 4, 5, GFX_WindowPosFromXY(0, y), 1);
        GFX_printWindowColored(((int)tileColor1) + 4, 5, GFX_WindowPosFromXY(5, y), 1);
        GFX_printWindowColored(((int)tileColor2) + 4, 5, GFX_WindowPosFromXY(10, y), 1);
        GFX_printWindowColored(((int)tileColor3) + 4, 5, GFX_WindowPosFromXY(15, y), 1);
        GFX_printWindowColored(((int)tileColor0) + 4, 5, GFX_WindowPosFromXY(20, y), 2);
        GFX_printWindowColored(((int)tileColor1) + 4, 5, GFX_WindowPosFromXY(25, y), 2);
        GFX_printWindowColored(((int)tileColor2) + 4, 5, GFX_WindowPosFromXY(30, y), 2);
        GFX_printWindowColored(((int)tileColor3) + 4, 5, GFX_WindowPosFromXY(35, y), 2);
    }
}

void writePattern()
{
    ASM("\
    // backup registers                 ;\
    push r1                             ;\
    push r2                             ;\
    push r3                             ;\
    push r4                             ;\
    push r5                             ;\
    push r6                             ;\
    push r7                             ;\
    // 128 tiles in Window layer to id 252-255;\
    // vram address;\
    load32 0xC01420 r1        // vram addr 1056+2048 0xC01420;\
    add r1 412 r1               // add starting offset;\
;\
    // loop variables;\
    load 0 r3                   // loopvar;\
    load 128 r4                 // loopmax;\
    or r1 r0 r5                 // vram addr with offset;\
    load 252 r1                 // initial tile ID;\
    load 0 r2                   // counter for next line;\
    load 15 r6                  // compare for next line (-1);\
;\
    // loop;\
    Test_colors_write_tile_id_loop:;\
        write 0 r5 r1           // set tile;\
;\
        // check if tile id is 255, then set back to 252, else increase by one;\
        load 255 r7;\
        bne r7 r1 2;\
            load 252 r1;\
        add r1 1 r1;\
;\
        shiftr r3 2 r7          // only increase color id every 4 tiles;\
        write 2048 r5 r7        // set color (2048 offset, 0x800 in hex);\
;\
        // if drawn 16 tiles on this line;\
        bne r2 r6 4;\
            add r5 25 r5;\
            load 0 r2;\
            jumpo 3                 // skip the other clause;\
        ;\
        // else;\
            add r2 1 r2;\
            add r5 1 r5             // incr vram address;\
;\
        add r3 1 r3             // incr counter;\
;\
        beq r3 r4 2             // keep looping until all tiles are set;\
        jump Test_colors_write_tile_id_loop;\
;\
    // restore registers ;\
    pop r7                 ;\
    pop r6                  ;\
    pop r5                  ;\
    pop r4                  ;\
    pop r3                  ;\
    pop r2                  ;\
    pop r1                  ;\
    ");
}

void testPalette1()
{
    GFX_initVram(); // clear all VRAM
    GFX_copyPaletteTable((int)TEST_COLOR_PALETTETABLE_1);
    GFX_copyPatternTable((int)DATA_ASCII_DEFAULT);
    writePattern();
}

void testPalette2()
{
    GFX_initVram(); // clear all VRAM
    GFX_copyPaletteTable((int)TEST_COLOR_PALETTETABLE_2);
    GFX_copyPatternTable((int)DATA_ASCII_DEFAULT);
    writePattern();
}

int main() 
{

    GFX_clearConsole();
    GFX_PrintConsole("Image test tool\n");
    GFX_PrintConsole("Press one of the following keys:\n");
    GFX_PrintConsole("q: quit\n");
    GFX_PrintConsole("1: test card\n");
    GFX_PrintConsole("2: color palette 1/2\n");
    GFX_PrintConsole("3: color palette 2/2\n");

    while (1)
    {
        if (HID_FifoAvailable())
        {
            int c = HID_FifoRead();
            if (c == 'q') // escape
            {
                return 'q';
            }
            if (c == '1')
            {
                testCard();
            }
            if (c == '2')
            {
                testPalette1();
            }
            if (c == '3')
            {
                testPalette2();
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