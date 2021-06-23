; Big System Test Program
;
; Tests:
;   - GPI[0] (for advancing the tests)
;   - Display
;       * Tiles
;       * Sprites
;       * Layers
;       * Colors
;       * Scrolling
;   - Audio
;   - USB host
;       * Read file
;       * Write file
;   - SNES controller
;   - PS/2 Keyboard
;   - Timers
;   - UART
;       * TX only


; Program variables starting from address 0x80000 (2MiB)
; 0x80000 test state

`include lib/CH376.asm
`include lib/UART.asm
`include lib/STD.asm
`include lib/GFX.asm
`include testData/testData.asm

; Test states
define TEST_STATE_PRINT_TEXT        = 0
define TEST_STATE_BG_SCROLL         = 1
define TEST_STATE_SPRITES           = 2
define TEST_STATE_COLOR1            = 3
define TEST_STATE_COLOR2            = 4
define TEST_STATE_AUDIO             = 5
define TEST_STATE_USB               = 6

Main:
    ; set test state
    load32 0x80000 r1
    load TEST_STATE_PRINT_TEXT r2
    write 0 r1 r2

    ; test display
    savpc r15
    push r15
    jump Test_display

    ; test colors
    savpc r15
    push r15
    jump Test_colors

    ; test audio
    savpc r15
    push r15
    jump Test_audio

    ; test usb
    savpc r15
    push r15
    jump Test_usb

    halt


; Tests usb
Test_usb:
    nop

    ; keep waiting until the state has advanced to audio test
    Test_usb_wait_for_button_1:
        nop

    load32 0x80000 r1
    read 0 r1 r2
    load TEST_STATE_USB r1 
    bne r2 r1 2
        jump Test_usb_part_1

    savpc r15
    push r15
    jump Test_wait_for_button_press  
    jump Test_usb_wait_for_button_1


    Test_usb_part_1:
        nop

    ; clear previous info message
    addr2reg TEST_INFO_CLEAR r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 40 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print new message to top of screen
    addr2reg TEST_INFO_USB r2       ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 52 r3                          ; offset from start (40 per line)
    load 0 r4                         ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print UART message
    addr2reg TEST_INFO_UART r2       ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 172 r3                          ; offset from start (40 per line)
    load 0 r4                         ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored


    ; init controller
    savpc r15
    push r15
    jump CH376_init

    ; checks and mounts drive
    savpc r15
    push r15
    jump CH376_Check_drive

    ; read filename argument
    addr2reg CH376_Test_Name r1
    read 0 r1 r2
    add r1 1 r1

    ; send filename
    savpc r15
    push r15
    jump CH376_Send_filename

    ;savpc r15
    ;push r15
    ;jump CH376_Create_file

    savpc r15
    push r15
    jump CH376_Open_file

    ; read the file
    ; set location of data for reading
    load32 0x80001 r1
    load 16 r2          ; read 16 bytes
    savpc r15
    push r15
    jump CH376_Read_file


    ; set cursor to end
    load 0xffff r1
    loadhi 0xffff r1
    savpc r15
    push r15
    jump CH376_Set_cursor

    ; set write data and length args
    addr2reg CH376_Test_String r1
    read 0 r1 r2
    add r1 1 r1

    savpc r15
    push r15
    jump CH376_Write_file


    savpc r15
    push r15
    jump CH376_Close_file


    load32 0x80001 r1                 ; start of text data
    load 16 r2                        ; length of data
    load 653 r3                       ; offset from start (40 per line)
    load 0 r4                         ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; return
    pop r15
    jumpr 3 r15







; Tests audio
Test_audio:
    nop

    ; keep waiting until the state has advanced to audio test
    Test_audio_wait_for_button_1:
        nop

    load32 0x80000 r1
    read 0 r1 r2
    load TEST_STATE_AUDIO r1 
    bne r2 r1 2
        jump Test_audio_part_1

    savpc r15
    push r15
    jump Test_wait_for_button_press  
    jump Test_audio_wait_for_button_1


    Test_audio_part_1:
        nop

    ; clear VRAM
    savpc r15
    push r15
    jump GFX_initVram

    ; load standard palette table and copy to VRAM
    addr2reg TEST_ASCII_PALETTETABLE r1 

    savpc r15
    push r15
    jump GFX_copyPaletteTable


    ; clear previous info message
    addr2reg TEST_INFO_CLEAR r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 40 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print new message to top of screen
    addr2reg TEST_INFO_AUDIO r2       ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 48 r3                          ; offset from start (40 per line)
    load 0 r4                         ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    load32 0xC0262C r1  ; 0xC0262C toneplayer 1, 262D = toneplayer 2

    ; right hand: C; 72 67 64 60        0x4843403C
    ; left hand: C; 0 0 48 36           0x3024

    ; r: 68 63 56           0x443F3800
    ; l: 44 39 32           0x2C2720
    ; r: 58                 0x3A
    ; l: 39 34 27           0x27221B



    load32 0x44000000 r2
    write 0 r1 r2
    load32 0x2C2720 r3
    write 1 r1 r3

    ; simple wait loop before adding a note
    load32 250000 r4
    Test_audio_wait_loop1:
        sub r4 1 r4
        beq r0 r4 2         ; keep looping until r1 reached zero
            jump Test_audio_wait_loop1

    
    load32 0x443F0000 r2
    write 0 r1 r2

    ; simple wait loop before adding a note
    load32 250000 r4
    Test_audio_wait_loop2:
        sub r4 1 r4
        beq r0 r4 2         ; keep looping until r1 reached zero
            jump Test_audio_wait_loop2
    
    load32 0x443F3800 r2
    write 0 r1 r2

    ; simple wait loop before adding a note
    load32 250000 r4
    Test_audio_wait_loop3:
        sub r4 1 r4
        beq r0 r4 2         ; keep looping until r1 reached zero
            jump Test_audio_wait_loop3
    
    load32 0x3A r2
    write 0 r1 r2
    load32 0x27221B r3
    write 1 r1 r3

    ; simple wait loop before stopping sound
    load32 600000 r4
    Test_audio_wait_loop4:
        sub r4 1 r4
        beq r0 r4 2         ; keep looping until r1 reached zero
            jump Test_audio_wait_loop4

    write 0 r1 r0
    write 1 r1 r0

    ; return
    pop r15
    jumpr 3 r15






; Tests colors
Test_colors:
    nop

    ; keep waiting until the state has advanced to first color test
    Test_colors_wait_for_button_1:
        nop

    load32 0x80000 r1
    read 0 r1 r2
    load TEST_STATE_COLOR1 r1 
    bne r2 r1 2
        jump Test_colors_part_1

    savpc r15
    push r15
    jump Test_wait_for_button_press  
    jump Test_colors_wait_for_button_1


    Test_colors_part_1:
        nop

    ; clear VRAM (without pattern and palette table)
    savpc r15
    push r15
    jump GFX_initVram

    ; load palette table for color test and copy to VRAM
    addr2reg TEST_COLOR_PALETTETABLE_1 r1 

    savpc r15
    push r15
    jump GFX_copyPaletteTable

    ; 128 tiles in Window layer to id 252-255
    ; vram address
    load32 0xC01420 r1        ; vram addr 1056+2048 0xC01420
    add r1 412 r1               ; add starting offset

    ; loop variables
    load 0 r3                   ; loopvar
    load 128 r4                 ; loopmax
    or r1 r0 r5                 ; vram addr with offset
    load 252 r1                 ; initial tile ID
    load 0 r2                   ; counter for next line
    load 15 r6                  ; compare for next line (-1)

    ; loop
    Test_colors_write_tile_id_loop:
        write 0 r5 r1           ; set tile

        ; check if tile id is 255, then set back to 252, else increase by one
        load 255 r7
        bne r7 r1 2
            load 252 r1
        add r1 1 r1

        shiftr r3 2 r7          ; only increase color id every 4 tiles
        write 2048 r5 r7        ; set color (2048 offset, 0x800 in hex)

        ; if drawn 16 tiles on this line
        bne r2 r6 4
            add r5 25 r5
            load 0 r2
            jumpo 3                 ; skip the other clause
        
        ; else
            add r2 1 r2
            add r5 1 r5             ; incr vram address

        add r3 1 r3             ; incr counter

        beq r3 r4 2             ; keep looping until all tiles are set
        jump Test_colors_write_tile_id_loop


    ; clear previous info message
    addr2reg TEST_INFO_CLEAR r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 40 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print new message to top of screen
    addr2reg TEST_INFO_COLOR1 r2       ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 42 r3                          ; offset from start (40 per line)
    load 0 r4                         ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored



    ;******************
    ; COLORS PART 2
    ;******************

    ; keep waiting until the state has advanced to second color test
    Test_colors_wait_for_button_2:
        nop

    load32 0x80000 r1
    read 0 r1 r2
    load TEST_STATE_COLOR2 r1 
    bne r2 r1 2
        jump Test_colors_part_2

    savpc r15
    push r15
    jump Test_wait_for_button_press  
    jump Test_colors_wait_for_button_2


    Test_colors_part_2:
        nop


    ; load second palette table for color test and copy to VRAM
    addr2reg TEST_COLOR_PALETTETABLE_2 r1 

    savpc r15
    push r15
    jump GFX_copyPaletteTable

    ; clear previous info message
    addr2reg TEST_INFO_CLEAR r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 40 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print new message to top of screen
    addr2reg TEST_INFO_COLOR2 r2       ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 44 r3                          ; offset from start (40 per line)
    load 0 r4                         ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored


    ; return
    pop r15
    jumpr 3 r15









; Tests display related functions
Test_display:
    ; clear VRAM
    savpc r15
    push r15
    jump GFX_initVram

    ;*******************
    ; TEXT PRINTING TEST
    ;*******************

    ; load pattern table and copy to VRAM
    addr2reg TEST_ASCIITABLE r1 

    savpc r15
    push r15
    jump GFX_copyPatternTable


    ; load palette table and copy to VRAM
    addr2reg TEST_ASCII_PALETTETABLE r1 

    savpc r15
    push r15
    jump GFX_copyPaletteTable


    ; print text to Window layer
    addr2reg TEST_WINDOW_STRING_1 r2    ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 122 r3                          ; offset from start (40 per line)
    load 1 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored


    ; print text to Background layer
    addr2reg TEST_BG_STRING_1 r2        ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 258 r3                         ; offset from start (64 per line)
    load 2 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printBGColored  


    ;*******************
    ; OVERLAP TEST
    ;*******************

    ; print text to Window layer
    addr2reg TEST_WINDOW_STRING_1 r2    ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 242 r3                         ; offset from start (40 per line)
    load 1 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print text to Background layer
    addr2reg TEST_BG_STRING_1 r2        ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 386 r3                         ; offset from start (64 per line)
    load 2 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printBGColored  


    ; print message to top of screen
    addr2reg TEST_INFO_LAYER r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 44 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored


    ;*******************
    ; BG SCROLLING TEST
    ;*******************

    ; keep waiting until the state has advanced to bg scrolling test
    Test_display_wait_for_button_1:
        nop

    load32 0x80000 r1
    read 0 r1 r2
    load TEST_STATE_BG_SCROLL r1 
    bne r2 r1 2
        jump Test_display_part_2

    savpc r15
    push r15
    jump Test_wait_for_button_press  
    jump Test_display_wait_for_button_1


    Test_display_part_2:
        nop

    ; clear previous info message
    addr2reg TEST_INFO_CLEAR r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 40 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print new message to top of screen
    addr2reg TEST_INFO_SCROLL r2        ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 46 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored


    ;*******************
    ; SPRITES TEST
    ;*******************

    ; keep waiting until the state has advanced to bg scrolling test
    Test_display_wait_for_button_2:
        nop

    load32 0x80000 r1
    read 0 r1 r2
    load TEST_STATE_SPRITES r1 
    bne r2 r1 2
        jump Test_display_part_3

    savpc r15
    push r15
    jump Test_wait_for_button_press  
    jump Test_display_wait_for_button_2


    Test_display_part_3:
        nop

    ; start of sprite addresses
    load32 0xC02632 r1

    load 40 r2      ; x
    write 0 r1 r2
    load 65 r2      ; y
    write 1 r1 r2
    load 1 r2       ; tile
    write 2 r1 r2
    load 0 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 50 r2      ; x
    write 0 r1 r2
    load 66 r2      ; y
    write 1 r1 r2
    load 2 r2       ; tile
    write 2 r1 r2
    load 1 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 60 r2      ; x
    write 0 r1 r2
    load 67 r2      ; y
    write 1 r1 r2
    load 3 r2       ; tile
    write 2 r1 r2
    load 2 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 70 r2      ; x
    write 0 r1 r2
    load 68 r2      ; y
    write 1 r1 r2
    load 4 r2       ; tile
    write 2 r1 r2
    load 3 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 80 r2      ; x
    write 0 r1 r2
    load 69 r2      ; y
    write 1 r1 r2
    load 5 r2       ; tile
    write 2 r1 r2
    load 4 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 90 r2      ; x
    write 0 r1 r2
    load 70 r2      ; y
    write 1 r1 r2
    load 6 r2       ; tile
    write 2 r1 r2
    load 5 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 


    ; overlap

    load 100 r2      ; x
    write 0 r1 r2
    load 70 r2      ; y
    write 1 r1 r2
    load 1 r2       ; tile
    write 2 r1 r2
    load 0 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 102 r2      ; x
    write 0 r1 r2
    load 69 r2      ; y
    write 1 r1 r2
    load 2 r2       ; tile
    write 2 r1 r2
    load 1 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 104 r2      ; x
    write 0 r1 r2
    load 68 r2      ; y
    write 1 r1 r2
    load 3 r2       ; tile
    write 2 r1 r2
    load 2 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 106 r2      ; x
    write 0 r1 r2
    load 67 r2      ; y
    write 1 r1 r2
    load 4 r2       ; tile
    write 2 r1 r2
    load 3 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 108 r2      ; x
    write 0 r1 r2
    load 66 r2      ; y
    write 1 r1 r2
    load 5 r2       ; tile
    write 2 r1 r2
    load 4 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    load 110 r2      ; x
    write 0 r1 r2
    load 65 r2      ; y
    write 1 r1 r2
    load 6 r2       ; tile
    write 2 r1 r2
    load 5 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    add r1 4 r1 

    ; overlap on layers

    load 116 r2      ; x
    write 0 r1 r2
    load 48 r2      ; y
    write 1 r1 r2
    load 1 r2       ; tile
    write 2 r1 r2
    load 3 r2       ; palette
    shiftl r2 4 r2  ; flags
    write 3 r1 r2

    ; clear previous info message
    addr2reg TEST_INFO_CLEAR r2         ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 40 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; print new message to top of screen
    addr2reg TEST_INFO_SPRITES r2       ; address of length of data
    add r2 1 r1                         ; start of text data
    read 0 r2 r2                        ; read length of data from address
    load 50 r3                          ; offset from start (40 per line)
    load 0 r4                           ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored

    ; return
    pop r15
    jumpr 3 r15


Test_wait_for_button_press:
    push r1
    push r2
    push r3

    load32 0xC02630 r1      ; GPIO address: 0xC02630

    read 0 r1 r2            ; read GPIO values
    load 0b00000001 r3      ; bitmask for GPI[0]
    and r2 r3 r3            ; r3 = GPI[0]

    ; skip to end if no button press
    beq r0 r3 2
        jump Test_wait_for_button_press_end


    ; now wait a bit before waiting for button release (debounce)
    load32 200000 r1
    Test_wait_for_button_press_wait_loop:
        sub r1 1 r1
        beq r0 r1 2         ; keep looping until r1 reached zero
        jump Test_wait_for_button_press_wait_loop


    Test_wait_for_button_press_check_release:
    ; wait for button release
    load32 0xC02630 r1      ; GPIO address: 0xC02630

    read 0 r1 r2            ; read GPIO values
    load 0b00000001 r3      ; bitmask for GPI[0]
    and r2 r3 r3            ; r3 = GPI[0]

    bne r0 r3 2
        jump Test_wait_for_button_press_check_release

    ; increase state variable
    load32 0x80000 r1
    read 0 r1 r2
    add r2 1 r2
    write 0 r1 r2

    Test_wait_for_button_press_end:
        nop

    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15

Int1:
    reti

Int2:
    reti

Int3:
    reti

Int4:
    push r1
    push r2
    push r3
    push r4
    push r5

    ; check if test state variable == TEST_STATE_BG_SCROLL or TEST_STATE_SPRITES
    load32 0x80000 r1
    read 0 r1 r1
    ; skip bg scroll if we are not in the correct state
    load TEST_STATE_BG_SCROLL r2
    beq r1 r2 4                 
        load TEST_STATE_SPRITES r2
        beq r1 r2 2                 ; skip bg scroll if we are not in the correct state
            jump Test_skip_scroll

    ; x fine address 0xC02421
    load32 0xC02421 r1

    ; x offset address 0xC02420
    load32 0xC02420 r2

    read 0 r1 r3 ; fine value
    read 0 r2 r4 ; offset value

    ; check if we have to increase tile offset
    and r3 0b111 r5
    sub r5 0b111 r5
    bne r5 r0 3
        add r4 1 r4
        write 0 r2 r4

    ; increase fine offset
    add r3 1 r3
    write 0 r1 r3

    Test_skip_scroll:
        nop

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    reti
