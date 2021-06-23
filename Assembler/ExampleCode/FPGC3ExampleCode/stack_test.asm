Main:	
	load 0b0000 r14

	savpc r15
	push r15
	jump F1

	or r1 r14 r14

	halt		


F1:
	load 7 r1

	savpc r15
	push r15
	jump F2

	pop r15
	jump 3 r15


F2:
	sub 3 r1 r1

	savpc r15
	push r15
	jump F3


	pop r15
	jump 3 r15

F3:
	shiftr 2 r1 r1

	pop r15
	jump 3 r15


Int1:						; Interrupt1 handler
	reti 					; Return from interrupt

Int2:						; Interrupt2 handler
	reti 					; Return from interrupt

Int3:						; Interrupt3 handler
	reti 					; Return from interrupt

Int4:						; Interrupt4 handler, Vsync interrupt
	reti 					; Return from interrupt
