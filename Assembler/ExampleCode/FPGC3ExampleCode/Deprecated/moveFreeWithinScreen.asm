Main:						; Main program code
	jump LoadPatternTable

; using random registers for copying, because init functions
LoadPatternTable:
	load 0 r12				; counter for increasing addr
	load 1023 r13
	load 0b1000 r1
	load 16 r2
	shiftl r1 r2 r3 
	load 0b1000000000000000 r4
	add r3 r4 r5 			; vram addr 0     1000 1000000000000000
	load 0b111 r6
	shiftl r6 r2 r7
	load 0b1111110000000000 r8
	add r8 r7 r9			; ascii addr 0     111 1111110000000000
	; copy first address (before increasing offset)
	read 0 r9 r10			; read ascii data
	write 0 r5 r10			; write to vram

CopyTile:
	add 1 r9 r9				; incr ascii
	add 1 r5 r5				; incr vram
	read 0 r9 r10			; read ascii data
	write 0 r5 r10			; write to vram
	add 1 r12 r12			; incr counter (TODO should use counter as offset for read/write)
	bgt r13 r12 CopyTile

LoadPaletteTable:
	load 0b1000 r10
	load 0b1000010000000000  r11
	load 16 r12
	shiftl r10 r12 r13
	add r11 r13 r13 		; palette table address	0   1000 1000010000000000

	load 0xffff r1 			; palette 0, 2xblack 2xwhite
	load 0b11111 r2 		; palette 1, 3xblack 1xlightBlue
	write 0 r13 r1 			; write palette 0
	write 1 r13 r2 			; write palette 1

; all regs free, start of game
; as this list increases, should write values to RAM
; reg1: player position
; reg2; player previous position
; reg3; player sprite
; reg4; player palette
; reg5; frame counter
; reg6; previous frame counter
; reg 10, 11, 12, 13 and 14: obtaining button data, checking buttons and drawing player
; reg 15 is for savpc

InitPlayer:
	load 447 r1 			; init player position to center
	or r0 r1 r2 			; init player previous position
	load 2 r3 				; init player sprite
	load 1 r4 				; init player palette to 1
	load 0 r5 				; init frame counter to 0
	load 0 r6 				; init previous frame counter to 0




; main loop of game
GameLoop:
	or r1 r0 r2 				; copy player position to player previous position

ReadController:
	load 0b1000 r10
	load 0b1000101110000000 r11 
	load 16 r12
	shiftl r10 r12 r13		
	add r11 r13 r13 		; Gamepad address 0x88B80 1000 1000101110000000

	; read nespad
	read 0 r13 r14			; 24x0,r,l,d,u,st,sel,b,a
	; check right nespad
	load 0b10000000 r10		; right mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveRight	; if button pressed, do action and return after
	; check left nespad
	load 0b01000000 r10		; left mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveLeft		; if button pressed, do action and return after
	; check up nespad
	load 0b00010000 r10		; up mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveUp		; if button pressed, do action and return after
	; check down nespad
	load 0b00100000 r10		; down mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveDown		; if button pressed, do action and return after
	; check a nespad
	load 0b00000001 r10		; a mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 ChangeSprite	; if button pressed, do action and return after





	; read keyboard
	read 5 r13 r14			; keyboard[31:0]
	; check keybaord right arrow
	load 0b010000000 r10	; right mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveRight	; if button pressed, do action and return after
	; check keybaord left arrow
	load 0b000100000 r10	; left mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveLeft		; if button pressed, do action and return after
	; check keybaord up arrow
	load 0b100000000 r10	; up mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveUp		; if button pressed, do action and return after
	; check keybaord down arrow
	load 0b001000000 r10	; down mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 MoveDown		; if button pressed, do action and return after
	; check keybaord space button
	load 0b000001000 r10	; space mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 ChangeSprite	; if button pressed, do action and return after

; remove player from screen (remove bg tile data and bg palette data) and redraw at new position
RedrawPlayer:

	; tile
	load 0b1000 r10
	load 0b1000010010000000 r11
	load 16 r12
	shiftl r10 r12 r13
	add r11 r13 r13 		; bg tile table address 0 1000 1000010010000000

	add r2 r13 r14			; add old player position offset
	write 0 r14 r0 			; clear tile at correct quadrant

	add r1 r13 r14			; add new player position offset
	write 0 r14 r3 			; draw tile with current player sprite

	; palette
	load 0b1000 r10
	load 0b1000100000000000 r11
	load 16 r12
	shiftl r10 r12 r13
	add r11 r13 r13 		; bg palette table address 0 1000 1000100000000000

	add r2 r13 r14			; add old player position offset
	write 0 r14 r0 			; clear palette
	add r1 r13 r14			; add new player position offset
	write 0 r14 r4 			; draw tile with current player palette


	savpc r15				; save pc for after jump
	jump WaitNewFrame		; wait for new frame
	jump GameLoop 			; go to start of game loop



; do not use r14 and r11 in move functions!
MoveRight:
	load 32 r11
	or 0 r1 r12
	;keep removing 32 untill smaller than 32
	Rem32Right:
	bgt r11 r12 EndRem32Right
	sub r12 r11 r12
	jump Rem32Right

	EndRem32Right:
	xor 31 r12 r12			; zero if at right side of screen
	beq r0 r12 RetMoveRight	; do not move player right when at right of screen
	add 1 r1 r1 			; move player right
	RetMoveRight:
	jump 2 r15				; return to previous function savpc +2

MoveLeft:
	load 1 r10
	load 32 r11
	or 0 r1 r12
	;keep removing 32 untill smaller than 32
	Rem32Left:
	bgt r11 r12 EndRem32Left
	sub r12 r11 r12
	jump Rem32Left

	EndRem32Left:
	xor 0 r12 r12			; zero if at left side of screen
	beq r0 r12 RetMoveLeft	; do not move player left when at left of screen
	sub r1 r10 r1 			; move player left
	RetMoveLeft:
	jump 2 r15				; return to previous function savpc +2

MoveUp:
	load 32 r10
	bgt r10 r1 RetMoveUp 	; do not move up when at top row
	sub r1 r10 r1 			; move player left
	RetMoveUp:
	jump 2 r15				; return to previous function savpc +2

MoveDown:
	load 863 r10
	bgt r1 r10 RetMoveDown	; do not move down when at bottom row
	add 32 r1 r1 			; move player right
	RetMoveDown:
	jump 2 r15				; return to previous function savpc +2


ChangeSprite:
	add 1 r3 r3 			; increase sprite reg
	load 255 r10 			; max sprite index
	and r10 r3 r3 			; to prevent higher than 255 as sprite index
	jump 2 r15				; return to previous function savpc +2


WaitNewFrame:
	beq r5 r6 WaitNewFrame	; keep looping until new frame is drawn
	or r5 r0 r6 			; copy r5 to r6
	jump 2 r15				; return +2 after frame is drawn
	

Int1:						; Interrupt1 handler
	reti 					; Return from interrupt

Int2:						; Interrupt2 handler
	reti 					; Return from interrupt

Int3:						; Interrupt3 handler
	reti 					; Return from interrupt

Int4:						; Interrupt4 handler, Vsync interrupt
	add 1 r5 r5 			; increase frame counter
	reti 					; Return from interrupt