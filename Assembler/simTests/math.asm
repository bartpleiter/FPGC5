Main:
    load 5 r1
    load 3 r2
    add r1 r2 r3
    mult r3 1 r4
    beq r3 r4 2
    halt
    push r1
    pop r2
    read 0 r2 r1
    or r1 r1 r1
    savpc r2
    halt


Int1:
    reti

Int2:
    reti

Int3:
    reti

Int4:
    reti