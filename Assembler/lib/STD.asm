; STD library
; Contains basic functions
; Currently only contains a functions to convert a byte to hex string

; Converts byte into ASCII string
; INPUT:
;   r1: byte to convert at right side of reg
; OUTPUT:
;   r1: ASCII string in single reg with 0x prefix
STD_Byte2_to_Hex:
    ; backup regs
    push r2
    push r3
    push r4

    and r1 0b00001111 r2        ; r2 = right 4 bits
    and r1 0b11110000 r3        ; r3 = left 4 bits

    ; move offset back to right of word
    shiftr r3 4 r3

    addr2reg STD_Byte2_to_Hex_lookup_String r4

    ; add offset to addresses
    add r2 r4 r2
    add r3 r4 r3

    load 0 r1                   ; clear r1
    loadhi 0x3078 r1            ; set 0x prefix

    ; read ascii values
    read 0 r2 r2
    read 0 r3 r3

    shiftl r3 8 r3              ; shift r3 by one byte to left

    ; add ascii values to return reg
    add r2 r1 r1
    add r3 r1 r1

    ; restore regs
    pop r4
    pop r3
    pop r2

    ; return
    pop r15
    jumpr 3 r15


; We use .dw so each char is in one word for easy address offsets
STD_Byte2_to_Hex_lookup_String:
.dw 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70


; TODO sleep millis function without using timers