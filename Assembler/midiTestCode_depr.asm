; Music test rom

; Graphics library test
; Should eventually become a real library when library support is added in assembler

`include lib/GFX.asm
`include example/data_gfx_tables.asm
`include example/data_music.asm

define MUSIC_LEN                    = 12        ; number of notes


Main:

  

    ;CRAPPY MUSIC PLAYER TEST CODE
    load 0x0000 r2
    loadhi 0x08 r2      ; r2 =  0x80000 | music index
                        ;       0x80001 | max music index
    load MUSIC_LEN r1
    write 1 r2 r1
    write 0 r2 r0
    write 2 r2 r0
    write 3 r2 r0

    load 0x2626 r1
    loadhi 0xC0 r1      ; r1 = Timer1 value register

    addr2reg MUSICLENS r2
    read 0 r2 r2

    addr2reg MUSICLOWLENS r10
    read 0 r10 r10


    load 1 r3

    write 0 r1 r2       ; write timer1 value
    write 1 r1 r3       ; start timer1

    ;write 2 r1 r10      ; write timer2 value
    ;write 3 r1 r3       ; start timer3

    addr2reg MUSICNOTES r4
    read 0 r4 r4

    addr2reg MUSICLOWNOTES r11
    read 0 r11 r11

    load 0x0000 r2
    loadhi 0x08 r2      ; r2 =  0x80000 | music index
                        ;       0x80001 | max music index

    read 0 r2 r3
    add r3 1 r3
    write 0 r2 r3
    write 2 r2 r3
    ;END CRAPPY MUSIC TEST INIT CODE



    savpc r15
    push r15
    jump GFX_initVram

    ; ascii address
    addr2reg ASCIITABLE r1 

    savpc r15
    push r15
    jump GFX_copyPatternTable

    ; palette address
    addr2reg PALETTETABLE r1 

    savpc r15
    push r15
    jump GFX_copyPaletteTable

    ; print some data to Window
    addr2reg WINDOWTEXT r1   ; data to copy
    load 25 r2              ; length of data
    load 42 r3               ; offset from start
    load 2 r4               ; palette idx

    savpc r15
    push r15
    jump GFX_printWindowColored   

    ; print some data to BG
    addr2reg BACKGROUNDTILES r1   ; data to copy
    load 6 r2               ; length of data
    load 76 r3              ; offset from start
    load 1 r4               ; palette idx

    savpc r15
    push r15
    jump GFX_printBGColored  



    ; INIT SPRITES TEST
    load 0x2632 r1
    loadhi 0xC0 r1

    load 46 r2
    write 0 r1 r2
    load 43 r2
    write 1 r1 r2
    load 1 r2
    write 2 r1 r2
    load 0b100000 r2
    write 3 r1 r2

    add r1 4 r1 

    load 127 r2
    write 0 r1 r2
    load 47 r2
    write 1 r1 r2
    load 2 r2
    write 2 r1 r2
    load 0b010000 r2
    write 3 r1 r2

    add r1 4 r1 

    load 376 r2
    write 0 r1 r2
    load 221 r2
    write 1 r1 r2
    load 3 r2
    write 2 r1 r2
    load 0b000000 r2
    write 3 r1 r2

    add r1 4 r1 

    load 276 r2
    write 0 r1 r2
    load 121 r2
    write 1 r1 r2
    load 4 r2
    write 2 r1 r2
    load 0b000000 r2
    write 3 r1 r2

    add r1 4 r1 

    load 256 r2
    write 0 r1 r2
    load 171 r2
    write 1 r1 r2
    load 5 r2
    write 2 r1 r2
    load 0b100000 r2
    write 3 r1 r2

    add r1 4 r1 

    load 260 r2
    write 0 r1 r2
    load 175 r2
    write 1 r1 r2
    load 6 r2
    write 2 r1 r2
    load 0b010000 r2
    write 3 r1 r2


    halt    

WINDOWTEXT:
.ds "Graphics printing test :)"

BACKGROUNDTILES:
.db 176 176 177 177 178 178



SNESloop:
    
    read 0 r1 r3
    write 0 r2 r3

    jump SNESloop





Int1:
    ; CRAPPY MUSIC INTERRUPT CODE TONE1PLAYER
    push r1
    push r2
    push r3
    push r4
    push r5

    load 0x0000 r2
    loadhi 0x08 r2      ; r2 =  0x80000 | music index
                        ;       0x80001 | max music index
    read 0 r2 r5 

    load 0x2626 r1
    loadhi 0xC0 r1      ; r1 = Timer1 value register

    addr2reg MUSICLENS r3
    add r3 r5 r3
    read 0 r3 r3        ; get len data

    load 1 r4

    write 0 r1 r3       ; write timer1 value
    write 1 r1 r4       ; start timer1

    addr2reg MUSICNOTES r4
    add r4 r5 r4
    read 0 r4 r4        ; get note

    write 6 r1 r4       ; 0xC0262C TonePlayer1

    load 0x0000 r2
    loadhi 0x08 r2      ; r2 =  0x80000 | music index
                        ;       0x80001 | max music index

    read 0 r2 r3
    add r3 1 r3
    write 0 r2 r3

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    reti

Int2:
    ; CRAPPY MUSIC INTERRUPT CODE TONE2PLAYER
    push r1
    push r2
    push r3
    push r4
    push r5

    load 0x0002 r2
    loadhi 0x08 r2      ; r2 =  0x80002 | music index
                        ;       0x80001 | max music index
    read 0 r2 r5 

    load 0x2626 r1
    loadhi 0xC0 r1      ; r1 = Timer1 value register

    addr2reg MUSICLOWLENS r3
    add r3 r5 r3
    read 0 r3 r3        ; get len data

    load 1 r4

    write 2 r1 r3       ; write timer2 value
    write 3 r1 r4       ; start timer2

    addr2reg MUSICLOWNOTES r4
    add r4 r5 r4
    read 0 r4 r4        ; get note

    write 7 r1 r4       ; 0xC0262D TonePlayer2

    load 0x0002 r2
    loadhi 0x08 r2      ; r2 =  0x80002 | music index
                        ;       0x80001 | max music index

    read 0 r2 r3
    add r3 1 r3
    write 0 r2 r3

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    reti

Int3:
    push r1
    push r2
    push r3
    push r4
    push r5

    load 0x262E r1
    loadhi 0xC0 r1

    read 1 r1 r2

    ; vram address
    load 0x1420 r1
    loadhi 0xC0 r1          ; r1 = vram addr 1056+2048 0xC01420

    load 0x0003 r3
    loadhi 0x08 r3      ; r2 =  0x80003 | counter

    read 0 r3 r4

    add r4 r1 r1
    write 0 r1 r2

    add r4 1 r4
    write 0 r3 r4


    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    reti

Int4:
    push r1
    push r2
    push r3
    push r4
    push r5

    ; x fine address 0xC02421
    load 0x2421 r1
    loadhi 0xC0 r1

    ; x offset address 0xC02420
    load 0x2420 r2
    loadhi 0xC0 r2

    read 0 r1 r3 ; fine value
    read 0 r2 r4 ; offset value

    ; check if we have to increase tile offset
    and r3 0b111 r5
    sub r5 0b111 r5
    bne r5 r0 3
        add r4 1 r4
        write 0 r2 r4


    add r3 1 r3
    write 0 r1 r3



    ; Sprite move test
    load 0x2632 r1
    loadhi 0xC0 r1

    read 0 r1 r2
    add r2 1 r2
    write 0 r1 r2

    read 1 r1 r2
    add r2 1 r2
    write 1 r1 r2

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    reti


