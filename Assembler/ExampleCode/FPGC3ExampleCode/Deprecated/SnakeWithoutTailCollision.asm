Main:						; Main program code
	jump InitVram

; Initialize VRAM by copying pattern table and setting palette table
InitVram:
	; vram address
	load 0b1000 r1
	load 16 r2
	shiftl r1 r2 r1 
	load 0b1000000000000000 r2
	add r1 r2 r1 			; r1 = vram addr 0    0b 1000 1000000000000000

	; ascii address
	load 0b111 r2
	load 16 r3
	shiftl r2 r3 r2
	load 0b1111110000000000 r3
	add r2 r3 r2			; r2 = ascii addr 0    0b 111 1111110000000000

	; loop variables
	load 0 r3				; r3 = loopvar
	load 1024 r4 			; r4 = loopmax
	or r1 r0 r5 			; vram addr with offset
	or r2 r0 r6 			; ascii addr with offset

	; copy loop
	LoadPatternTableLoop:
	add 1 r5 r5				; incr vram
	add 1 r6 r6				; incr ascii
	copy 0 r6 r5			; copy ascii to vram
	add 1 r3 r3				; incr counter
	bne r3 r4 LoadPatternTableLoop 	; keep looping until all data is copied

	; load palette table
	add 0b10000000000 r1 r3 ; r3 = palette table address	0  0b 1000 1000010000000000
	load 0xffff r4 			; palette 0, 2xblack 2xwhite
	write 0 r3 r4 
	load 0b11111 r4 		; palette 1, 3xblack 1xlightBlue
	write 1 r3 r4 
	load 0b00011100 r4 		; palette 2, 3xblack 1xgreen
	write 2 r3 r4 

; Address table:
; reg15 	return pointer (should become stack pointer in future)
; reg8 		interrupt 4 only reg
; reg9 		interrupt 4 only reg

; ram[0]	player x
; ram[1]	player y
; ram[2] 	player sprite
; ram[3] 	player palette
; ram[4] 	player direction

; ram[5] 	food x
; ram[6]	food y
; ram[7] 	food sprite
; ram[8] 	food palette

; ram[9] 	score [low]
; ram[10] 	score [high]
; ram[11] 	hiscore [low]
; ram[12] 	hiscore [high]

; ram[13] 	move delay
; ram[14] 	current move delay

; ram[15] 	RNG value
; ram[16] 	frame counter
; ram[17] 	previous frame counter

; ram[18] 	border palette
; ram[19] 	border sprite h
; ram[20] 	border sprite v
; ram[21] 	border sprite top right
; ram[22] 	border sprite bottom right
; ram[23] 	border sprite bottom left
; ram[24] 	border sprite top left

; ram[25]	tail sprite
; ram[26] 	tail palette

; ram[1024 t/m 1919] bg tile table buffer
; ram[1920 t/m 2815] bg palette table buffer
; ram[3000 t/m 3895] tail ram

; defines
define INIT_PLAYER_X = 3
define INIT_PLAYER_Y = 14
define INIT_PLAYER_SPRITE = 2
define INIT_PLAYER_PALETTE = 1
define INIT_PLAYER_DIRECTION = 0
define INIT_FOOD_X = 20
define INIT_FOOD_Y = 10
define INIT_FOOD_SPRITE = 6
define INIT_FOOD_PALETTE = 2
define INIT_MOVE_DELAY = 20
define INIT_MIN_SPEED_DELAY = 1
define INIT_RNG_VALUE = 173
define INIT_BORDER_PALETTE = 0
define INIT_BORDER_SPRITE_V = 186
define INIT_BORDER_SPRITE_H = 205
define INIT_BORDER_SPRITE_C_TR = 187
define INIT_BORDER_SPRITE_C_BR = 188
define INIT_BORDER_SPRITE_C_BL = 200
define INIT_BORDER_SPRITE_C_TL = 201
define INIT_TAIL_SPRITE = 4
define INIT_TAIL_PALETTE = 1


StartGame:
	or r0 r0 r0 			; basically a nop, needed for compiler

