# Memory map
The FPGC4 uses two memory maps to access all different types of memory and I/O.
One map is used by the CPU (and implemented by the MU) and the other map is used by the GPU. The GPU memory map is only useful when developing the GPU (in Verilog), so for writing code, you only need to understand the CPU memory map.

## CPU memory map
When the CPU gets a `READ`, `WRITE` or `COPY` instruction, it will use the following memory map. This means that, for example, reading from address `0xC02622` will read the button states of the (S)NES controller, and writing to address `0xC0041F` will write an entry in the Palette Table for the GPU.
Note: the memory map has been rearranged since the second version of the I/O Board. This means that older code that has not been updated will not work anymore.

``` text
$000000 +------------------------+ 
        |                        | 
        |         SDRAM          | 
        |                        | $7FFFFF 
$800000 +------------------------+ 
        |                        | 
        |       SPI FLASH        | 
        |                        | $BFFFFF 
$C00000 +------------------------+ 
        |                        | 
        |         VRAM32         | 
        |                        | 
        | $C00000                | 
        |     Pattern Table      | 
        |                $C003FF | 
        |                        | 
        | $C04000                | 
        |     Palette Table      | 
        |                $C0041F | 
        |                        | $C0041F 
$C00420 +------------------------+ 
        |                        | 
        |         VRAM8          | 
        |                        | 
        | $C00420                | 
        |    BG Pattern Table    | 
        |                $C00C1F | 
        |                        | 
        | $C00C20                | 
        |    BG Palette Table    | 
        |                $C0141F | 
        |                        |
        | $C01420                | 
        |  Window Pattern Table  | 
        |                $C01C1F | 
        |                        | 
        | $C01C20                | 
        |  Window Palette Table  | 
        |                $C0241F | 
        | $C02420                | 
        |       Parameters       | 
        |                $C02421 |  
        |                        | $C02421 
$C02422 +------------------------+ 
        |                        |
        |       SpriteVRAM       |
        |                        | $C02521 
$C02522 +------------------------+ 
        |                        | 
        |          ROM           |
        |                        | $C02721
$C02722 +------------------------+ 
        |                        | 
        |          I/O           | 
        |                        |
        | UART0 RX (MAIN)$C02722 |
        | UART0 TX (MAIN)$C02723 |
        | UART1 RX (APU) $C02724 |
        | UART1 TX (APU) $C02725 |
        | UART2 RX (EXT) $C02726 |
        | UART2 TX (EXT) $C02727 |
        | SPI0   (FLASH) $C02728 |
        | SPI0_CS        $C02729 |
        | SPI0_ENABLE    $C0272A |
        | SPI1 (CH376_0) $C0272B |
        | SPI1_CS        $C0272C |
        | SPI1_nINT      $C0272D |
        | SPI2 (CH376_1) $C0272E |
        | SPI2_CS        $C0272F |
        | SPI2_nINT      $C02730 |
        | SPI3   (W5500) $C02731 |
        | SPI3_CS        $C02732 |
        | SPI3_INT       $C02733 |
        | SPI4     (EXT) $C02734 |
        | SPI4_CS        $C02735 |
        | SPI4_GP        $C02736 |
        | GPIO           $C02737 |
        | GPIO_DIR       $C02738 |
        | Timer1_val     $C02739 |
        | Timer1_ctrl    $C0273A |
        | Timer2_val     $C0273B |
        | Timer2_ctrl    $C0273C |
        | Timer3_val     $C0273D |
        | Timer3_ctrl    $C0273E |
        | SNESpad        $C0273F |
        | PS/2 Keyboard  $C02740 |
        | BOOT_MODE      $C02741 |
        +------------------------+ $C02741

```

## GPU memory map
This memory map is only used in the GPU. These are basically the content read from the GPU port of VRAM. This map is only internal to the GPU hardware, and should/can not be used when writing code (use the CPU memory map instead for this!). This map is only useful when making modifications to the GPU in Verilog.
``` text
VRAM32
$000  +------------------------+ 
      |                        | 
      |     Pattern Table      | 
      |                        | $3FF
$400  +------------------------+ 
      |                        |
      |     Palette Table      |
      |                        | $41F
      +------------------------+


VRAM8
$000  +------------------------+
      |                        | 
      |     BG Tile Table      | 
      |                        | $7FF
$800  +------------------------+ 
      |                        |
      |     BG Color Table     |
      |                        | $FFF
$1000 +------------------------+
      |                        | 
      |   Window Tile Table    | 
      |                        | $17FF
$1800 +------------------------+ 
      |                        |
      |   Window Color Table   |
      |                        | $1FFF
$2000 +------------------------+
      |                        |
      |       Parameters       |
      |                        | $2001
      +------------------------+

SpriteVRAM
$000  +------------------------+
      |                        | 
      |    %0: X pos           | 
      |    %1: Y pos           | 
      |    %2: Tile            | 
      |    %3: Palette+flags   | 
      |                        | $FF
      +------------------------+ 
```