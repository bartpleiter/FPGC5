/*
* Graphics library
* Mostly Assembly code, because efficiency in both space and time
* Int arguments from C are stored in order of r5, r4, r3, r2, (r1?)
*/

// Workaround to allow for defines in ASM functions
void GFX_asmDefines()
{
	ASM("\
	define GFX_PATTERN_TABLE_SIZE       = 1024      // size of pattern table ;\
	define GFX_PALETTE_TABLE_SIZE       = 32        // size of palette table ;\
	define GFX_WINDOW_TILES             = 1920      // number of tiles in window plane ;\
	define GFX_BG_TILES                 = 2048      // number of tiles in bg plane ;\
	define GFX_SPRITES                  = 64        // number of sprites in spriteVRAM ;\
    ");
}


// Prints to screen in window plane, with color, data is accessed in words
// INPUT:
//   r5 = address of data to print
//   r4 = length of data
//   r3 = position on screen
//   r2 = palette index
void GFX_printWindowColored(int addr, int len, int pos, int palette)
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r6								;\
    push r7								;\
    push r8								;\
    push r9								;\
    push r10							;\
										;\
    // vram address						;\
    load32 0xC01420 r10             // r10 = vram addr 1056+4096 0xC01420		;\
																				;\
    // loop variables															;\
    load 0 r1                       // r1 = loopvar								;\
    or r10 r0 r6                    // r6 = vram addr with offset				;\
    or r5 r0 r7                     // r7 = data addr with offset				;\
																				;\
    add r3 r6 r6                    // apply offset from r3						;\
																				;\
    // copy loop																;\
    GFX_printWindowColoredLoop:													;\
        read 0 r7 r9            // read 32 bits									;\
        write 0 r6 r9           // write char to vram							;\
        write 2048 r6 r2        // write palette index to vram					;\
        add r6 1 r6             // incr vram address							;\
        add r7 1 r7             // incr data address 							;\
        add r1 1 r1             // incr counter									;\
        bge r1 r4 2             // keep looping until all data is copied		;\
        jump GFX_printWindowColoredLoop											;\
																				;\
    // restore registers														;\
    pop r10					;\
    pop r9					;\
    pop r8					;\
    pop r7					;\
    pop r6					;\
    pop r1					;\
    ");
}


// Prints to screen in background plane, with color, data is accessed in words
// INPUT:
//   r5 = address of data to print
//   r4 = length of data
//   r3 = position on screen
//   r2 = palette index
void GFX_printBGColored(int addr, int len, int pos, int palette)
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r6								;\
    push r7								;\
    push r8								;\
    push r9								;\
    push r10							;\
										;\
    // vram address						;\
    load32 0xC00420 r10             // r10 = vram addr 1056 0xC00420			;\
																				;\
    // loop variables															;\
    load 0 r1                       // r1 = loopvar								;\
    or r10 r0 r6                    // r6 = vram addr with offset				;\
    or r5 r0 r7                     // r7 = data addr with offset				;\
																				;\
    add r3 r6 r6                    // apply offset from r3						;\
																				;\
    // copy loop																;\
    GFX_printBGColoredLoop:														;\
        read 0 r7 r9            // read 32 bits									;\
        write 0 r6 r9           // write char to vram							;\
        write 2048 r6 r2        // write palette index to vram					;\
        add r6 1 r6             // incr vram address							;\
        add r7 1 r7             // incr data address 							;\
        add r1 1 r1             // incr counter									;\
        bge r1 r4 2             // keep looping until all data is copied		;\
        jump GFX_printBGColoredLoop												;\
																				;\
    // restore registers														;\
    pop r10					;\
    pop r9					;\
    pop r8					;\
    pop r7					;\
    pop r6					;\
    pop r1					;\
    ");
}


