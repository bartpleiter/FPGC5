Main:						; Main program code

	or 0b0010 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	or 0b0100 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	or 0b1000 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	and 0b1110 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	and 0b1101 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	and 0b1011 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	or 0b0100 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	or 0b0010 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	or 0b0001 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	and 0b0111 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	and 0b1011 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop

	and 0b1101 r14 r14
	savpc r15				; save pc for after jump
	jump WaitLoop



	jump Main

WaitLoop:
	;jump 2 r15

	load 0 r5
	load 60000 r6

	RepeatLoop:
	add 1 r5 r5
	bgt r6 r5 RepeatLoop

	jump 2 r15					; return to previous function savpc +2

Int1:						; Interrupt1 handler
	reti 					; Return from interrupt

Int2:						; Interrupt2 handler
	reti 					; Return from interrupt

Int3:						; Interrupt3 handler
	reti 					; Return from interrupt

Int4:						; Interrupt4 handler, Vsync interrupt
	reti 					; Return from interrupt