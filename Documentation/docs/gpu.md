# GPU (FSX2)

!!! danger
    Almost all of this is outdated now, since I have changed video outputs multiple times now. I now have HDMI output (640x480) and 240P NTSC composite, so no VGA or RGBs anymore.

The GPU generates a progressive 320x200@60hz RGBs signal using a pixel clock of ~6.944MHz.
It uses a tile based rendering system inspired by the NES PPU in order to prevent having to use a frame buffer and therefore save video RAM (since the FPGA only has ~64KB of SRAM/block RAM). Tile rendering works as follows:


## Tile based rendering process
For each tile, the GPU has to read the following tables in order to know which color to draw (in the following order):

- BG Tile table
- Pattern table
- BG Color table
- Palette table
- Window Tile table
- Pattern table
- Window Color table
- Palette table

The Pattern table allows for 256 different tiles on a single screen.

The Palette table allows for 32 different palettes per screen with four colors per palette.

Each address in the tile tables and the color tables is mapped to one tile on screen.

Two layers of tiles are rendered, the background layer which can be scrolled horizontally and the window layer, which draws on top of the background layer and does not scroll.

Aside from the tiles in the two layers, the GPU also renders Sprites as a third layer, which are basically just tiles which can be placed at any position (so without snapping to a grid). These are way more expensive to render and therefore have more constraints (see section Sprites).

## Background layer
The background layer consists of 512x200 pixels. They are indexed by tiles of 8x8 pixels making 64x25 tiles. The background is horizontally scrollable by using the tile offset parameter and fine offset parameter. The tile offset parameter specifies how many tiles the background has to be scrolled to the left. The fine offset parameter specifies how many pixels (ranging from 0 to 7) the background has to be scrolled to the left. The background wraps around horizontally. This means no vertical scrolling (in hardware).

## Window layer
The window layer consists of 320x200 pixels. They are indexed by tiles of 8x8 pixels making 40x25 tiles. The window is not scrollable and is rendered above the background. When a pixel is black, it will not be rendered which makes the background visible. The window is especially useful for static UI things like text, score and a life bar for example.

## Sprites
The sprite layer can consist of a maximum of 64 sprites. Only 16 of these sprites (which is double the amount a NES can render!) can be rendered on the same horizontal line. Each sprite has four different addresses that can be written to, with the following functions:
1. X position (9 bits)
2. Y position (8 bits)
3. Tile index (8 bits)
4. Color index (5 bits), hflip, vflip, priority, disable (all 1 bit)
hflip, vflip, priority and disable are currently not implemented.
The sprites are rendered on top of the window and background layers. When a pixel is black, it will not be rendered which makes the window or background visible. Sprites are useful for things that move per pixel on the screen independently, such as the ball in pong or a mouse cursor.


## Video timing
The timing of the video signal is as follows:
``` text
H_RES   = 320,      // horizontal resolution (pixels)
V_RES   = 200,      // vertical resolution (lines)
H_FP    = 34,       // horizontal front porch
H_SYNC  = 32,       // horizontal sync
H_BP    = 56,       // horizontal back porch
V_FP    = 23,       // vertical front porch
V_SYNC  = 5,        // vertical sync
V_BP    = 34,       // vertical back porch
H_POL   = 0,        // horizontal sync polarity (0:neg, 1:pos)
V_POL   = 0;        // vertical sync polarity

H_TOTAL = 320+34+32+56  = 442 //Horizontal total pixels
V_TOTAL = 200+23+5+34   = 262 //Vertical total lines

442 pixels * 262 lines * 60 FPS = 6.948240 MHz (6.944MHz works fine)
```
A PLL is responsible for generating the GPU clock from 50MHz.