InitGame:
	load 0b1000 r1
	load 16 r2
	shiftl r1 r2 r1 		; r1 is now addr 0 of RAM

	load INIT_PLAYER_X r2 			; player x
	write 0 r1 r2
	load INIT_PLAYER_Y r2 			; player y
	write 1 r1 r2
	load INIT_PLAYER_SPRITE r2 		; player sprite
	write 2 r1 r2
	load INIT_PLAYER_PALETTE r2 	; player palette
	write 3 r1 r2 
	load INIT_PLAYER_DIRECTION r2 	; player direction
	write 4 r1 r2 
	load INIT_FOOD_X r2 			; food x
	write 5 r1 r2 
	load INIT_FOOD_Y r2 			; food y
	write 6 r1 r2 
	load INIT_FOOD_SPRITE r2 		; food sprite
	write 7 r1 r2 
	load INIT_FOOD_PALETTE r2 		; food palette
	write 8 r1 r2 
	load 0 r2 						; score [low]
	write 9 r1 r2 
	load 0 r2 						; score [high]
	write 10 r1 r2 
	load 0 r2 						; hiscore [low]
	write 11 r1 r2 
	load 0 r2 						; hiscore [high]
	write 12 r1 r2 
	load INIT_MOVE_DELAY r2 		; move delay
	write 13 r1 r2 
	load INIT_MOVE_DELAY r2 		; current move delay
	write 14 r1 r2 
	load INIT_RNG_VALUE r2 			; RNG value
	write 15 r1 r2 
	load 0 r2 						; frame counter
	write 16 r1 r2 
	load 0 r2 						; previous frame counter
	write 17 r1 r2 
	load INIT_BORDER_PALETTE r2 	; border palette
	write 18 r1 r2 
	load INIT_BORDER_SPRITE_H r2	; border sprite h
	write 19 r1 r2 
	load INIT_BORDER_SPRITE_V r2	; border sprite v
	write 20 r1 r2 
	load INIT_BORDER_SPRITE_C_TR r2	; border sprite corner top right
	write 21 r1 r2 
	load INIT_BORDER_SPRITE_C_BR r2	; border sprite corner bottom right
	write 22 r1 r2 
	load INIT_BORDER_SPRITE_C_BL r2	; border sprite corner bottom left
	write 23 r1 r2 
	load INIT_BORDER_SPRITE_C_TL r2	; border sprite corner top left
	write 24 r1 r2 
	load INIT_TAIL_SPRITE r2		; tail sprite
	write 25 r1 r2 
	load INIT_TAIL_PALETTE r2		; tail palette
	write 26 r1 r2 

	; clear ram addresses 1024 t/m 1919 (bg pattern table buffer) 
	;						and 1920 t/m 2815 (bg palette table buffer)
	add 1024 r1 r2 
	add 1792 r2 r3

	ClearBGvramBuffer:
	write 0 r2 r0
	add 1 r2 r2
	bne r2 r3 ClearBGvramBuffer

	; clear ram addresses 3000 t/m 3895 (tail ram)
	add 3000 r1 r2
	add 896 r2 r3

	ClearTailRam:
	write 0 r2 r0
	add 1 r2 r2
	bne r2 r3 ClearTailRam


; main loop of game
GameLoop:
	or r1 r0 r2 				; copy player position to player previous position


ReadControllerandKeyboard:
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
	bne r0 r11 SetRight		; if button pressed, do action and return after
	; check left nespad
	load 0b01000000 r10		; left mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 SetLeft		; if button pressed, do action and return after
	; check up nespad
	load 0b00010000 r10		; up mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 SetUp		; if button pressed, do action and return after
	; check down nespad
	load 0b00100000 r10		; down mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 SetDown		; if button pressed, do action and return after
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
	bne r0 r11 SetRight		; if button pressed, do action and return after
	; check keybaord left arrow
	load 0b000100000 r10	; left mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 SetLeft		; if button pressed, do action and return after
	; check keybaord up arrow
	load 0b100000000 r10	; up mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 SetUp		; if button pressed, do action and return after
	; check keybaord down arrow
	load 0b001000000 r10	; down mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 SetDown		; if button pressed, do action and return after
	; check keybaord space button
	load 0b000001000 r10	; space mask
	and r10 r14 r11			; compare
	savpc r15				; save pc in case of jump
	bne r0 r11 ChangeSprite	; if button pressed, do action and return after

