; SPI library
; Defines basic SPI functions with GPO[0] as CS pin

; Sets GPO[0] (cs) low
SPI_beginTransfer:
    ; backup regs
    push r1
    push r2
    push r3

    load32 0xC02630 r3          ; r3 = 0xC02630 | GPIO

    read 0 r3 r1                ; r1 = GPIO values
    load 0b1111111011111111 r2  ; r2 = bitmask
    and r1 r2 r1                ; set GPO[0] low
    write 0 r3 r1               ; write GPIO

    ; restore regs
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Sets GPO[0] (cs) high
SPI_endTransfer:
    ; backup regs
    push r1
    push r2
    push r3

    load32 0xC02630 r3          ; r3 = 0xC02630 | GPIO         

    read 0 r3 r1                ; r1 = GPIO values
    load 0b100000000 r2         ; r2 = bitmask
    or r1 r2 r1                 ; set GPO[0] high
    write 0 r3 r1               ; write GPIO

    ; restore regs
    pop r3
    pop r2
    pop r1

    ; return
    pop r15
    jumpr 3 r15


; Writes byte over SPI
; INPUT:
;   r1: byte to write
; OUTPUT:
;   r1: read value
SPI_transfer:
    ; backup regs
    push r2

    savpc r15
    push r15
    jump SPI_beginTransfer

    load32 0xC02631 r2      ; r2 = 0xC02631 | SPI address    

    write 0 r2 r1           ; write r1 over SPI
    read 0 r2 r1            ; read return value

    savpc r15
    push r15
    jump SPI_endTransfer

    ; restore regs
    pop r2

    ; return
    pop r15
    jumpr 3 r15