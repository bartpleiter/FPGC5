// Test image generator for more advanced color tests

#define word char

#include "LIB/MATH.C"
#include "LIB/STDLIB.C"
#include "LIB/SYS.C"
#include "LIB/GFX.C"
#include "DATA/TESTIMGD.C"

#define DATA_OFFSET 3

void testCard()
{
  GFX_initVram(); // clear all VRAM
  GFX_copyPaletteTable((word)DATA_PALETTE_COLOR);
  GFX_copyPatternTable((word)DATA_PATTERN_COLOR);

  word y;
  for (y = 0; y < 25; y++)
  {
    GFX_printWindowColored(((word)tileColor0) + DATA_OFFSET, 5, GFX_WindowPosFromXY(0, y), 1);
    GFX_printWindowColored(((word)tileColor1) + DATA_OFFSET, 5, GFX_WindowPosFromXY(5, y), 1);
    GFX_printWindowColored(((word)tileColor2) + DATA_OFFSET, 5, GFX_WindowPosFromXY(10, y), 1);
    GFX_printWindowColored(((word)tileColor3) + DATA_OFFSET, 5, GFX_WindowPosFromXY(15, y), 1);
    GFX_printWindowColored(((word)tileColor0) + DATA_OFFSET, 5, GFX_WindowPosFromXY(20, y), 2);
    GFX_printWindowColored(((word)tileColor1) + DATA_OFFSET, 5, GFX_WindowPosFromXY(25, y), 2);
    GFX_printWindowColored(((word)tileColor2) + DATA_OFFSET, 5, GFX_WindowPosFromXY(30, y), 2);
    GFX_printWindowColored(((word)tileColor3) + DATA_OFFSET, 5, GFX_WindowPosFromXY(35, y), 2);
  }
}

void writePattern()
{
  asm(
    "; backup registers\n"
    "push r1\n"
    "push r2\n"
    "push r3\n"
    "push r4\n"
    "push r5\n"
    "push r6\n"
    "push r7\n"

    "; 128 tiles in Window layer to id 252-255\n"
    "; vram address\n"
    "load32 0xC01420 r1      ; vram addr 1056+2048 0xC01420\n"
    "add r1 412 r1         ; add starting offset\n"

    "; loop variables\n"
    "load 0 r3           ; loopvar\n"
    "load 128 r4         ; loopmax\n"
    "or r1 r0 r5         ; vram addr with offset\n"
    "load 252 r1         ; initial tile ID\n"
    "load 0 r2           ; counter for next line\n"
    "load 15 r6          ; compare for next line (-1)\n"

    "; loop\n"
    "Test_colors_write_tile_id_loop:\n"
    "write 0 r5 r1       ; set tile\n"

    "; check if tile id is 255, then set back to 252, else increase by one\n"
    "load 255 r7\n"
    "bne r7 r1 2\n"
    "load 252 r1\n"
    "add r1 1 r1\n"

    "shiftr r3 2 r7      ; only increase color id every 4 tiles\n"
    "write 2048 r5 r7    ; set color (2048 offset, 0x800 in hex)\n"

    "; if drawn 16 tiles on this line\n"
    "bne r2 r6 4\n"
    "add r5 25 r5\n"
    "load 0 r2\n"
    "jumpo 3         ; skip the other clause\n"

    "; else\n"
    "add r2 1 r2\n"
    "add r5 1 r5       ; incr vram address\n"

    "add r3 1 r3       ; incr counter\n"

    "beq r3 r4 2       ; keep looping until all tiles are set\n"
    "jump Test_colors_write_tile_id_loop\n"

    "; restore registers\n"
    "pop r7\n"
    "pop r6\n"
    "pop r5\n"
    "pop r4\n"
    "pop r3\n"
    "pop r2\n"
    "pop r1\n"
    );
}

void testPalette1()
{
  GFX_initVram(); // clear all VRAM
  GFX_copyPaletteTable((word)TEST_COLOR_PALETTETABLE_1);
  GFX_copyPatternTable((word)DATA_ASCII_DEFAULT);
  writePattern();
}

void testPalette2()
{
  GFX_initVram(); // clear all VRAM
  GFX_copyPaletteTable((word)TEST_COLOR_PALETTETABLE_2);
  GFX_copyPatternTable((word)DATA_ASCII_DEFAULT);
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
      word c = HID_FifoRead();
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