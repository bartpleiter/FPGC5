; GFX library
; Defines basic functions for display graphics operations

define GFX_PATTERN_TABLE_SIZE       = 1024      ; size of pattern table
define GFX_PALETTE_TABLE_SIZE       = 32        ; size of palette table
define GFX_WINDOW_TILES             = 1920      ; number of tiles in window plane
define GFX_BG_TILES                 = 2048      ; number of tiles in bg plane
define GFX_SPRITES                  = 64        ; number of sprites in spriteVRAM

; Prints to screen in window plane, with color, data is accessed in bytes
; Reads each word from left to right
; INPUT:
;   r1 = address of data to print
;   r2 = length of data
;   r3 = position on screen
;   r4 = palette index
GFX_printWindowColored:
    ; backup registers
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10

    ; vram address
    load32 0xC01420 r10               ; r10 = vram addr 1056+4096 0xC01420             

    ; loop variables
    load 0 r5                       ; r5 = loopvar
    or r10 r0 r6                    ; r6 = vram addr with offset
    or r1 r0 r7                     ; r7 = data addr with offset
    load 32 r8                      ; r8 = shift variable

    add r3 r6 r6                    ; apply offset from r3

    ; copy loop
    GFX_printWindowColoredLoop:
        sub r8 8 r8             ; remove 8 from shift variable
        read 0 r7 r9            ; read 32 bits
        shiftr r9 r8 r9         ; shift to right
        write 0 r6 r9           ; write char to vram
        write 2048 r6 r4        ; write palette index to vram
        add r6 1 r6             ; incr vram address

        bne r0 r8 3             ; if we shifted the last byte
            add r7 1 r7             ; incr data address 
            load 32 r8              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all data is copied
        jump GFX_printWindowColoredLoop

    ; restore registers
    pop r10
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5

    ; return
    pop r15
    jumpr 3 r15


; Prints to screen in window plane, data is accessed in bytes
; Reads each word from left to right
; INPUT:
;   r1 = address of data to print
;   r2 = length of data
;   r3 = position on screen
GFX_printWindow:
    ; backup registers
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9

    ; vram address
    load32 0xC01420 r4                ; r10 = vram addr 1056+4096 0xC01420             

    ; loop variables
    load 0 r5                       ; r5 = loopvar
    or r4 r0 r6                     ; r6 = vram addr with offset
    or r1 r0 r7                     ; r7 = data addr with offset
    load 32 r8                      ; r8 = shift variable

    add r3 r6 r6                    ; apply offset from r3

    ; copy loop
    GFX_printWindowLoop:
        sub r8 8 r8             ; remove 8 from shift variable
        read 0 r7 r9            ; read 32 bits
        shiftr r9 r8 r9         ; shift to right
        write 0 r6 r9           ; write char to vram
        add r6 1 r6             ; incr vram address

        bne r0 r8 3             ; if we shifted the last byte
            add r7 1 r7             ; incr data address 
            load 32 r8              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all data is copied
        jump GFX_printWindowLoop

    ; restore registers
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4

    ; return
    pop r15
    jumpr 3 r15
   

; Prints to screen in BG plane, with color, data is accessed in bytes
; Reads each word from left to right
; INPUT:
;   r1 = address of data to print
;   r2 = length of data
;   r3 = position on screen
;   r4 = palette index
GFX_printBGColored:
    ; backup registers
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10

    ; vram address
    load32 0xC00420 r10               ; r10 = vram addr 1056 0xC00420               

    ; loop variables
    load 0 r5                       ; r5 = loopvar
    or r10 r0 r6                    ; r6 = vram addr with offset
    or r1 r0 r7                     ; r7 = data addr with offset
    load 32 r8                      ; r8 = shift variable

    add r3 r6 r6                    ; apply offset from r3

    ; copy loop
    GFX_printBGColoredLoop:
        sub r8 8 r8             ; remove 8 from shift variable
        read 0 r7 r9            ; read 32 bits
        shiftr r9 r8 r9         ; shift to right
        write 0 r6 r9           ; write char to vram
        write 2048 r6 r4        ; write palette index to vram
        add r6 1 r6             ; incr vram address

        bne r0 r8 3             ; if we shifted the last byte
            add r7 1 r7             ; incr data address 
            load 32 r8              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all data is copied
        jump GFX_printBGColoredLoop

    ; restore registers
    pop r10
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5

    ; return
    pop r15
    jumpr 3 r15


