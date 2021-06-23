; I/O mapping:
; 0b000X = CS
; 0b00X0 = SCK
; 0b0X00 = MOSI (Connect to SI on enc28j60)

;NOTE: r1 is a global register here!
;This example will send the rightmost 8 bits from r1 over SPI
Main:
	load 0b0001 r14 			; Default state, CS high

	;delay some time
	savpc r15
	jump LongWaitLoop

	
	load 0xFFFF r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4800 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4900 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4C00 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4D00 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4AFF r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4B0B r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4400 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x450C r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x46FF r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4711 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0xBF03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F02 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x5414 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x5676 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x5704 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0xBF03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x0A00 r1 				; Data to send (r1)
	load 8 r9
	shiftl r1 r9 r1 			; Shift to left by 2 to get 0A0000
	load 23 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0xBF03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F01 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x58B1 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x483F r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4930 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x50F9 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x51F7 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0xBF03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F02 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4001 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x8232 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4612 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x470C r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4412 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4ADC r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4B05 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x5410 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x5600 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x5701 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0xBF03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x0A00 r1 				; Data to send (r1)
	load 8 r9
	shiftl r1 r9 r1 			; Shift to left by 2 to get 0A0000
	load 23 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0xBF03 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F00 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9BC0 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F04 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop





	SendPacket:

	;delay some time
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop
	savpc r15
	jump LongWaitLoop



	load 0x4200 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x430C r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x4602 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x470C r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x7A00 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x7AAA r1 				; Data to send (r1)
	load 8 r9
	shiftl r1 r9 r1 			; Shift to left by 2 to get 7AAA00
	add 0xBB r1 r1 				; Add BB to get 7AAABB
	load 23 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop

	load 0x9F08 r1 				; Data to send (r1)
	load 15 r3 					; Number of bits to send (-1) (r3)
	savpc r15
	jump SendSPI				; Send
	savpc r15
	jump SmallWaitLoop



	jump SendPacket


	halt



;FUNCTIONS

;sends bits over SPI
;number of bits to send (-1) needs to be specified in r3 upon calling this function
SendSPI:
	or r0 r15 r13 			; Backup return register to r13

	;start SPI transmission
	savpc r15
	jump EnableChip

	SendBits:
	shiftl 1 r3 r4 			; Bitmask (r4)

	;send high or low based on bit
	and r4 r1 r2	; Bitmask result (r2)
	savpc r15
	beq r0 r2 ShiftLow
	savpc r15
	bne r0 r2 ShiftHigh

	beq r0 r3 DoneSending	; When r3 reached 0, we have sent all bits

	load 1 r2
	sub r3 r2 r3 			; Sub r3 by one
	jump SendBits 			; Send next bit

	DoneSending:
	;stop SPI transmission
	savpc r15
	jump DisableChip
	
	jump 2 r13 				; return using backup register


;enable device
EnableChip:
	and 0b1110 r14 r14 		; CS  lo
	jump 2 r15				; return

;set data low and disable device
DisableChip:
	and 0b1011 r14 r14 		; SO  lo
	or  0b0001 r14 r14 		; CS  hi
	jump 2 r15				; return

;clock high bit
ShiftHigh:
	or  0b0100 r14 r14 		; SO  hi
	or  0b0010 r14 r14 		; SCK hi
	or  r0     r0  r0 		; Delay for longer clock pulses
	and 0b1101 r14 r14 		; SCK lo
	jump 2 r15				; return

;clock low bit
ShiftLow:
	and 0b1011 r14 r14 		; SO  lo
	or  0b0010 r14 r14 		; SCK hi
	or  r0     r0  r0 		; Delay for longer clock pulses
	and 0b1101 r14 r14 		; SCK lo
	jump 2 r15				; return

;wait a a number of clocks specified in r6
LongWaitLoop:
	load 0 r5
	load 60000 r6

	LongRepeatLoop:
	add 1 r5 r5
	bgt r6 r5 LongRepeatLoop

	jump 2 r15

;wait a a number of clocks specified in r6
SmallWaitLoop:
	load 0 r5
	load 1000 r6

	SmallRepeatLoop:
	add 1 r5 r5
	bgt r6 r5 SmallRepeatLoop

	jump 2 r15


Int1:						; Interrupt1 handler
	reti 					; Return from interrupt

Int2:						; Interrupt2 handler
	reti 					; Return from interrupt

Int3:						; Interrupt3 handler
	reti 					; Return from interrupt

Int4:						; Interrupt4 handler, Vsync interrupt
	reti 					; Return from interrupt