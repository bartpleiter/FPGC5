#define word char

#include "LIB/MATH.C"
#include "LIB/STDLIB.C"
#include "LIB/SYS.C"
#include "LIB/GFX.C"

#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 25

#define MAX_RAIN_LENGTH 15
#define MIN_RAIN_LENGTH 5
#define RAIN_DELAY_MS 32 // ~30fps

#define VRAM_PALETTE_TABLE_ADDR 0xC00400

#define VRAM_WINDOW_TILE_ADDR 0xC01420
#define MEMSTATUS_ADDR 0x440000

// Window tile vram. vidMem[Y][X] (bottom right is [24][39])
char (*vidMem)[SCREEN_WIDTH] = (char (*)[SCREEN_WIDTH]) VRAM_WINDOW_TILE_ADDR;

// Hidden vram layer for pixel status
char (*memStatus)[SCREEN_WIDTH] = (char (*)[SCREEN_WIDTH]) MEMSTATUS_ADDR;

// Chars: 33 to 126

word rngLfsr = 0xACE1;
word rngBit = 0;

word rngRand()
{
  rngBit  = ((rngLfsr >> 0) ^ (rngLfsr >> 2) ^ (rngLfsr >> 3) ^ (rngLfsr >> 5) ) & 1;
  rngLfsr = (rngLfsr >> 1) | (rngBit << 15);
  return rngLfsr;
}

void initGraphics()
{
  GFX_clearWindowtileTable();

  // set default green palette
  word* palette = (word*) VRAM_PALETTE_TABLE_ADDR;
  palette[0] = 28; // green -> 0b00011100

  word x, y;
  for (x = 0; x < SCREEN_WIDTH; x++)
  {
    for (y = 0; y < SCREEN_HEIGHT; y++)
    {
      vidMem[y][x] = 0;
      memStatus[y][x] = 0;
    }
  }
}


// Return a random character to print
char getRandomChar()
{
  rngRand(); rngRand();
  return MATH_modU(rngRand(), 93) + 33;
}

// Update all rain on screen
void updateRain()
{
  word x, y;

  // do last line
  for (x = 0; x < SCREEN_WIDTH; x++)
  {
    if (memStatus[SCREEN_HEIGHT-1][x] > 0)
    {
      memStatus[SCREEN_HEIGHT-1][x]--;
      if (memStatus[SCREEN_HEIGHT-1][x] == 0)
      {
        vidMem[SCREEN_HEIGHT-1][x] = 0; // clear the character on screen
      }
    }
  }

  // skip last line
  for (y = SCREEN_HEIGHT-2; y >= 0; y--)
  {
    for (x = 0; x < SCREEN_WIDTH; x++)
    {
      if (memStatus[y][x] > 0)
      {
        // create new char if at bottom of rain
        if (memStatus[y+1][x] == 0)
        {
          vidMem[y+1][x] = getRandomChar();
        }

        memStatus[y+1][x] = memStatus[y][x]; // propagate downwards

        memStatus[y][x]--; // decrease so it eventually ends
        if (memStatus[y][x] == 0)
        {
          vidMem[y][x] = 0; // clear the character on screen
        }
      }
    }
  }
}


// Generate a falling line at position x
void genRainLine(word x)
{
  // return if x is not free
  if (memStatus[0][x] != 0 || memStatus[1][x] != 0)
  {
    return;
  }

  word rainLen = MATH_modU(rngRand(), (MAX_RAIN_LENGTH + 1) - MIN_RAIN_LENGTH) + MIN_RAIN_LENGTH;

  memStatus[0][x] = rainLen;
  vidMem[0][x] = getRandomChar();
}

int main() 
{

  initGraphics();

  while (1)
  {
    if (HID_FifoAvailable())
    {
      word c = HID_FifoRead();
      if (c == 27) // escape
      {
        GFX_clearWindowtileTable();
        return 'q';
      }
    }

    updateRain();
    rngRand(); rngRand(); rngRand();
    genRainLine(MATH_modU(rngRand(), SCREEN_WIDTH));
    rngRand(); rngRand(); rngRand();
    genRainLine(MATH_modU(rngRand(), SCREEN_WIDTH));
    delay(RAIN_DELAY_MS);
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