; Prints to screen in window plane, data is accessed in bytes
; Reads each word from left to right
; INPUT:
;   r1 = address of data to print
;   r2 = length of data
;   r3 = position on screen
GFX_printBG:
    ; backup registers
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9

    ; vram address
    load32 0xC00420 r4                ; r10 = vram addr 1056 0xC00420       

    ; loop variables
    load 0 r5                       ; r5 = loopvar
    or r4 r0 r6                     ; r6 = vram addr with offset
    or r1 r0 r7                     ; r7 = data addr with offset
    load 32 r8                      ; r8 = shift variable

    add r3 r6 r6                    ; apply offset from r3

    ; copy loop
    GFX_printBGLoop:
        sub r8 8 r8             ; remove 8 from shift variable
        read 0 r7 r9            ; read 32 bits
        shiftr r9 r8 r9         ; shift to right
        write 0 r6 r9           ; write char to vram
        add r6 1 r6             ; incr vram address

        bne r0 r8 3             ; if we shifted the last byte
            add r7 1 r7             ; incr data address 
            load 32 r8              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all data is copied
        jump GFX_printBGLoop

    ; restore registers
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4

    ; return
    pop r15
    jumpr 3 r15


; Initialize VRAM by clearing all VRAM except pattern and palette table
GFX_initVram:
    savpc r15
    push r15
    jump GFX_clearBGtileTable

    savpc r15
    push r15
    jump GFX_clearBGpaletteTable

    savpc r15
    push r15
    jump GFX_clearWindowtileTable

    savpc r15
    push r15
    jump GFX_clearWindowpaletteTable

    savpc r15
    push r15
    jump GFX_clearSprites

    savpc r15
    push r15
    jump GFX_clearParameters

    ; return
    pop r15
    jumpr 3 r15
  

; Loads entire pattern table
; INPUT:
;   r1 = address of pattern table to copy
GFX_copyPatternTable:
    ; backup registers
    push r2
    push r3
    push r4
    push r5
    push r6

    ; vram address
    load32 0xC00000 r2                ; r2 = vram addr 0 0xC00000               

    ; loop variables
    load 0 r3                       ; r3 = loopvar
    load GFX_PATTERN_TABLE_SIZE r4  ; r4 = loopmax
    or r2 r0 r5                     ; r5 = vram addr with offset
    or r1 r0 r6                     ; r6 = ascii addr with offset

    ; copy loop
    GFX_initPatternTableLoop:
        copy 0 r6 r5            ; copy ascii to vram
        add r5 1 r5             ; incr vram address
        add r6 1 r6             ; incr ascii address 
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all data is copied
        jump GFX_initPatternTableLoop

    ; restore registers
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Loads entire palette table
; INPUT:
;   r1 = address of palette table to copy
GFX_copyPaletteTable:
    ; backup registers
    push r2
    push r3
    push r4
    push r5
    push r6

    ; vram address
    load32 0xC00400 r2                ; r2 = vram addr 1024 0xC00400

    ; loop variables
    load 0 r3                       ; r3 = loopvar
    load GFX_PALETTE_TABLE_SIZE r4  ; r4 = loopmax
    or r2 r0 r5                     ; r5 = vram addr with offset
    or r1 r0 r6                     ; r6 = palette addr with offset

    ; copy loop
    GFX_initPaletteTableLoop:
        copy 0 r6 r5            ; copy palette to vram
        add r5 1 r5             ; incr vram address
        add r6 1 r6             ; incr palette address 
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all data is copied
        jump GFX_initPaletteTableLoop

    ; restore registers
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; Clear BG tile table
GFX_clearBGtileTable:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5

    ; vram address
    load32 0xC00420 r1        ; r1 = vram addr 1056 0xC00420         

    ; loop variables
    load 0 r3               ; r3 = loopvar
    load GFX_BG_TILES r4    ; r4 = loopmax
    or r1 r0 r5             ; r5 = vram addr with offset

    ; copy loop
    GFX_clearBGtileTableLoop:
        write 0 r5 r0           ; clear tile
        add r5 1 r5             ; incr vram address
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all tiles are cleared
        jump GFX_clearBGtileTableLoop

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15
  