DoMovement:
	load 0b1000 r10
	load 16 r11
	shiftl r10 r11 r11 		; r11 is now addr 0 of RAM

	read 14 r11 r12 		; r12 is current movedelay
	beq r0 r12 MoveAndResetDelay ;if current movedelay is 0, then move and reset movedelay
	;else, decrease current movedelay and do not move
	load 1 r13
	sub r12 r13 r12			; decrease by one
	write 14 r11 r12			; write current movedelay back to ram
	jump EndDoMovement

	MoveAndResetDelay:
	read 13 r11 r13 		; r13 is movedelay
	write 14 r11 r13		; write movedelay to current movedelay

	read 4 r11 r7 			; read direction

	;if dir == 0, moveright
	load 0 r10
	savpc r15
	beq r10 r7 MoveRight

	;if dir == 1, moveDown
	load 1 r10
	savpc r15
	beq r10 r7 MoveDown

	;if dir == 2, moveLeft
	load 2 r10
	savpc r15
	beq r10 r7 MoveLeft

	;if dir == 3, moveUp
	load 3 r10
	savpc r15
	beq r10 r7 MoveUp

	EndDoMovement:
	or r0 r0 r0 				; basically a nop


CheckFoodCollision:
	read 0 r1 r2 			; r2 player x
	read 1 r1 r3 			; r3 player y
	read 5 r1 r4 			; r4 food x
	read 6 r1 r5  			; r5 food y

	bne r2 r4 EndFoodCollision 	; skip if no x collision
	bne r3 r5 EndFoodCollision 	; skip if no y collision

	IncreaseScore:
	read 9 r1 r12 			; r12 is current score [low]
	add 1 r12 r12			; increase
	; todo, if 255, then increase score [high] by one
	write 9 r1 r12			; write back

	UpdateFoodPosition:		; update rng in case of repeat (should not be needed anymore)
	savpc r15				; save pc for after jump
	jump UpdateRNG			; update RNG value

	; GEN NEW X POSITION USING RNG
	read 15 r1 r2 			; r2 rng value

	; modulo by 30, and add 1 because position 31 and 0 is a wall
	load 30 r3
	FoodRngSubstractX:
	bgt r3 r2 FoodRngXDone
	sub r2 r3 r2
	jump FoodRngSubstractX

	FoodRngXDone:
	add 1 r2 r2 			; should be between (inclusive) 1 and 30
	write 5 r1 r2 			; write new food x position back

	; GEN NEW Y POSITION USING RNG
	read 15 r1 r2 			; r2 rng value

	; modulo by 26, and add 1 because position 27 and 0 is a wall
	load 26 r3
	FoodRngSubstractY:
	bgt r3 r2 FoodRngYDone
	sub r2 r3 r2
	jump FoodRngSubstractY

	FoodRngYDone:
	add 1 r2 r2 			; should be between (inclusive) 1 and 26
	write 6 r1 r2 			; write new food y position back
	

	; DECREASE MOVEDELAY
	read 13 r1 r2 					; r2 is movedelay
	load INIT_MIN_SPEED_DELAY r3 	; r13 is max speed
	beq r2 r3 EndDecreaseMoveDelay 	; skip decreasing if at max speed
	load 1 r3
	sub r2 r3 r2 					; decrease movedelay by one
	write 13 r1 r2 					; write back new movedelay
	EndDecreaseMoveDelay:
	or r0 r0 r0 					; basically a nop

	EndFoodCollision:
	or r0 r0 r0 				; basically a nop


WriteTailRam:
	; first calculate player position
	read 0 r1 r2 			; r2 player x
	read 1 r1 r3 			; r3 player y

	load 0 r6 				; loop counter
	load 1 r7 				; decrease value
	PlayerXYTailloop:
	beq r6 r3 EndPlayerXYTailloop ; when all y lines are added
	add 32 r2 r2 			; add line to x
 	sub r3 r7 r3 			; decrease y
 	jump PlayerXYTailloop

	EndPlayerXYTailloop:
	or r0 r0 r0 			; nop, r2 is now player position
	
	read 9 r1 r3 			; r3 current score [low]
	; todo add score [high] as well
	add 2 r3 r3 	 		; add 2 to tail value to start with tail of 2

	add r1 r2 r4 			; r4 is RAM with player offset
	write 3000 r4 r3		; write score to tail ram


; start of drawing functions


ClearScreen:
	; clear ram addresses 1024 t/m 1919 (bg pattern table buffer) 
	;						and 1920 t/m 2815 (bg palette table buffer)

	add 1024 r1 r2 
	add 1792 r2 r3

	ClearBGRAMLoop:
	write 0 r2 r0
	add 1 r2 r2
	bne r2 r3 ClearBGRAMLoop

