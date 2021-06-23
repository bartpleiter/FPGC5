define PALETTE_0 = 0xffff		;2xblack 2xwhite
define PALETTE_1 = 0b11111 		;3xblack 1xlightBlue
define PALETTE_2 = 0b00011100 	;3xblack 1xgreen

Main:						; Main program code
	savpc r15
	push r15
	jump InitVram
	halt

; Initialize VRAM by copying pattern table and setting palette table
InitVram:
	; vram address
	load 0b1000000000000000 r1
	loadhi 0b1000 r1 		; r1 = vram addr 0 |0x88000|0b 1000 1000000000000000

	; ascii address
	load 0b1111110000000000 r2
	loadhi 0b111 r2			; r2 = ascii addr 0|0x7FC00|0b  111 1111110000000000

	; loop variables
	load 0 r3				; r3 = loopvar
	load 1024 r4 			; r4 = loopmax
	or r1 r0 r5 			; r5 = vram addr with offset
	or r2 r0 r6 			; r6 = ascii addr with offset

	; copy loop
	LoadPatternTableLoop:
	add 1 r5 r5				; incr vram address
	add 1 r6 r6				; incr ascii address 
	;copy 0 r6 r5			; copy ascii to vram
	read 0 r6 r7 			; read data from ascii
	write 0 r5 r7 			; write data to vram
	add 1 r3 r3				; incr counter
	bne r3 r4 LoadPatternTableLoop 	; keep looping until all data is copied

	; load palette table
	add 0b10000000000 r1 r3 ; r3 = palette table addr 0|0x88400|0b 1000 1000010000000000
	load PALETTE_0 r4 		; load palette 0,
	write 0 r3 r4 			; write palette to vram
	load PALETTE_1 r4 		; load palette 1
	write 1 r3 r4 			; write palette to vram
	load PALETTE_2 r4 		; load palette 2
	write 2 r3 r4 			; write palette to vram

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