; Clear BG palette table
GFX_clearBGpaletteTable:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5

    ; vram address
    load32 0xC00C20 r1        ; r1 = vram addr 1056+2048 0xC00C20       

    ; loop variables
    load 0 r3               ; r3 = loopvar
    load GFX_BG_TILES r4    ; r4 = loopmax
    or r1 r0 r5             ; r5 = vram addr with offset

    ; copy loop
    GFX_clearBGpaletteTableLoop:
        write 0 r5 r0           ; clear tile
        add r5 1 r5             ; incr vram address
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all tiles are cleared
        jump GFX_clearBGpaletteTableLoop

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Clear Window tile table
GFX_clearWindowtileTable:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5

    ; vram address
    load32 0xC01420 r1        ; r1 = vram addr 1056+2048 0xC01420

    ; loop variables
    load 0 r3               ; r3 = loopvar
    load GFX_WINDOW_TILES r4    ; r4 = loopmax
    or r1 r0 r5             ; r5 = vram addr with offset

    ; copy loop
    GFX_clearWindowtileTableLoop:
        write 0 r5 r0           ; clear tile
        add r5 1 r5             ; incr vram address
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all tiles are cleared
        jump GFX_clearWindowtileTableLoop

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15
  

; Clear Window palette table
GFX_clearWindowpaletteTable:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5

    ; vram address
    load32 0xC01C20 r1        ; r1 = vram addr 1056+2048 0xC01C20 

    ; loop variables
    load 0 r3               ; r3 = loopvar
    load GFX_WINDOW_TILES r4    ; r4 = loopmax
    or r1 r0 r5             ; r5 = vram addr with offset

    ; copy loop
    GFX_clearWindowpaletteTableLoop:
        write 0 r5 r0           ; clear tile
        add r5 1 r5             ; incr vram address
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all tiles are cleared
        jump GFX_clearWindowpaletteTableLoop

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Clear Sprites
GFX_clearSprites:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5

    ; vram address
    load32 0xC02632 r1        ; r1 = vram addr 0xC02632     

    ; loop variables
    load 0 r3               ; r3 = loopvar
    load GFX_SPRITES r4     ; r4 = loopmax
    or r1 r0 r5             ; r5 = vram addr with offset

    ; copy loop
    GFX_clearSpritesLoop:
        write 0 r5 r0           ; clear x
        write 1 r5 r0           ; clear y
        write 2 r5 r0           ; clear tile
        write 3 r5 r0           ; clear color+attrib
        add r5 4 r5             ; incr vram address by 4
        add r3 1 r3             ; incr counter
        beq r3 r4 2             ; keep looping until all tiles are cleared
        jump GFX_clearSpritesLoop

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15

; Clear parameters
GFX_clearParameters:
    ; backup registers
    push r1

    ; vram address
    load32 0xC02420 r1        ; r1 = vram addr 0xC02420

    write 0 r1 r0           ; clear tile scroll
    write 1 r1 r0           ; clear fine scroll

    ; restore registers
    pop r1

    ; return
    pop r15
    jumpr 3 r15