DrawAndDecreaseTail:
	read 25 r1 r11 				; r11 tail sprite
	read 26 r1 r12 				; r12 tail palette

	load 0 r2 					; r2 loop counter
	load 896 r3 				; r3 loop max

	LoopTailRead:
	add r2 r1 r4 				; r4 ram + offset
	read 3000 r4 r10 			; r10 tail ram value
	beq r0 r10 EndDecreaseTail 	; skip if there is no tail

	; if there is a tail
	; draw tail
	write 1024 r4 r11 			; write tail sprite
	write 1920 r4 r12 			; write tail palette

	; decrease by one with movedelay
	load 1 r5 					; r5 1
	read 14 r1 r6 				; r6 is current movedelay
	bne r6 r5 SkipDecreaseTail
	sub r10 r5 r10 				; decrease tail value
	write 3000 r4 r10 			; write decreased tail ram value back

	SkipDecreaseTail:
	or r0 r0 r0 				; nop

	EndDecreaseTail:
	add 1 r2 r2
	bne r2 r3 LoopTailRead



; remove player from screen (remove bg tile data and bg palette data) and redraw at new position
RedrawPlayer:
	read 0 r1 r2 			; r2 player x
	read 1 r1 r3 			; r3 player y
	read 2 r1 r4 			; r4 player sprite idx
	read 3 r1 r5 			; r5 player palette idx

	load 0 r6 				; loop counter
	load 1 r7 				; decrease value
	PlayerXYloop:
	beq r6 r3 EndPlayerXYloop ; when all y lines are added
	add 32 r2 r2 			; add line to x
 	sub r3 r7 r3 			; decrease y
 	jump PlayerXYloop

	EndPlayerXYloop:
	or r0 r0 r0 			; nop, r2 is now player position

	add r1 r2 r2			; add new player position offset
	write 1024 r2 r4 		; draw player tile
	write 1920 r2 r5 		; draw player palette


DrawFood:
	read 5 r1 r2 			; r2 food x
	read 6 r1 r3 			; r3 food y
	read 7 r1 r4 			; r4 food sprite idx
	read 8 r1 r5 			; r5 food palette idx

	load 0 r6 				; loop counter
	load 1 r7 				; decrease value
	FoodXYloop:
	beq r6 r3 EndFoodXYloop ; when all y lines are added
	add 32 r2 r2 			; add line to x
 	sub r3 r7 r3 			; decrease y
 	jump FoodXYloop

	EndFoodXYloop:
	or r0 r0 r0 			; nop, r2 is now food position

	add r1 r2 r2			; add new food position offset
	write 1024 r2 r4 		; draw food tile
	write 1920 r2 r5 		; draw food palette


DrawBorder:
	read 18 r1 r2 			; r2 border palette idx
	read 19 r1 r3 			; r3 border sprite h
	read 20 r1 r4 			; r4 border sprite v
	read 21 r1 r5 			; r5 border sprite corner tr
	read 22 r1 r6 			; r6 border sprite corner br
	read 23 r1 r7 			; r7 border sprite corner bl
	read 24 r1 r10 			; r10 border sprite corner tl

	load 0 r11				; from
	load 32 r12				; to
	DrawTopBorder:
	add r11 r1 r14			; add offset tile
	write 1024 r14 r3		; write tile
	write 1920 r14 r2		; write palette
	add 1 r11 r11			; increase offset
	bne r12 r11 DrawTopBorder

	load 0 r11				; from
	load 32 r12				; to
	DrawBottomBorder:
	add r11 r1 r14			; add offset tile
	write 1888 r14 r3		; write tile (864 + 1024)
	write 2784 r14 r2		; write palette (864 + 1024 + 896)
	add 1 r11 r11			; increase offset
	bne r12 r11 DrawBottomBorder

	load 0 r11				; from
	load 896 r12			; to (28x32)
	DrawLeftBorder:
	add r11 r1 r14			; add offset tile
	write 1024 r14 r4		; write tile
	write 1920 r14 r2		; write palette
	add 32 r11 r11			; increase offset
	bne r12 r11 DrawLeftBorder

	load 31 r11				; from
	load 927 r12			; to (28x32 + 31)
	DrawRightBorder:
	add r11 r1 r14			; add offset tile
	write 1024 r14 r4		; write tile
	write 1920 r14 r2		; write palette
	add 32 r11 r11			; increase offset
	bne r12 r11 DrawRightBorder

	write 1024 r1 r10 		; write top left corner
	write 1055 r1 r5 		; write top right corner
	write 1888 r1 r7 		; write bottom left corner
	write 1919 r1 r6 		; write bottom right corner


