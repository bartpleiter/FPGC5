; Graphics, sound and UART printing test ROM

; Graphics library test
; Should eventually become a real library when library support is added in assembler

`include lib/UART.asm
`include lib/STD.asm



Main:

 
    load32 0x74657374  r1
    savpc r15
    push r15
    jump UART_print_reg
    

    halt    



Int1:
    push r1
    push r2
    push r3
    push r4
    push r5

    ; restore registers
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    reti

Int2:
    push r1
    push r2
    push r3
    push r4
    push r5

    load32 0xC02623 r1  ; keycode address
    read 0 r1 r1        ; read keycode

    ; convert keycode to hex string
    savpc r15
    push r15
    jump STD_Byte2_to_Hex

    ; send hex string over uart
    savpc r15
    push r15
    jump UART_print_reg


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


