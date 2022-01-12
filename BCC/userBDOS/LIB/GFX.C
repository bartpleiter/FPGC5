/*
* Graphics library
* Mostly Assembly code, because efficiency in both space and time
* More complex functions are written in C
* Int arguments from C are stored in order of r4, r5, r6, r7
* Return value in r2, but should be written on stack using write -4 r14 r2 (add variable in C)
*/

// uses math.c

#define GFX_WINDOW_PATTERN_ADDR 0xC01420
#define GFX_WINDOW_PALETTE_ADDR 0xC01C20
#define GFX_CURSOR_ASCII        219

word GFX_cursor = 0;

// Prints to screen in window plane, with color, data is accessed in words
// INPUT:
//   r4 = address of data to print
//   r5 = length of data
//   r6 = position on screen
//   r7 = palette index
void GFX_printWindowColored(word addr, word len, word pos, word palette)
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
  "push r8\n"
  "push r9\n"
  );

  asm(

  "; vram address\n"
  "load32 0xC01420 r9       ; r9 = vram addr 1056+4096 0xC01420\n"

  "; loop variables\n"
  "load 0 r1            ; r1 = loopvar\n"
  "or r9 r0 r3          ; r3 = vram addr with offset\n"
  "or r4 r0 r2          ; r2 = data addr with offset\n"

  "add r6 r3 r3           ; apply offset from r6\n"

  "; copy loop\n"
  "GFX_printWindowColoredLoop:\n"
  "  read 0 r2 r8      ; read 32 bits\n"
  "  write 0 r3 r8       ; write char to vram\n"
  "  write 2048 r3 r7    ; write palette index to vram\n"
  "  add r3 1 r3       ; incr vram address\n"
  "  add r2 1 r2       ; incr data address\n"
  "  add r1 1 r1       ; incr counter\n"
  "  bge r1 r5 2       ; keep looping until all data is copied\n"
  "  jump GFX_printWindowColoredLoop\n"

  );

  asm(
  "; restore registers\n"
  "pop r9\n"
  "pop r8\n"
  "pop r7\n"
  "pop r6\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Prints to screen in background plane, with color, data is accessed in words
// INPUT:
//   r4 = address of data to print
//   r5 = length of data
//   r6 = position on screen
//   r7 = palette index
void GFX_printBGColored(word addr, word len, word pos, word palette)
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
  "push r8\n"
  "push r9\n"
  );

  asm(

  "; vram address\n"
  "load32 0xC00420 r9       ; r9 = vram addr 1056 0xC00420\n"

  "; loop variables\n"
  "load 0 r1            ; r1 = loopvar\n"
  "or r9 r0 r3          ; r3 = vram addr with offset\n"
  "or r4 r0 r2          ; r2 = data addr with offset\n"

  "add r6 r3 r3           ; apply offset from r6\n"

  "; copy loop\n"
  "GFX_printBGColoredLoop:\n"
  "  read 0 r2 r8      ; read 32 bits\n"
  "  write 0 r3 r8       ; write char to vram\n"
  "  write 2048 r3 r7    ; write palette index to vram\n"
  "  add r3 1 r3       ; incr vram address\n"
  "  add r2 1 r2       ; incr data address\n"
  "  add r1 1 r1       ; incr counter\n"
  "  bge r1 r5 2       ; keep looping until all data is copied\n"
  "  jump GFX_printBGColoredLoop\n"

  );

  asm(
  "; restore registers\n"
  "pop r9\n"
  "pop r8\n"
  "pop r7\n"
  "pop r6\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Loads entire pattern table
// INPUT:
//   r4 = address of pattern table to copy
void GFX_copyPatternTable(word addr)
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"
  "push r6\n"

  "; vram address\n"
  "load32 0xC00000 r2        ; r2 = vram addr 0 0xC00000\n"

  "; loop variables\n"
  "load 0 r3             ; r3 = loopvar\n"
  "load 1024 r5  ; r5 = loopmax\n"
  "or r2 r0 r1           ; r1 = vram addr with offset\n"
  "add r4 3 r6  ; r6 = ascii addr with offset\n"

  "; copy loop\n"
  "GFX_initPatternTableLoop:\n"
  "  copy 0 r6 r1      ; copy ascii to vram\n"
  "  add r1 1 r1       ; incr vram address\n"
  "  add r6 1 r6       ; incr ascii address\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r5 2       ; keep looping until all data is copied\n"
  "  jump GFX_initPatternTableLoop\n"

  "; restore registers\n"
  "pop r6\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}



// Loads entire palette table
// INPUT:
//   r4 = address of palette table to copy
void GFX_copyPaletteTable(word addr)
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"
  "push r6\n"

  "; vram address\n"
  "load32 0xC00400 r2        ; r2 = vram addr 1024 0xC00400\n"

  "; loop variables\n"
  "load 0 r3             ; r3 = loopvar\n"
  "load 32 r5  ; r5 = loopmax\n"
  "or r2 r0 r1           ; r1 = vram addr with offset\n"
  "add r4 3 r6  ; r6 = palette addr with offset\n"

  "; copy loop\n"
  "GFX_initPaletteTableLoop:\n"
  "  copy 0 r6 r1      ; copy palette to vram\n"
  "  add r1 1 r1       ; incr vram address\n"
  "  add r6 1 r6       ; incr palette address\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r5 2       ; keep looping until all data is copied\n"
  "  jump GFX_initPaletteTableLoop\n"

  "; restore registers\n"
  "pop r6\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Clear BG tile table
void GFX_clearBGtileTable()
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"

  "; vram address\n"
  "load32 0xC00420 r1      ; r1 = vram addr 1056 0xC00420\n"

  "; loop variables\n"
  "load 0 r3           ; r3 = loopvar\n"
  "load 2048 r4    ; r4 = loopmax\n"
  "or r1 r0 r5         ; r5 = vram addr with offset\n"

  "; copy loop\n"
  "GFX_clearBGtileTableLoop:\n"
  "  write 0 r5 r0       ; clear tile\n"
  "  add r5 1 r5       ; incr vram address\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r4 2       ; keep looping until all tiles are cleared\n"
  "  jump GFX_clearBGtileTableLoop\n"

  "; restore registers\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Clear BG palette table
void GFX_clearBGpaletteTable()
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"

  "; vram address\n"
  "load32 0xC00C20 r1      ; r1 = vram addr 1056+2048 0xC00C20\n"

  "; loop variables\n"
  "load 0 r3           ; r3 = loopvar\n"
  "load 2048 r4    ; r4 = loopmax\n"
  "or r1 r0 r5         ; r5 = vram addr with offset\n"

  "; copy loop\n"
  "GFX_clearBGpaletteTableLoop:\n"
  "  write 0 r5 r0       ; clear tile\n"
  "  add r5 1 r5       ; incr vram address\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r4 2       ; keep looping until all tiles are cleared\n"
  "  jump GFX_clearBGpaletteTableLoop\n"

  "; restore registers\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Clear Window tile table
void GFX_clearWindowtileTable()
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"

  "; vram address\n"
  "load32 0xC01420 r1      ; r1 = vram addr 1056+2048 0xC01420\n"

  "; loop variables\n"
  "load 0 r3           ; r3 = loopvar\n"
  "load 1920 r4  ; r4 = loopmax\n"
  "or r1 r0 r5         ; r5 = vram addr with offset\n"

  "; copy loop\n"
  "GFX_clearWindowtileTableLoop:\n"
  "  write 0 r5 r0       ; clear tile\n"
  "  add r5 1 r5       ; incr vram address\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r4 2       ; keep looping until all tiles are cleared\n"
  "  jump GFX_clearWindowtileTableLoop\n"

  "; restore registers\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Clear Window palette table
void GFX_clearWindowpaletteTable()
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"

  "; vram address\n"
  "load32 0xC01C20 r1      ; r1 = vram addr 1056+2048 0xC01C20\n"

  "; loop variables\n"
  "load 0 r3           ; r3 = loopvar\n"
  "load 1920 r4  ; r4 = loopmax\n"
  "or r1 r0 r5         ; r5 = vram addr with offset\n"

  "; copy loop\n"
  "GFX_clearWindowpaletteTableLoop:\n"
  "  write 0 r5 r0       ; clear tile\n"
  "  add r5 1 r5       ; incr vram address\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r4 2       ; keep looping until all tiles are cleared\n"
  "  jump GFX_clearWindowpaletteTableLoop\n"

  "; restore registers\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Clear Sprites
void GFX_clearSprites()
{
  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"
  "push r5\n"

  "; vram address\n"
  "load32 0xC02422 r1      ; r1 = vram addr 0xC02422\n"

  "; loop variables\n"
  "load 0 r3           ; r3 = loopvar\n"
  "load 64 r4     ; r4 = loopmax\n"
  "or r1 r0 r5         ; r5 = vram addr with offset\n"

  "; copy loop\n"
  "GFX_clearSpritesLoop:\n"
  "  write 0 r5 r0       ; clear x\n"
  "  write 1 r5 r0       ; clear y\n"
  "  write 2 r5 r0       ; clear tile\n"
  "  write 3 r5 r0       ; clear color+attrib\n"
  "  add r5 4 r5       ; incr vram address by 4\n"
  "  add r3 1 r3       ; incr counter\n"
  "  beq r3 r4 2       ; keep looping until all tiles are cleared\n"
  "  jump GFX_clearSpritesLoop\n"

  "; restore registers\n"
  "pop r5\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );
}


// Clear parameters
void GFX_clearParameters()
{
  asm(
  "; backup registers\n"
  "push r1\n"

  "; vram address\n"
  "load32 0xC02420 r1    ; r1 = vram addr 0xC02420\n"

  "write 0 r1 r0       ; clear tile scroll\n"
  "write 1 r1 r0       ; clear fine scroll\n"

  "; restore registers\n"
  "pop r1\n"
  );
}


// clears and initializes VRAM (excluding pattern and palette data table)
void GFX_initVram() 
{
  GFX_clearBGtileTable();
  GFX_clearBGpaletteTable();
  GFX_clearWindowtileTable();
  GFX_clearWindowpaletteTable();
  GFX_clearSprites();
  GFX_clearParameters();
}


// convert x and y to position for window table
word GFX_WindowPosFromXY(word x, word y)
{
  return y*40 + x;
}

// convert x and y to position for background table
word GFX_BackgroundPosFromXY(word x, word y)
{
  return y*64 + x;
}


// scrolls up screen, clearing last line
void GFX_ScrollUp()
{

  asm(
  "; backup registers\n"
  "push r1\n"
  "push r2\n"
  "push r3\n"
  "push r4\n"

  "; GFX_WINDOW_PATTERN_ADDR address\n"
  "load32 0xC01420 r1    ; r1 = window pattern addr 0xC01420\n"

  "load32 0 r2 ; r2 = loopvar\n"
  "load32 960 r3 ; r3 = loopmax\n"

  "GFX_scrollUpLoop:\n"
  "  read 40 r1 r4       ; read r1+40 to tmp r4\n"
  "  write 0 r1 r4       ; write tmp r4 to r1\n"
  "  add r1 1 r1       ; incr addr r1\n"
  "  add r2 1 r2       ; incr loopvar r2\n"
  "  beq r2 r3 2       ; keep looping for r3 times\n"
  "  jump GFX_scrollUpLoop\n"

  "load32 0 r2 ; r2 = loopvar\n"
  "load32 40 r3 ; r3 = loopmax\n"

  "GFX_clearLastLineLoop:\n"
  "  write 0 r1 r0       ; clear at r1\n"
  "  add r1 1 r1       ; incr addr r1\n"
  "  add r2 1 r2       ; incr loopvar r2\n"
  "  beq r2 r3 2       ; keep looping for r3 times\n"
  "  jump GFX_clearLastLineLoop\n"

  "; restore registers\n"
  "pop r4\n"
  "pop r3\n"
  "pop r2\n"
  "pop r1\n"
  );

}


// Prints cursor character at cursor
void GFX_printCursor()
{
  // print character at cursor
  word *v = (word *) GFX_WINDOW_PATTERN_ADDR;
  *(v+GFX_cursor) = GFX_CURSOR_ASCII;
}


// Prints character to console
// Handles scrolling, newline and backspace
// Uses cursor from memory
// TODO: could convert this to assembly for speed
void GFX_PrintcConsole(char c)
{
  // if newline
  if (c == 0xa)
  {
    // remove current cursor
    word *v = (word *) GFX_WINDOW_PATTERN_ADDR;
    *(v+GFX_cursor) = 0;

    // get next line number
    word nl = MATH_divU(GFX_cursor, 40) + 1;
    // multiply by 40 to get the correct line
    GFX_cursor = nl * 40;
  }

  // if backspace
  else if (c == 0x8)
  {
    // NOTE: by commenting this out it now is allowed to backspace to the previous line
    //  This is done since the shell checks for valid backspaces now,
    //  so we can remove multiline arguments

    // if we are not at the start of a line
    //if (MATH_mod(GFX_cursor, 40) != 0)

    // if we are not at the first character
    if ((unsigned int) GFX_cursor > 0)
    {
      // set current and previous character to 0
      word *v = (word *) GFX_WINDOW_PATTERN_ADDR;
      *(v+GFX_cursor) = 0;
      *(v+GFX_cursor-1) = 0;
      // decrement cursor
      GFX_cursor -= 1;
    }
  }

  // if\r
  else if (c == '\r')
  {
    // ignore
  }

  // else (character)
  else
  {
    // print character at cursor
    word *v = (word *) GFX_WINDOW_PATTERN_ADDR;
    *(v+GFX_cursor) = (word) c;
    // increment cursor
    GFX_cursor += 1;
  }


  // if we went offscreen, scroll screen up and set cursor to last line
  if ((unsigned int) GFX_cursor >= 1000)
  {
    GFX_ScrollUp();
    // set cursor to 960
    GFX_cursor = 960;
  }

  // add cursor at end
  GFX_printCursor();
}


// Prints string on console untill terminator
// Does not add newline at end
// TODO: could convert this to assembly for speed
void GFX_PrintConsole(char* str)
{
  char chr = *str;      // first character of str

  while (chr != 0)      // continue until null value
  {
    GFX_PrintcConsole((word)chr);
    str++;          // go to next character address
    chr = *str;       // get character from address
  }
}

// Clears console by removing all tiles and resetting the cursor
void GFX_clearConsole()
{
  GFX_clearWindowtileTable();
  GFX_clearBGtileTable();
  GFX_cursor = 0;
}