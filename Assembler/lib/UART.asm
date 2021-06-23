; UART library
; Currently allows for printing text and regs

; Prints text over UART
; INPUT:
;   r1: address of first byte
;   r2: length of data to print
UART_print_text:
    ; backup regs
    push r1
    push r2
    push r3
    push r5
    push r8
    push r9

    load32 0xC0262E r3          ; r3 = 0xC0262E | UART tx    

    ; loop variables
    load 0 r5                   ; r5 = loopvar
    load 32 r8                  ; r8 = shift variable

    ; copy loop
    UART_print_text_loop:
        sub r8 8 r8             ; remove 8 from shift variable
        read 0 r1 r9            ; read 32 bits
        shiftr r9 r8 r9         ; shift to right
        write 0 r3 r9           ; write char to UART tx

        bne r0 r8 3             ; if we shifted the last byte
            add r1 1 r1             ; incr data address 
            load 32 r8              ; set shift variable back to 24

        add r5 1 r5             ; incr counter
        bge r5 r2 2             ; keep looping until all data is copied
        jump UART_print_text_loop

    ; print \n (0x0A)
    load 0xA r2
    write 0 r3 r2

    ; restore regs
    pop r9
    pop r8
    pop r5
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Prints 4 bytes from reg over UART
; INPUT:
;   r1: reg to send
UART_print_reg:
    ; backup regs
    push r1
    push r2
    push r3

    load32 0xC0262E r3          ; r3 = 0xC0262E | UART tx

    ; send leftmost byte
    shiftr r1 24 r2
    write 0 r3 r2

    ; send second byte
    shiftr r1 16 r2
    write 0 r3 r2

    ; send thrid byte
    shiftr r1 8 r2
    write 0 r3 r2

    ; send rightmost byte
    write 0 r3 r1

    ; print \n (0x0A)
    load 0xA r2
    write 0 r3 r2

    ; restore regs
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15