// Loads entire pattern table
// INPUT:
//   r5 = address of pattern table to copy
void GFX_copyPatternTable(int addr)
{
	ASM("\
    // backup registers					;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r1								;\
    push r6								;\
										;\
    // vram address						;\
    load32 0xC00000 r2          	// r2 = vram addr 0 0xC00000  					;\
																					;\
    // loop variables																;\
    load 0 r3                       // r3 = loopvar									;\
    load GFX_PATTERN_TABLE_SIZE r4  // r4 = loopmax									;\
    or r2 r0 r1                     // r1 = vram addr with offset					;\
    add r5 4 r6                     // r6 = ascii addr with offset					;\
																					;\
    // copy loop																	;\
    GFX_initPatternTableLoop:														;\
        copy 0 r6 r1            // copy ascii to vram								;\
        add r1 1 r1             // incr vram address								;\
        add r6 1 r6             // incr ascii address 								;\
        add r3 1 r3             // incr counter										;\
        beq r3 r4 2             // keep looping until all data is copied			;\
        jump GFX_initPatternTableLoop												;\
							;\
    // restore registers	;\
    pop r6					;\
    pop r1					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    ");
}



// Loads entire palette table
// INPUT:
//   r5 = address of palette table to copy
void GFX_copyPaletteTable(int addr)
{
	ASM("\
    // backup registers					;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r1								;\
    push r6								;\
										;\
    // vram address						;\
    load32 0xC00400 r2          // r2 = vram addr 1024 0xC00400  					;\
																					;\
    // loop variables																;\
    load 0 r3                       // r3 = loopvar									;\
    load GFX_PALETTE_TABLE_SIZE r4  // r4 = loopmax									;\
    or r2 r0 r1                     // r1 = vram addr with offset					;\
    add r5 4 r6                     // r6 = palette addr with offset				;\
																					;\
    // copy loop																	;\
    GFX_initPaletteTableLoop:														;\
        copy 0 r6 r1            // copy palette to vram								;\
        add r1 1 r1             // incr vram address								;\
        add r6 1 r6             // incr palette address 							;\
        add r3 1 r3             // incr counter										;\
        beq r3 r4 2             // keep looping until all data is copied			;\
        jump GFX_initPaletteTableLoop												;\
							;\
    // restore registers	;\
    pop r6					;\
    pop r1					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    ");
}


// Clear BG tile table
void GFX_clearBGtileTable()
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r5								;\
										;\
    // vram address						;\
    load32 0xC00420 r1        // r1 = vram addr 1056 0xC00420  						;\
																					;\
    // loop variables																;\
    load 0 r3               	// r3 = loopvar										;\
    load GFX_BG_TILES r4    	// r4 = loopmax										;\
    or r1 r0 r5             	// r5 = vram addr with offset						;\
																					;\
    // copy loop																	;\
    GFX_clearBGtileTableLoop:														;\
        write 0 r5 r0           // clear tile										;\
        add r5 1 r5             // incr vram address								;\
        add r3 1 r3             // incr counter										;\
        beq r3 r4 2             // keep looping until all tiles are cleared			;\
        jump GFX_clearBGtileTableLoop												;\
							;\
    // restore registers	;\
    pop r5					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    pop r1					;\
    ");
}


// Clear BG palette table
void GFX_clearBGpaletteTable()
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r5								;\
										;\
    // vram address						;\
    load32 0xC00C20 r1        // r1 = vram addr 1056+2048 0xC00C20 					;\
																					;\
    // loop variables																;\
    load 0 r3               	// r3 = loopvar										;\
    load GFX_BG_TILES r4    	// r4 = loopmax										;\
    or r1 r0 r5             	// r5 = vram addr with offset						;\
																					;\
    // copy loop																	;\
    GFX_clearBGpaletteTableLoop:													;\
        write 0 r5 r0           // clear tile										;\
        add r5 1 r5             // incr vram address								;\
        add r3 1 r3             // incr counter										;\
        beq r3 r4 2             // keep looping until all tiles are cleared			;\
        jump GFX_clearBGpaletteTableLoop											;\
							;\
    // restore registers	;\
    pop r5					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    pop r1					;\
    ");
}