EndOfGameLoop:
	savpc r15				; save pc for after jump
	jump WaitNewFrame		; wait for new frame
	savpc r15				; save pc for after jump
	jump CopyRAMtoVRAM		; copy vram buffer in ram to vram
	savpc r15				; save pc for after jump
	jump UpdateRNG			; update RNG value
	jump GameLoop 			; go to start of game loop

SetRight:
	load 0 r2 				; r2 direction 0
	write 4 r1 r2 			; write direction

	jump 2 r15				; return to previous function savpc +2

SetDown:
	load 1 r2 				; r2 direction 1
	write 4 r1 r2 			; write direction
	
	jump 2 r15				; return to previous function savpc +2

SetLeft:
	load 2 r2 				; r2 direction 2
	write 4 r1 r2 			; write direction
	
	jump 2 r15				; return to previous function savpc +2

SetUp:
	load 3 r2 				; r2 direction 3
	write 4 r1 r2 			; write direction
	
	jump 2 r15				; return to previous function savpc +2

MoveRight:
	read 0 r1 r2 			; r2 player x
	load 30 r3 				; r3 30
	beq r2 r3 GameOver 		; game over if moving into wall

	add 1 r2 r2 			; increase x
	write 0 r1 r2 			; write back new x

	jump 2 r15				; return to previous function savpc +2

MoveLeft:
	read 0 r1 r2 			; r2 player x
	load 1 r3 				; r3 1
	beq r2 r3 GameOver 		; game over if moving into wall

	sub r2 r3 r2 			; decrease x
	write 0 r1 r2 			; write back new x

	jump 2 r15				; return to previous function savpc +2

MoveUp:
	read 1 r1 r2 			; r2 player y
	load 1 r3 				; r3 1
	beq r2 r3 GameOver 		; game over if moving into wall

	sub r2 r3 r2 			; decrease y
	write 1 r1 r2 			; write back new y

	jump 2 r15				; return to previous function savpc +2

MoveDown:
	read 1 r1 r2 			; r2 player y
	load 26 r3 				; r3 26
	beq r2 r3 GameOver 		; game over if moving into wall

	add 1 r2 r2 			; increase y
	write 1 r1 r2 			; write back new y

	jump 2 r15				; return to previous function savpc +2

ChangeSprite:
	read 2 r1 r2 			; r2 player sprite idx
	add 1 r2 r2 			; increase
	write 2 r1 r2 			; write back

	jump 2 r15				; return to previous function savpc +2


WaitNewFrame:
	read 17 r1 r2 				; r2 previous frame counter

	WaitFrameChange:
	read 16 r1 r3 				; r3 frame counter
	beq r2 r3 WaitFrameChange	; keep looping until framecounter differs from previous

	write 17 r1 r3 				; update previous frame counter

	jump 2 r15					; return to previous function savpc +2
	
UpdateRNG:
	read 15 r1 r2 			; r2 rng value

	add 0b00110100 r2 r2
	xor 0b10101100 r2 r2

	read 16 r1 r3 			; r3 frame counter
	add r3 r2 r2

	write 15 r1 r2 			; write new rng value back

	jump 2 r15 				; return to previous function savpc +2

GameOver:
	jump StartGame

CopyRAMtoVRAM:
	add 1024 r1 r2 			; r2 RAM with offset, bg table addr 0

	add 1792 r2 r10 		; max RAM bg address + 1 for loop condition

	load 0b1000 r3
	load 0b1000010010000000 r4
	load 16 r5
	shiftl r3 r5 r3
	add r4 r3 r3 			; r3 bg tile table address 0 1000 1000010010000000

	load 1 r13

	CopyBGvramBuffer:
	;copy 0 r2 r3
	read 0 r2 r11
	write 0 r3 r11
	add 1 r2 r2
	add 1 r3 r3
	bne r2 r10 CopyBGvramBuffer

	jump 2 r15 				; return to previous function savpc +2


Int1:						; Interrupt1 handler
	reti 					; Return from interrupt

Int2:						; Interrupt2 handler
	reti 					; Return from interrupt

Int3:						; Interrupt3 handler
	reti 					; Return from interrupt


Int4:						; Interrupt4 handler, Vsync interrupt
	load 0b1000 r8
	load 16 r9
	shiftl r8 r9 r8 		; r8 is now addr 0 of RAM

	read 16 r8 r9 			; r9 frame counter
	add 1 r9 r9  			; increase frame counter
	write 16 r8 r9 			; write new frame counter back

	reti 					; Return from interrupt