// Clear Window tile table
void GFX_clearWindowtileTable()
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r5								;\
										;\
    // vram address						;\
    load32 0xC01420 r1        // r1 = vram addr 1056+2048 0xC01420					;\
																					;\
    // loop variables																;\
    load 0 r3               	// r3 = loopvar										;\
    load GFX_WINDOW_TILES r4    // r4 = loopmax										;\
    or r1 r0 r5             	// r5 = vram addr with offset						;\
																					;\
    // copy loop																	;\
    GFX_clearWindowtileTableLoop:													;\
        write 0 r5 r0           // clear tile										;\
        add r5 1 r5             // incr vram address								;\
        add r3 1 r3             // incr counter										;\
        beq r3 r4 2             // keep looping until all tiles are cleared			;\
        jump GFX_clearWindowtileTableLoop											;\
							;\
    // restore registers	;\
    pop r5					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    pop r1					;\
    ");
}


// Clear Window palette table
void GFX_clearWindowpaletteTable()
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r5								;\
										;\
    // vram address						;\
    load32 0xC01C20 r1        // r1 = vram addr 1056+2048 0xC01C20 					;\
																					;\
    // loop variables																;\
    load 0 r3               	// r3 = loopvar										;\
    load GFX_WINDOW_TILES r4    // r4 = loopmax										;\
    or r1 r0 r5             	// r5 = vram addr with offset						;\
																					;\
    // copy loop																	;\
    GFX_clearWindowpaletteTableLoop:												;\
        write 0 r5 r0           // clear tile										;\
        add r5 1 r5             // incr vram address								;\
        add r3 1 r3             // incr counter										;\
        beq r3 r4 2             // keep looping until all tiles are cleared			;\
        jump GFX_clearWindowpaletteTableLoop										;\
																					;\
    // restore registers	;\
    pop r5					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    pop r1					;\
    ");
}


// Clear Sprites
void GFX_clearSprites()
{
	ASM("\
    // backup registers					;\
    push r1								;\
    push r2								;\
    push r3								;\
    push r4								;\
    push r5								;\
										;\
    // vram address						;\
    load32 0xC02422 r1        // r1 = vram addr 0xC02422     					;\
																				;\
    // loop variables															;\
    load 0 r3               // r3 = loopvar										;\
    load GFX_SPRITES r4     // r4 = loopmax										;\
    or r1 r0 r5             // r5 = vram addr with offset						;\
																				;\
    // copy loop																;\
    GFX_clearSpritesLoop:														;\
        write 0 r5 r0           // clear x										;\
        write 1 r5 r0           // clear y										;\
        write 2 r5 r0           // clear tile									;\
        write 3 r5 r0           // clear color+attrib							;\
        add r5 4 r5             // incr vram address by 4						;\
        add r3 1 r3             // incr counter									;\
        beq r3 r4 2             // keep looping until all tiles are cleared		;\
        jump GFX_clearSpritesLoop												;\
							;\
    // restore registers	;\
    pop r5					;\
    pop r4					;\
    pop r3					;\
    pop r2					;\
    pop r1					;\
    ");
}


// Clear parameters
void GFX_clearParameters()
{
	ASM("\
    // backup registers 								;\
    push r1 											;\
    													;\
    // vram address 									;\
    load32 0xC02420 r1      // r1 = vram addr 0xC02420 	;\
    													;\
    write 0 r1 r0           // clear tile scroll 		;\
    write 1 r1 r0           // clear fine scroll 		;\
    													;\
    // restore registers 								;\
    pop r1 												;\
    ");
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
int GFX_WindowPosFromXY(int x, int y)
{
    return y*40 + x;
}

// convert x and y to position for background table
int GFX_BackgroundPosFromXY(int x, int y)
{
    return y*64 + x;
}