; This file is used to look up how certain things were done by the shivyC compiler (for when I'm confused with SmallerC)
; Setup stack and return function before jumping to Main of C program
Main:
    load32 0x77FFFF rsp     ; initialize (BDOS) main stack address
    addr2reg Return_UART r1 ; get address of return function
    sub r1 4 r1             ; remove 4 from address, since function return has offset 4
    write 0 rsp r1          ; write return address on stack
    jump Label_main         ; jump to main of C program
                            ; should return to the address we just put on the stack
    halt                    ; should not get here

; Function that is called after Main of C program has returned
; Return value should be in R1
; Send it over UART and halt afterwards
Return_UART:
    load32 0xC02723 r2          ; r2 = 0xC02723 | UART tx
    write 0 r2 r1               ; write r1 over UART
    halt                        ; halt

; COMPILED C CODE HERE

Label_UserprogramRunning:
	.dw 0
Label_timer1Value:
	.dw 0
Label_timer2Value:
	.dw 0
Label_timer3Value:
	.dw 0
Label_GFX_cursor:
	.dw 0
Label_hidfifo:
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
Label_hidreadIdx:
	.dw 0
Label_hidwriteIdx:
	.dw 0
Label_hidbufSize:
	.dw 0
Label_ps2caps:
	.dw 0
Label_ps2shifted:
	.dw 0
Label_ps2controlled:
	.dw 0
Label_ps2alted:
	.dw 0
Label_ps2extended:
	.dw 0
Label_ps2released:
	.dw 0
Label_USBkeyboard_endp_mode:
	.dw 128
Label_USBkeyboard_buffer:
	.dw 0 0 0 0 0 0 0 0
Label_USBkeyboard_buffer_prev:
	.dw 0 0 0 0 0 0 0 0
Label_USBkeyboard_holdCounter:
	.dw 0
Label_USBkeyboard_holdButton:
	.dw 0
Label_NETLOADER_transferState:
	.dw 0
Label_NETLOADER_wordPosition:
	.dw 0
Label_NETLOADER_currentByteShift:
	.dw 24
Label_SHELL_commandIdx:
	.dw 0
Label_SHELL_promptCursorPos:
	.dw 0
Label___strlit1437:
	.dw 10 0
Label___strlit1438:
	.dw 10 0
Label___strlit1439:
	.dw 10 0
Label___strlit1440:
	.dw 10 0
Label___strlit1441:
	.dw 10 0
Label___strlit1442:
	.dw 69 58 32 69 114 114 111 114 32 119 104 105 108 101 32 114 101 97 100 105 110 103 32 100 97 116 97 0
Label___strlit1443:
	.dw 69 58 32 69 114 114 111 114 32 119 104 105 108 101 32 119 114 105 116 105 110 103 32 100 97 116 97 0
Label___strlit1444:
	.dw 47 0
Label___strlit1445:
	.dw 70 65 84 115 116 114 105 110 103 58 32 76 101 110 32 97 114 103 117 109 101 110 116 32 62 32 56 0
Label___strlit1446:
	.dw 85 110 101 120 112 101 99 116 101 100 32 70 65 84 32 116 97 98 108 101 32 108 101 110 103 116 104 0
Label___strlit1447:
	.dw 46 32 32 32 32 32 32 32 32 32 32 0
Label___strlit1448:
	.dw 46 46 32 32 32 32 32 32 32 32 32 0
Label___strlit1449:
	.dw 42 0
Label___strlit1450:
	.dw 47 0
Label___strlit1451:
	.dw 47 0
Label___strlit1452:
	.dw 69 58 32 72 73 68 32 66 117 102 102 101 114 32 102 117 108 108 0
Label___strlit1453:
	.dw 69 58 32 72 73 68 32 66 117 102 102 101 114 32 101 109 112 116 121 0
Label___strlit1454:
	.dw 78 69 87 10 0
Label___strlit1455:
	.dw 85 83 66 10 0
Label___strlit1456:
	.dw 68 65 84 10 0
Label___strlit1457:
	.dw 69 78 68 10 0
Label___strlit1458:
	.dw 68 65 84 10 0
Label___strlit1459:
	.dw 69 78 68 10 0
Label___strlit1460:
	.dw 69 82 82 79 82 0
Label___strlit1461:
	.dw 68 79 78 69 0
Label___strlit1462:
	.dw 62 32 0
Label___strlit1463:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1464:
	.dw 47 66 73 78 47 0
Label___strlit1465:
	.dw 76 111 97 100 105 110 103 32 112 114 111 103 114 97 109 0
Label___strlit1466:
	.dw 87 58 32 69 114 114 111 114 32 114 101 97 100 105 110 103 32 102 105 108 101 10 0
Label___strlit1467:
	.dw 100 111 110 101 33 10 0
Label___strlit1468:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 109 111 118 101 32 116 111 32 115 116 97 114 116 32 111 102 32 102 105 108 101 10 0
Label___strlit1469:
	.dw 69 58 32 80 114 111 103 114 97 109 32 105 115 32 116 111 111 32 108 97 114 103 101 10 0
Label___strlit1470:
	.dw 69 58 32 85 110 107 110 111 119 110 32 99 111 109 109 97 110 100 10 0
Label___strlit1471:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 111 112 101 110 32 102 105 108 101 10 0
Label___strlit1472:
	.dw 69 58 32 85 110 107 110 111 119 110 32 99 111 109 109 97 110 100 10 0
Label___strlit1473:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1474:
	.dw 87 58 32 69 114 114 111 114 32 114 101 97 100 105 110 103 32 102 105 108 101 10 0
Label___strlit1475:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 109 111 118 101 32 116 111 32 115 116 97 114 116 32 111 102 32 102 105 108 101 10 0
Label___strlit1476:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 111 112 101 110 32 102 105 108 101 10 0
Label___strlit1477:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1478:
	.dw 70 105 108 101 32 114 101 109 111 118 101 100 10 0
Label___strlit1479:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 100 101 108 101 116 101 32 102 105 108 101 10 0
Label___strlit1480:
	.dw 68 105 114 32 114 101 109 111 118 101 100 10 0
Label___strlit1481:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 100 101 108 101 116 101 32 100 105 114 10 0
Label___strlit1482:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 102 105 110 100 32 102 105 108 101 32 111 114 32 100 105 114 10 0
Label___strlit1483:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1484:
	.dw 70 105 108 101 32 99 114 101 97 116 101 100 10 0
Label___strlit1485:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 99 114 101 97 116 101 32 102 105 108 101 10 0
Label___strlit1486:
	.dw 69 58 32 70 105 108 101 110 97 109 101 32 116 111 111 32 108 111 110 103 10 0
Label___strlit1487:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1488:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1489:
	.dw 68 105 114 32 99 114 101 97 116 101 100 10 0
Label___strlit1490:
	.dw 69 58 32 67 111 117 108 100 32 110 111 116 32 99 114 101 97 116 101 32 100 105 114 10 0
Label___strlit1491:
	.dw 69 58 32 70 105 108 101 110 97 109 101 32 116 111 111 32 108 111 110 103 10 0
Label___strlit1492:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1493:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1494:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1495:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1496:
	.dw 66 68 79 83 32 102 111 114 32 70 80 71 67 10 0
Label___strlit1497:
	.dw 67 117 114 114 101 110 116 108 121 32 115 117 112 112 111 114 116 101 100 32 99 111 109 109 97 110 100 115 58 10 0
Label___strlit1498:
	.dw 45 32 82 85 78 32 32 32 32 91 97 114 103 49 93 10 0
Label___strlit1499:
	.dw 45 32 67 68 32 32 32 32 32 91 97 114 103 49 93 10 0
Label___strlit1500:
	.dw 45 32 76 83 32 32 32 32 32 91 97 114 103 49 93 10 0
Label___strlit1501:
	.dw 45 32 67 76 69 65 82 10 0
Label___strlit1502:
	.dw 45 32 80 82 73 78 84 32 32 91 97 114 103 49 93 10 0
Label___strlit1503:
	.dw 45 32 77 75 68 73 82 32 32 91 97 114 103 49 93 10 0
Label___strlit1504:
	.dw 45 32 77 75 70 73 76 69 32 91 97 114 103 49 93 10 0
Label___strlit1505:
	.dw 45 32 82 77 32 32 32 32 32 91 97 114 103 49 93 10 0
Label___strlit1506:
	.dw 45 32 72 69 76 80 10 0
Label___strlit1507:
	.dw 10 69 120 116 114 97 32 105 110 102 111 58 10 0
Label___strlit1508:
	.dw 80 97 116 104 115 32 99 97 110 32 98 101 32 114 101 108 97 116 105 118 101 32 111 114 32 97 98 115 111 108 117 116 101 10 0
Label___strlit1509:
	.dw 85 110 114 101 99 111 103 110 105 122 101 100 32 99 111 109 109 97 110 100 115 32 119 105 108 108 32 98 101 32 108 111 111 107 101 100 10 32 117 112 32 105 110 32 116 104 101 32 47 66 73 78 32 100 105 114 44 32 105 102 32 97 32 102 105 108 101 32 109 97 116 99 104 101 115 10 32 116 104 101 32 99 111 109 109 97 110 100 32 116 104 101 110 32 105 116 32 119 105 108 108 32 98 101 32 101 120 101 99 117 116 101 100 10 0
Label___strlit1510:
	.dw 114 117 110 0
Label___strlit1511:
	.dw 69 58 32 69 120 112 101 99 116 101 100 32 49 32 97 114 103 117 109 101 110 116 10 0
Label___strlit1512:
	.dw 108 115 0
Label___strlit1513:
	.dw 69 58 32 84 111 111 32 109 97 110 121 32 97 114 103 117 109 101 110 116 115 10 0
Label___strlit1514:
	.dw 0
Label___strlit1515:
	.dw 99 100 0
Label___strlit1516:
	.dw 69 58 32 84 111 111 32 109 97 110 121 32 97 114 103 117 109 101 110 116 115 10 0
Label___strlit1517:
	.dw 69 58 32 73 110 118 97 108 105 100 32 112 97 116 104 10 0
Label___strlit1518:
	.dw 99 108 101 97 114 0
Label___strlit1519:
	.dw 112 114 105 110 116 0
Label___strlit1520:
	.dw 69 58 32 69 120 112 101 99 116 101 100 32 49 32 97 114 103 117 109 101 110 116 10 0
Label___strlit1521:
	.dw 114 109 0
Label___strlit1522:
	.dw 69 58 32 69 120 112 101 99 116 101 100 32 49 32 97 114 103 117 109 101 110 116 10 0
Label___strlit1523:
	.dw 109 107 102 105 108 101 0
Label___strlit1524:
	.dw 69 58 32 69 120 112 101 99 116 101 100 32 49 32 97 114 103 117 109 101 110 116 10 0
Label___strlit1525:
	.dw 109 107 100 105 114 0
Label___strlit1526:
	.dw 69 58 32 69 120 112 101 99 116 101 100 32 49 32 97 114 103 117 109 101 110 116 10 0
Label___strlit1527:
	.dw 104 101 108 112 0
Label___strlit1528:
	.dw 99 112 0
Label___strlit1529:
	.dw 69 58 32 69 120 112 101 99 116 101 100 32 50 32 97 114 103 117 109 101 110 116 10 0
Label___strlit1530:
	.dw 69 114 114 111 114 32 105 110 105 116 105 97 108 105 122 105 110 103 32 67 72 51 55 54 32 102 111 114 32 70 83 0
Label___strlit1531:
	.dw 67 111 117 108 100 32 110 111 116 32 109 111 117 110 116 32 100 114 105 118 101 0
Label___strlit1532:
	.dw 66 68 79 83 10 0
Label___strlit1533:
	.dw 68 111 119 110 108 111 97 100 105 110 103 32 102 105 108 101 0
Label___strlit1534:
	.dw 68 111 110 101 33 10 0

Label_MATH_divmod:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	or r0 r4 r8
	; LOADARG
	or r0 r3 r9
	; SET
	load32 0 r3
	; SET
	load32 0 r2
	; EQUALCMP
	load32 1 r1
	or r0 r8 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label507
	load32 0 r1
Label___shivyc_label507:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label1
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label1:
	; SET
	load32 31 r4
	; LABEL
Label___shivyc_label2:
	; GREATEROREQCMP
	load32 1 r1
	or r0 r4 r12
	load32 0 r13
	bgt r13 r12 2
	jump Label___shivyc_label508
	load32 0 r1
Label___shivyc_label508:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label4
	; LBITSHIFT
	or r0 r3 r12
	load32 1 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r3
	; LBITSHIFT
	or r0 r2 r12
	load32 1 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r2
	; LBITSHIFT
	load32 1 r12
	or r0 r4 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; AND
	or r0 r5 r12
	or r0 r1 r13
	and r12 r13 r12
	or r0 r12 r1
	; RBITSHIFT
	or r0 r1 r12
	or r0 r4 r13
	shiftr r12 r13 r12
	or r0 r12 r1
	; OR
	or r0 r2 r12
	or r0 r1 r13
	or r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r2
	; GREATEROREQCMP
	load32 1 r1
	or r0 r2 r12
	or r0 r8 r13
	bgt r13 r12 2
	jump Label___shivyc_label509
	load32 0 r1
Label___shivyc_label509:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label5
	; SUBTR
	or r0 r2 r12
	or r0 r8 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r2
	; OR
	or r0 r3 r12
	load32 1 r13
	or r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r3
	; LABEL
Label___shivyc_label5:
	; EQUALCMP
	load32 1 r1
	or r0 r4 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label510
	load32 0 r1
Label___shivyc_label510:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label6
	; EQUALCMP
	load32 1 r1
	or r0 r9 r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label511
	load32 0 r1
Label___shivyc_label511:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label7
	; RETURN
	or r0 r2 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label8
	; LABEL
Label___shivyc_label7:
	; RETURN
	or r0 r3 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label8:
	; LABEL
Label___shivyc_label6:
	; LABEL
Label___shivyc_label3:
	; SET
	or r0 r4 r1
	; SUBTR
	or r0 r4 r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r4
	; JUMP
	jump Label___shivyc_label2
	; LABEL
Label___shivyc_label4:
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_MATH_div:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	; ADDROF
	addr2reg Label_MATH_divmod r1
	; CALL
	load32 0 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_MATH_mod:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	; ADDROF
	addr2reg Label_MATH_divmod r1
	; CALL
	load32 1 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_memcpy:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	; LOADARG
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label9:
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	or r0 r3 r13
	bge r12 r13 2
	jump Label___shivyc_label512
	load32 0 r1
Label___shivyc_label512:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label11
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r8
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	write 0 r1 r8
	; LABEL
Label___shivyc_label10:
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label9
	; LABEL
Label___shivyc_label11:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_memcmp:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	; LOADARG
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label12:
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	or r0 r3 r13
	bge r12 r13 2
	jump Label___shivyc_label513
	load32 0 r1
Label___shivyc_label513:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label14
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r8
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r9
	read 0 r9 r1
	; SET
	; SET
	; NOTEQUALCMP
	load32 1 r9
	or r0 r8 r12
	or r0 r1 r13
	beq r13 r12 2
	jump Label___shivyc_label514
	load32 0 r9
Label___shivyc_label514:
	; JUMPZERO
	or r0 r9 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label15
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label15:
	; LABEL
Label___shivyc_label13:
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label12
	; LABEL
Label___shivyc_label14:
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_strlen:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; SET
	load32 0 r1
	; READAT
	or r0 r5 r3
	read 0 r3 r2
	; SET
	; LABEL
Label___shivyc_label16:
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r2 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label515
	load32 0 r3
Label___shivyc_label515:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label17
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	; SET
	or r0 r5 r2
	; ADD
	or r0 r5 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r5
	; SET
	; READAT
	or r0 r5 r3
	read 0 r3 r2
	; SET
	; JUMP
	jump Label___shivyc_label16
	; LABEL
Label___shivyc_label17:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_strcpy:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	; SET
	load32 0 r1
	; LABEL
Label___shivyc_label18:
	; SET
	or r0 r1 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r4 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r3
	read 0 r3 r2
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r2 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label516
	load32 0 r3
Label___shivyc_label516:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label19
	; SET
	or r0 r1 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r4 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r2
	read 0 r2 r3
	; SET
	or r0 r1 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	write 0 r2 r3
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	; JUMP
	jump Label___shivyc_label18
	; LABEL
Label___shivyc_label19:
	; SET
	or r0 r1 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	load32 0 r12
	write 0 r2 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_strcat:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; LOADARG
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label20:
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label517
	load32 0 r3
Label___shivyc_label517:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label21
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label20
	; LABEL
Label___shivyc_label21:
	; ADDROF
	addr2reg Label_strcpy r1
	; SET
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; CALL
	or r0 r2 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_strcmp:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 3 rsp
	; LOADARG
	write -1 rbp r5
	; LOADARG
	write -2 rbp r4
	; LOADARG
	; ADDROF
	addr2reg Label_strlen r1
	; CALL
	read -1 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	write -3 rbp r1
	; ADDROF
	addr2reg Label_strlen r1
	; CALL
	read -2 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	read -3 rbp r12
	or r0 r1 r13
	beq r13 r12 2
	jump Label___shivyc_label518
	load32 0 r2
Label___shivyc_label518:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label22
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label22:
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label23:
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -1 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label519
	load32 0 r3
Label___shivyc_label519:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label24
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -1 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r3
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -2 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r4
	read 0 r4 r1
	; SET
	; SET
	; NOTEQUALCMP
	load32 1 r4
	or r0 r3 r12
	or r0 r1 r13
	beq r13 r12 2
	jump Label___shivyc_label520
	load32 0 r4
Label___shivyc_label520:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label25
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label25:
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label23
	; LABEL
Label___shivyc_label24:
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_itoar:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 7 rsp
	; LOADARG
	write -4 rbp r5
	; LOADARG
	write -5 rbp r4
	; ADDROF
	addr2reg Label_MATH_mod r1
	; CALL
	read -4 rbp r5
	load32 10 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -6 rbp r1
	; SET
	load32 0 r12
	write -7 rbp r12
	; ADDROF
	addr2reg Label_MATH_div r1
	; CALL
	read -4 rbp r5
	load32 10 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -4 rbp r1
	; GREATERCMP
	load32 1 r1
	read -4 rbp r12
	load32 0 r13
	bge r13 r12 2
	jump Label___shivyc_label521
	load32 0 r1
Label___shivyc_label521:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label26
	; ADDROF
	addr2reg Label_itoar r1
	; CALL
	read -4 rbp r5
	read -5 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -7 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -7 rbp r1
	; LABEL
Label___shivyc_label26:
	; ADD
	read -6 rbp r12
	load32 48 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	read -7 rbp r1
	; ADD
	read -7 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	write -7 rbp r3
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -5 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	; SETAT
	or r0 r1 r1
	write 0 r1 r2
	; RETURN
	read -7 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_itoa:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 8 rsp
	; LOADARG
	; LOADARG
	write -8 rbp r4
	; ADDROF
	addr2reg Label_itoar r1
	; CALL
	read -8 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -8 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_itoahr:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 12 rsp
	; LOADARG
	write -9 rbp r5
	; LOADARG
	write -10 rbp r4
	; ADDROF
	addr2reg Label_MATH_mod r1
	; CALL
	read -9 rbp r5
	load32 16 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -11 rbp r1
	; SET
	load32 0 r12
	write -12 rbp r12
	; ADDROF
	addr2reg Label_MATH_div r1
	; CALL
	read -9 rbp r5
	load32 16 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -9 rbp r1
	; GREATERCMP
	load32 1 r1
	read -9 rbp r12
	load32 0 r13
	bge r13 r12 2
	jump Label___shivyc_label522
	load32 0 r1
Label___shivyc_label522:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label27
	; ADDROF
	addr2reg Label_itoahr r1
	; CALL
	read -9 rbp r5
	read -10 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -12 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -12 rbp r1
	; LABEL
Label___shivyc_label27:
	; GREATERCMP
	load32 1 r1
	read -11 rbp r12
	load32 9 r13
	bge r13 r12 2
	jump Label___shivyc_label523
	load32 0 r1
Label___shivyc_label523:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label28
	; ADD
	read -11 rbp r12
	load32 65 r13
	add r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	load32 10 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label29
	; LABEL
Label___shivyc_label28:
	; ADD
	read -11 rbp r12
	load32 48 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; LABEL
Label___shivyc_label29:
	; SET
	read -12 rbp r1
	; ADD
	read -12 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	write -12 rbp r3
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -10 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	write 0 r1 r2
	; RETURN
	read -12 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_itoah:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 13 rsp
	; LOADARG
	; LOADARG
	write -13 rbp r4
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -13 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 48 r12
	write 0 r1 r12
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -13 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 120 r12
	write 0 r1 r12
	; MULT
	load32 2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -13 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -13 rbp r1
	; ADDROF
	addr2reg Label_itoahr r1
	; CALL
	read -13 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -13 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_strToInt:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; SET
	load32 0 r2
	; SET
	load32 1 r4
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label30:
	; SET
	or r0 r3 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r8
	read 0 r8 r1
	; SET
	; NOTEQUALCMP
	load32 1 r8
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label524
	load32 0 r8
Label___shivyc_label524:
	; JUMPZERO
	or r0 r8 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label31
	; SET
	or r0 r3 r1
	; ADD
	or r0 r3 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r3
	; JUMP
	jump Label___shivyc_label30
	; LABEL
Label___shivyc_label31:
	; EQUALCMP
	load32 1 r1
	or r0 r3 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label525
	load32 0 r1
Label___shivyc_label525:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label32
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label32:
	; SET
	or r0 r3 r1
	; SUBTR
	or r0 r3 r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r3
	; LABEL
Label___shivyc_label33:
	; GREATERCMP
	load32 1 r1
	or r0 r3 r12
	load32 0 r13
	bge r13 r12 2
	jump Label___shivyc_label526
	load32 0 r1
Label___shivyc_label526:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label34
	; SET
	or r0 r3 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r8
	read 0 r8 r1
	; SET
	; SUBTR
	or r0 r1 r12
	load32 48 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	; MULT
	or r0 r4 r12
	or r0 r1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; SET
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r2
	; MULT
	or r0 r4 r12
	load32 10 r13
	mult r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r4
	; SET
	or r0 r3 r1
	; SUBTR
	or r0 r3 r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r3
	; JUMP
	jump Label___shivyc_label33
	; LABEL
Label___shivyc_label34:
	; SET
	or r0 r3 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; SUBTR
	or r0 r1 r12
	load32 48 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	; MULT
	or r0 r4 r12
	or r0 r1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; SET
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r2
	; RETURN
	or r0 r2 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprintc:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; SET
	load32 12592931 r1
	; SET
	; SETAT
	or r0 r1 r1
	write 0 r1 r5
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprint:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; SET
	load32 12592931 r3
	; READAT
	or r0 r5 r1
	read 0 r1 r2
	; SET
	; LABEL
Label___shivyc_label35:
	; SET
	or r0 r2 r1
	; NOTEQUALCMP
	load32 1 r4
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label527
	load32 0 r4
Label___shivyc_label527:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label36
	; SET
	; SETAT
	or r0 r3 r1
	write 0 r1 r2
	; SET
	or r0 r5 r1
	; ADD
	or r0 r5 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r5
	; SET
	; READAT
	or r0 r5 r1
	read 0 r1 r2
	; SET
	; JUMP
	jump Label___shivyc_label35
	; LABEL
Label___shivyc_label36:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprintln:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 0 rsp
	; LOADARG
	; ADDROF
	addr2reg Label_uprint r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDROF
	addr2reg Label___strlit1437 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprintDec:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 24 rsp
	; LOADARG
	; ADDROF
	addr2reg Label_itoa r1
	; ADDRREL
	sub rbp 24 r4 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDRREL
	sub rbp 24 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDROF
	addr2reg Label___strlit1438 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprintHex:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 35 rsp
	; LOADARG
	; ADDROF
	addr2reg Label_itoah r1
	; ADDRREL
	sub rbp 35 r4 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDRREL
	sub rbp 35 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDROF
	addr2reg Label___strlit1439 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprintlnDec:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 46 rsp
	; LOADARG
	; ADDROF
	addr2reg Label_itoa r1
	; ADDRREL
	sub rbp 46 r4 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDRREL
	sub rbp 46 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDROF
	addr2reg Label___strlit1440 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_uprintlnHex:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 57 rsp
	; LOADARG
	; ADDROF
	addr2reg Label_itoah r1
	; ADDRREL
	sub rbp 57 r4 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDRREL
	sub rbp 57 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDROF
	addr2reg Label___strlit1441 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_delay:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 57 rsp
	; LOADARG
	; SET
	load32 0 r12
	addr2reg Label_timer1Value r7
	write 0 r7 r12
	; SET
	load32 12592953 r1
	; SETAT
	or r0 r1 r1
	write 0 r1 r5
	; SET
	load32 12592954 r1
	; SETAT
	or r0 r1 r1
	load32 1 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label37:
	; EQUALCMP
	load32 1 r1
	addr2reg Label_timer1Value r7
	read 0 r7 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label528
	load32 0 r1
Label___shivyc_label528:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label38
	; JUMP
	jump Label___shivyc_label37
	; LABEL
Label___shivyc_label38:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_getIntID:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 57 rsp
	; ASMCODE
	readintid r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_toUpper:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 57 rsp
	; LOADARG
	; SET
	or r0 r5 r1
	; GREATERCMP
	load32 1 r2
	or r0 r1 r12
	load32 96 r13
	bge r13 r12 2
	jump Label___shivyc_label529
	load32 0 r2
Label___shivyc_label529:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label40
	; SET
	or r0 r5 r1
	; LESSCMP
	load32 1 r2
	or r0 r1 r12
	load32 123 r13
	bge r12 r13 2
	jump Label___shivyc_label530
	load32 0 r2
Label___shivyc_label530:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label40
	; JUMP
	jump Label___shivyc_label41
	; LABEL
Label___shivyc_label40:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label41:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label39
	; SET
	; XOR
	or r0 r5 r12
	load32 32 r13
	xor r12 r13 r12
	or r0 r12 r5
	; SET
	; LABEL
Label___shivyc_label39:
	; RETURN
	or r0 r5 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_strToUpper:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 58 rsp
	; LOADARG
	write -58 rbp r5
	; READAT
	read -58 rbp r1
	read 0 r1 r5
	; SET
	; LABEL
Label___shivyc_label42:
	; SET
	or r0 r5 r1
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label531
	load32 0 r2
Label___shivyc_label531:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label43
	; ADDROF
	addr2reg Label_toUpper r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SETAT
	read -58 rbp r2
	write 0 r2 r1
	; SET
	read -58 rbp r1
	; ADD
	read -58 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -58 rbp r1
	; READAT
	read -58 rbp r1
	read 0 r1 r5
	; SET
	; JUMP
	jump Label___shivyc_label42
	; LABEL
Label___shivyc_label43:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_hexdump:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 78 rsp
	; LOADARG
	write -75 rbp r5
	; LOADARG
	write -76 rbp r4
	; SET
	load32 0 r12
	write -77 rbp r12
	; LABEL
Label___shivyc_label44:
	; LESSCMP
	load32 1 r1
	read -77 rbp r12
	read -76 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label532
	load32 0 r1
Label___shivyc_label532:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label46
	; NOTEQUALCMP
	load32 1 r1
	read -77 rbp r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label533
	load32 0 r1
Label___shivyc_label533:
	; SET
	load32 1 r12
	write -78 rbp r12
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label48
	; ADDROF
	addr2reg Label_MATH_mod r1
	; CALL
	read -77 rbp r5
	load32 8 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label534
	load32 0 r2
Label___shivyc_label534:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label48
	; JUMP
	jump Label___shivyc_label49
	; LABEL
Label___shivyc_label48:
	; SET
	load32 0 r12
	write -78 rbp r12
	; LABEL
Label___shivyc_label49:
	; JUMPZERO
	read -78 rbp r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label47
	; ADDROF
	addr2reg Label_uprintc r1
	; CALL
	load32 10 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label47:
	; ADDROF
	addr2reg Label_itoah r2
	; SET
	read -77 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -75 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r5
	; SET
	; ADDRREL
	sub rbp 74 r4 ;lea
	; CALL
	or r0 r2 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprint r1
	; ADDRREL
	sub rbp 74 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_uprintc r1
	; CALL
	load32 32 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label45:
	; SET
	read -77 rbp r1
	; ADD
	read -77 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -77 rbp r1
	; JUMP
	jump Label___shivyc_label44
	; LABEL
Label___shivyc_label46:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_asmDefines:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	define GFX_PATTERN_TABLE_SIZE       = 1024
	define GFX_PALETTE_TABLE_SIZE       = 32
	define GFX_WINDOW_TILES             = 1920
	define GFX_BG_TILES                 = 2048
	define GFX_SPRITES                  = 64
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_printWindowColored:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; LOADARG
	; LOADARG
	; LOADARG
	; ASMCODE
	push r1
	push r6
	push r7
	push r8
	push r9
	push r10
	load32 0xC01420 r10
	load 0 r1
	or r10 r0 r6
	or r5 r0 r7
	add r3 r6 r6
	GFX_printWindowColoredLoop:
	read 0 r7 r9
	write 0 r6 r9
	write 2048 r6 r2
	add r6 1 r6
	add r7 1 r7
	add r1 1 r1
	bge r1 r4 2
	jump GFX_printWindowColoredLoop
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_printBGColored:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; LOADARG
	; LOADARG
	; LOADARG
	; ASMCODE
	push r1
	push r6
	push r7
	push r8
	push r9
	push r10
	load32 0xC00420 r10
	load 0 r1
	or r10 r0 r6
	or r5 r0 r7
	add r3 r6 r6
	GFX_printBGColoredLoop:
	read 0 r7 r9
	write 0 r6 r9
	write 2048 r6 r2
	add r6 1 r6
	add r7 1 r7
	add r1 1 r1
	bge r1 r4 2
	jump GFX_printBGColoredLoop
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_copyPatternTable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; ASMCODE
	push r2
	push r3
	push r4
	push r1
	push r6
	load32 0xC00000 r2
	load 0 r3
	load GFX_PATTERN_TABLE_SIZE r4
	or r2 r0 r1
	add r5 4 r6
	GFX_initPatternTableLoop:
	copy 0 r6 r1
	add r1 1 r1
	add r6 1 r6
	add r3 1 r3
	beq r3 r4 2
	jump GFX_initPatternTableLoop
	pop r6
	pop r1
	pop r4
	pop r3
	pop r2
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_copyPaletteTable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; ASMCODE
	push r2
	push r3
	push r4
	push r1
	push r6
	load32 0xC00400 r2
	load 0 r3
	load GFX_PALETTE_TABLE_SIZE r4
	or r2 r0 r1
	add r5 4 r6
	GFX_initPaletteTableLoop:
	copy 0 r6 r1
	add r1 1 r1
	add r6 1 r6
	add r3 1 r3
	beq r3 r4 2
	jump GFX_initPaletteTableLoop
	pop r6
	pop r1
	pop r4
	pop r3
	pop r2
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_clearBGtileTable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	load32 0xC00420 r1
	load 0 r3
	load GFX_BG_TILES r4
	or r1 r0 r5
	GFX_clearBGtileTableLoop:
	write 0 r5 r0
	add r5 1 r5
	add r3 1 r3
	beq r3 r4 2
	jump GFX_clearBGtileTableLoop
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_clearBGpaletteTable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	load32 0xC00C20 r1
	load 0 r3
	load GFX_BG_TILES r4
	or r1 r0 r5
	GFX_clearBGpaletteTableLoop:
	write 0 r5 r0
	add r5 1 r5
	add r3 1 r3
	beq r3 r4 2
	jump GFX_clearBGpaletteTableLoop
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_clearWindowtileTable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	load32 0xC01420 r1
	load 0 r3
	load GFX_WINDOW_TILES r4
	or r1 r0 r5
	GFX_clearWindowtileTableLoop:
	write 0 r5 r0
	add r5 1 r5
	add r3 1 r3
	beq r3 r4 2
	jump GFX_clearWindowtileTableLoop
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_clearWindowpaletteTable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	load32 0xC01C20 r1
	load 0 r3
	load GFX_WINDOW_TILES r4
	or r1 r0 r5
	GFX_clearWindowpaletteTableLoop:
	write 0 r5 r0
	add r5 1 r5
	add r3 1 r3
	beq r3 r4 2
	jump GFX_clearWindowpaletteTableLoop
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_clearSprites:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	load32 0xC02422 r1
	load 0 r3
	load GFX_SPRITES r4
	or r1 r0 r5
	GFX_clearSpritesLoop:
	write 0 r5 r0
	write 1 r5 r0
	write 2 r5 r0
	write 3 r5 r0
	add r5 4 r5
	add r3 1 r3
	beq r3 r4 2
	jump GFX_clearSpritesLoop
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_clearParameters:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	load32 0xC02420 r1
	write 0 r1 r0
	write 1 r1 r0
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_initVram:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_GFX_clearBGtileTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearBGpaletteTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearWindowtileTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearWindowpaletteTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearSprites r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearParameters r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_WindowPosFromXY:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; LOADARG
	; MULT
	or r0 r4 r12
	load32 40 r13
	mult r12 r13 r12
	or r0 r12 r4
	; ADD
	or r0 r4 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r4
	; RETURN
	or r0 r4 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_BackgroundPosFromXY:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; LOADARG
	; MULT
	or r0 r4 r12
	load32 64 r13
	mult r12 r13 r12
	or r0 r12 r4
	; ADD
	or r0 r4 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r4
	; RETURN
	or r0 r4 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_ScrollUp:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; SET
	load32 12588064 r3
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label50:
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	load32 960 r13
	bge r12 r13 2
	jump Label___shivyc_label535
	load32 0 r1
Label___shivyc_label535:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label52
	; MULT
	load32 40 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r3 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r4
	read 0 r4 r1
	; SETAT
	or r0 r3 r4
	write 0 r4 r1
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r3 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; LABEL
Label___shivyc_label51:
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label50
	; LABEL
Label___shivyc_label52:
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label53:
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	load32 40 r13
	bge r12 r13 2
	jump Label___shivyc_label536
	load32 0 r1
Label___shivyc_label536:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label55
	; SETAT
	or r0 r3 r1
	load32 0 r12
	write 0 r1 r12
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r3 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; LABEL
Label___shivyc_label54:
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label53
	; LABEL
Label___shivyc_label55:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_printCursor:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; SET
	load32 12588064 r2
	; SET
	addr2reg Label_GFX_cursor r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 219 r12
	write 0 r1 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_PrintcConsole:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 79 rsp
	; LOADARG
	write -79 rbp r5
	; SET
	read -79 rbp r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 10 r13
	bne r13 r12 2
	jump Label___shivyc_label537
	load32 0 r1
Label___shivyc_label537:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label56
	; SET
	load32 12588064 r2
	; SET
	addr2reg Label_GFX_cursor r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; ADDROF
	addr2reg Label_MATH_div r1
	; CALL
	addr2reg Label_GFX_cursor r7
	read 0 r7 r5
	load32 40 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 40 r13
	mult r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_GFX_cursor r7
	write 0 r7 r1
	; JUMP
	jump Label___shivyc_label57
	; LABEL
Label___shivyc_label56:
	; SET
	read -79 rbp r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 8 r13
	bne r13 r12 2
	jump Label___shivyc_label538
	load32 0 r1
Label___shivyc_label538:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label58
	; GREATERCMP
	load32 1 r1
	addr2reg Label_GFX_cursor r7
	read 0 r7 r12
	load32 0 r13
	bge r13 r12 2
	jump Label___shivyc_label539
	load32 0 r1
Label___shivyc_label539:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label59
	; SET
	load32 12588064 r2
	; SET
	addr2reg Label_GFX_cursor r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; SET
	addr2reg Label_GFX_cursor r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; SUBTR
	or r0 r2 r12
	or r0 r1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; SUBTR
	addr2reg Label_GFX_cursor r7
	read 0 r7 r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_GFX_cursor r7
	write 0 r7 r1
	; LABEL
Label___shivyc_label59:
	; JUMP
	jump Label___shivyc_label60
	; LABEL
Label___shivyc_label58:
	; SET
	read -79 rbp r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 13 r13
	bne r13 r12 2
	jump Label___shivyc_label540
	load32 0 r1
Label___shivyc_label540:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label61
	; JUMP
	jump Label___shivyc_label62
	; LABEL
Label___shivyc_label61:
	; SET
	load32 12588064 r2
	; SET
	read -79 rbp r3
	; SET
	addr2reg Label_GFX_cursor r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	write 0 r1 r3
	; ADD
	addr2reg Label_GFX_cursor r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_GFX_cursor r7
	write 0 r7 r1
	; LABEL
Label___shivyc_label62:
	; LABEL
Label___shivyc_label60:
	; LABEL
Label___shivyc_label57:
	; GREATEROREQCMP
	load32 1 r1
	addr2reg Label_GFX_cursor r7
	read 0 r7 r12
	load32 1000 r13
	bgt r13 r12 2
	jump Label___shivyc_label541
	load32 0 r1
Label___shivyc_label541:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label63
	; ADDROF
	addr2reg Label_GFX_ScrollUp r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 960 r12
	addr2reg Label_GFX_cursor r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label63:
	; ADDROF
	addr2reg Label_GFX_printCursor r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_GFX_PrintConsole:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 80 rsp
	; LOADARG
	write -80 rbp r5
	; READAT
	read -80 rbp r1
	read 0 r1 r5
	; SET
	; LABEL
Label___shivyc_label64:
	; SET
	or r0 r5 r1
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label542
	load32 0 r2
Label___shivyc_label542:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label65
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; SET
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -80 rbp r1
	; ADD
	read -80 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -80 rbp r1
	; READAT
	read -80 rbp r1
	read 0 r1 r5
	; SET
	; JUMP
	jump Label___shivyc_label64
	; LABEL
Label___shivyc_label65:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_PALETTE_DEFAULT:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	.dw 0b00000000000000001111111111111111
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_ASCII_DEFAULT:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111111111001100000000000011
	.dw 0b11001100001100111100000000000011
	.dw 0b11001111111100111100001111000011
	.dw 0b11000000000000110011111111111100
	.dw 0b00111111111111001111111111111111
	.dw 0b11110011110011111111111111111111
	.dw 0b11110000000011111111110000111111
	.dw 0b11111111111111110011111111111100
	.dw 0b00111100111100001111111111111100
	.dw 0b11111111111111001111111111111100
	.dw 0b00111111111100000000111111000000
	.dw 0b00000011000000000000000000000000
	.dw 0b00000011000000000000111111000000
	.dw 0b00111111111100001111111111111100
	.dw 0b00111111111100000000111111000000
	.dw 0b00000011000000000000000000000000
	.dw 0b00001111110000000011111111110000
	.dw 0b00001111110000001111111111111100
	.dw 0b11111111111111001111001100111100
	.dw 0b00000011000000000000111111000000
	.dw 0b00000011000000000000001100000000
	.dw 0b00001111110000000011111111110000
	.dw 0b11111111111111000011111111110000
	.dw 0b00000011000000000000111111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000111111110000
	.dw 0b00001111111100000000001111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111111111111111111111
	.dw 0b11111100001111111111000000001111
	.dw 0b11110000000011111111110000111111
	.dw 0b11111111111111111111111111111111
	.dw 0b00000000000000000000111111110000
	.dw 0b00111100001111000011000000001100
	.dw 0b00110000000011000011110000111100
	.dw 0b00001111111100000000000000000000
	.dw 0b11111111111111111111000000001111
	.dw 0b11000011110000111100111111110011
	.dw 0b11001111111100111100001111000011
	.dw 0b11110000000011111111111111111111
	.dw 0b00000000111111110000000000111111
	.dw 0b00000000111111110011111111110011
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b00001111111100000011110000111100
	.dw 0b00111100001111000011110000111100
	.dw 0b00001111111100000000001111000000
	.dw 0b00111111111111000000001111000000
	.dw 0b00001111111111110000111100001111
	.dw 0b00001111111111110000111100000000
	.dw 0b00001111000000000011111100000000
	.dw 0b11111111000000001111110000000000
	.dw 0b00111111111111110011110000001111
	.dw 0b00111111111111110011110000001111
	.dw 0b00111100000011110011110000111111
	.dw 0b11111100001111001111000000000000
	.dw 0b00000011110000001111001111001111
	.dw 0b00001111111100001111110000111111
	.dw 0b11111100001111110000111111110000
	.dw 0b11110011110011110000001111000000
	.dw 0b11000000000000001111110000000000
	.dw 0b11111111110000001111111111111100
	.dw 0b11111111110000001111110000000000
	.dw 0b11000000000000000000000000000000
	.dw 0b00000000000011000000000011111100
	.dw 0b00001111111111001111111111111100
	.dw 0b00001111111111000000000011111100
	.dw 0b00000000000011000000000000000000
	.dw 0b00000011110000000000111111110000
	.dw 0b00111111111111000000001111000000
	.dw 0b00000011110000000011111111111100
	.dw 0b00001111111100000000001111000000
	.dw 0b00111100001111000011110000111100
	.dw 0b00111100001111000011110000111100
	.dw 0b00111100001111000000000000000000
	.dw 0b00111100001111000000000000000000
	.dw 0b00111111111111111111001111001111
	.dw 0b11110011110011110011111111001111
	.dw 0b00000011110011110000001111001111
	.dw 0b00000011110011110000000000000000
	.dw 0b00001111111111000011110000001111
	.dw 0b00001111110000000011110011110000
	.dw 0b00111100111100000000111111000000
	.dw 0b11110000111100000011111111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111111111000011111111111100
	.dw 0b00111111111111000000000000000000
	.dw 0b00000011110000000000111111110000
	.dw 0b00111111111111000000001111000000
	.dw 0b00111111111111000000111111110000
	.dw 0b00000011110000001111111111111111
	.dw 0b00000011110000000000111111110000
	.dw 0b00111111111111000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00111111111111000000111111110000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000001111000000
	.dw 0b00000000111100001111111111111100
	.dw 0b00000000111100000000001111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00111100000000001111111111111100
	.dw 0b00111100000000000000111100000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000000000001111000000000000
	.dw 0b11110000000000001111111111111100
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000110000110000
	.dw 0b00111100001111001111111111111111
	.dw 0b00111100001111000000110000110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000001111000000
	.dw 0b00001111111100000011111111111100
	.dw 0b11111111111111111111111111111111
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000001111111111111111
	.dw 0b11111111111111110011111111111100
	.dw 0b00001111111100000000001111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111000000000011111111000000
	.dw 0b00111111110000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00111100111100000011110011110000
	.dw 0b00111100111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111100111100000011110011110000
	.dw 0b11111111111111000011110011110000
	.dw 0b11111111111111000011110011110000
	.dw 0b00111100111100000000000000000000
	.dw 0b00001111000000000011111111110000
	.dw 0b11110000000000000011111111000000
	.dw 0b00000000111100001111111111000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000000000001111000000111100
	.dw 0b11110000111100000000001111000000
	.dw 0b00001111000000000011110000111100
	.dw 0b11110000001111000000000000000000
	.dw 0b00001111110000000011110011110000
	.dw 0b00001111110000000011111100111100
	.dw 0b11110011111100001111000011110000
	.dw 0b00111111001111000000000000000000
	.dw 0b00111100000000000011110000000000
	.dw 0b11110000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000000011110000000000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000000000000000000000
	.dw 0b00000000000000000011110000111100
	.dw 0b00001111111100001111111111111111
	.dw 0b00001111111100000011110000111100
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000001111111111110000
	.dw 0b00001111000000000000111100000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000011110000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000001111000000000011110000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000001111000000000000
	.dw 0b11000000000000000000000000000000
	.dw 0b00111111111100001111000000111100
	.dw 0b11110000111111001111001111111100
	.dw 0b11111111001111001111110000111100
	.dw 0b00111111111100000000000000000000
	.dw 0b00001111000000000011111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b11111111111100000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b00000000111100000000111111000000
	.dw 0b00111100000000001111000011110000
	.dw 0b11111111111100000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b00000000111100000000111111000000
	.dw 0b00000000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000011111100000000111111110000
	.dw 0b00111100111100001111000011110000
	.dw 0b11111111111111000000000011110000
	.dw 0b00000011111111000000000000000000
	.dw 0b11111111111100001111000000000000
	.dw 0b11111111110000000000000011110000
	.dw 0b00000000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00001111110000000011110000000000
	.dw 0b11110000000000001111111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b11111111111100001111000011110000
	.dw 0b00000000111100000000001111000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000111100000011111111110000
	.dw 0b00000000111100000000001111000000
	.dw 0b00111111000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000011110000000000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000001111000000000000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111100000000000000000000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000000000000011110000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b00000000111100000000001111000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00111111111100001111000000111100
	.dw 0b11110011111111001111001111111100
	.dw 0b11110011111111001111000000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00001111000000000011111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11111111111100001111000011110000
	.dw 0b11110000111100000000000000000000
	.dw 0b11111111111100000011110000111100
	.dw 0b00111100001111000011111111110000
	.dw 0b00111100001111000011110000111100
	.dw 0b11111111111100000000000000000000
	.dw 0b00001111111100000011110000111100
	.dw 0b11110000000000001111000000000000
	.dw 0b11110000000000000011110000111100
	.dw 0b00001111111100000000000000000000
	.dw 0b11111111110000000011110011110000
	.dw 0b00111100001111000011110000111100
	.dw 0b00111100001111000011110011110000
	.dw 0b11111111110000000000000000000000
	.dw 0b11111111111111000011110000001100
	.dw 0b00111100110000000011111111000000
	.dw 0b00111100110000000011110000001100
	.dw 0b11111111111111000000000000000000
	.dw 0b11111111111111000011110000001100
	.dw 0b00111100110000000011111111000000
	.dw 0b00111100110000000011110000000000
	.dw 0b11111111000000000000000000000000
	.dw 0b00001111111100000011110000111100
	.dw 0b11110000000000001111000000000000
	.dw 0b11110000111111000011110000111100
	.dw 0b00001111111111000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111111111110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000000000000000000
	.dw 0b00111111110000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000011111111000000000011110000
	.dw 0b00000000111100000000000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b11111100001111000011110000111100
	.dw 0b00111100111100000011111111000000
	.dw 0b00111100111100000011110000111100
	.dw 0b11111100001111000000000000000000
	.dw 0b11111111000000000011110000000000
	.dw 0b00111100000000000011110000000000
	.dw 0b00111100000011000011110000111100
	.dw 0b11111111111111000000000000000000
	.dw 0b11110000001111001111110011111100
	.dw 0b11111111111111001111111111111100
	.dw 0b11110011001111001111000000111100
	.dw 0b11110000001111000000000000000000
	.dw 0b11110000001111001111110000111100
	.dw 0b11111111001111001111001111111100
	.dw 0b11110000111111001111000000111100
	.dw 0b11110000001111000000000000000000
	.dw 0b00001111110000000011110011110000
	.dw 0b11110000001111001111000000111100
	.dw 0b11110000001111000011110011110000
	.dw 0b00001111110000000000000000000000
	.dw 0b11111111111100000011110000111100
	.dw 0b00111100001111000011111111110000
	.dw 0b00111100000000000011110000000000
	.dw 0b11111111000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110011111100000011111111000000
	.dw 0b00000011111100000000000000000000
	.dw 0b11111111111100000011110000111100
	.dw 0b00111100001111000011111111110000
	.dw 0b00111100111100000011110000111100
	.dw 0b11111100001111000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b11111111111100001100111100110000
	.dw 0b00001111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11111111111100000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b00001111000000000000000000000000
	.dw 0b11110000001111001111000000111100
	.dw 0b11110000001111001111001100111100
	.dw 0b11111111111111001111110011111100
	.dw 0b11110000001111000000000000000000
	.dw 0b11110000001111001111000000111100
	.dw 0b00111100111100000000111111000000
	.dw 0b00001111110000000011110011110000
	.dw 0b11110000001111000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b11111111111111001111000000111100
	.dw 0b11000000111100000000001111000000
	.dw 0b00001111000011000011110000111100
	.dw 0b11111111111111000000000000000000
	.dw 0b00111111110000000011110000000000
	.dw 0b00111100000000000011110000000000
	.dw 0b00111100000000000011110000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b11110000000000000011110000000000
	.dw 0b00001111000000000000001111000000
	.dw 0b00000000111100000000000000111100
	.dw 0b00000000000011000000000000000000
	.dw 0b00111111110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000011000000000000111111000000
	.dw 0b00111100111100001111000000111100
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000001111111111111111
	.dw 0b00001111000000000000111100000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111110000000000000011110000
	.dw 0b00111111111100001111000011110000
	.dw 0b00111111001111000000000000000000
	.dw 0b11111100000000000011110000000000
	.dw 0b00111100000000000011111111110000
	.dw 0b00111100001111000011110000111100
	.dw 0b11110011111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000000000001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000011111100000000000011110000
	.dw 0b00000000111100000011111111110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111001111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11111111111100001111000000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00001111110000000011110011110000
	.dw 0b00111100000000001111111100000000
	.dw 0b00111100000000000011110000000000
	.dw 0b11111111000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111001111001111000011110000
	.dw 0b11110000111100000011111111110000
	.dw 0b00000000111100001111111111000000
	.dw 0b11111100000000000011110000000000
	.dw 0b00111100111100000011111100111100
	.dw 0b00111100001111000011110000111100
	.dw 0b11111100001111000000000000000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00111111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000111100000000000000000000
	.dw 0b00000000111100000000000011110000
	.dw 0b00000000111100001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b11111100000000000011110000000000
	.dw 0b00111100001111000011110011110000
	.dw 0b00111111110000000011110011110000
	.dw 0b11111100001111000000000000000000
	.dw 0b00111111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000111100001111111111111100
	.dw 0b11111111111111001111001100111100
	.dw 0b11110000001111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111110000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110011111100000011110000111100
	.dw 0b00111100001111000011111111110000
	.dw 0b00111100000000001111111100000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111001111001111000011110000
	.dw 0b11110000111100000011111111110000
	.dw 0b00000000111100000000001111111100
	.dw 0b00000000000000000000000000000000
	.dw 0b11110011111100000011111100111100
	.dw 0b00111100001111000011110000000000
	.dw 0b11111111000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111111100001111000000000000
	.dw 0b00111111110000000000000011110000
	.dw 0b11111111110000000000000000000000
	.dw 0b00000011000000000000111100000000
	.dw 0b00111111111100000000111100000000
	.dw 0b00001111000000000000111100110000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111001111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000001111001111001100111100
	.dw 0b11111111111111001111111111111100
	.dw 0b00111100111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000001111000011110011110000
	.dw 0b00001111110000000011110011110000
	.dw 0b11110000001111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000011111111110000
	.dw 0b00000000111100001111111111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111100001100001111000000
	.dw 0b00001111000000000011110000110000
	.dw 0b11111111111100000000000000000000
	.dw 0b00000011111100000000111100000000
	.dw 0b00001111000000001111110000000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00000011111100000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000000000000000
	.dw 0b11111100000000000000111100000000
	.dw 0b00001111000000000000001111110000
	.dw 0b00001111000000000000111100000000
	.dw 0b11111100000000000000000000000000
	.dw 0b00111111001111001111001111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000001100000000
	.dw 0b00001111110000000011110011110000
	.dw 0b11110000001111001111000000111100
	.dw 0b11111111111111000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000000000001111000011110000
	.dw 0b00111111110000000000001111000000
	.dw 0b00000000111100000011111111000000
	.dw 0b00000000000000001111000011110000
	.dw 0b00000000000000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00000011111100000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11111111111100001111000000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00111111111111001111000000001111
	.dw 0b00001111111100000000000000111100
	.dw 0b00001111111111000011110000111100
	.dw 0b00001111111111110000000000000000
	.dw 0b11110000111100000000000000000000
	.dw 0b00111111110000000000000011110000
	.dw 0b00111111111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b11111100000000000000000000000000
	.dw 0b00111111110000000000000011110000
	.dw 0b00111111111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000011110000
	.dw 0b00111111111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111110000001111000000000000
	.dw 0b11110000000000000011111111000000
	.dw 0b00000000111100000000111111000000
	.dw 0b00111111111111001111000000001111
	.dw 0b00001111111100000011110000111100
	.dw 0b00111111111111000011110000000000
	.dw 0b00001111111100000000000000000000
	.dw 0b11110000111100000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11111111111100001111000000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b11111100000000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11111111111100001111000000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b11110000111100000000000000000000
	.dw 0b00111111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00111111111100001111000000111100
	.dw 0b00001111110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00001111111100000000000000000000
	.dw 0b11111100000000000000000000000000
	.dw 0b00111111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b11110000001111000000111111000000
	.dw 0b00111100111100001111000000111100
	.dw 0b11111111111111001111000000111100
	.dw 0b11110000001111000000000000000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00000000000000000011111111000000
	.dw 0b11110000111100001111111111110000
	.dw 0b11110000111100000000000000000000
	.dw 0b00000011111100000000000000000000
	.dw 0b11111111111100000011110000000000
	.dw 0b00111111110000000011110000000000
	.dw 0b11111111111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111111111110000000011110000
	.dw 0b00111111111111111111000011110000
	.dw 0b00111111111111110000000000000000
	.dw 0b00001111111111000011110011110000
	.dw 0b11110000111100001111111111111100
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111111000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b00000000000000000011111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000001111000011110000
	.dw 0b00000000000000000011111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000001111110000000000
	.dw 0b00000000000000000011111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b00000000000000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00000000000000001111110000000000
	.dw 0b00000000000000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00000000000000001111000011110000
	.dw 0b00000000000000001111000011110000
	.dw 0b11110000111100000011111111110000
	.dw 0b00000000111100001111111111000000
	.dw 0b11110000000011110000001111000000
	.dw 0b00001111111100000011110000111100
	.dw 0b00111100001111000000111111110000
	.dw 0b00000011110000000000000000000000
	.dw 0b11110000111100000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00111111111111001111000000000000
	.dw 0b11110000000000000011111111111100
	.dw 0b00000011110000000000001111000000
	.dw 0b00001111110000000011110011110000
	.dw 0b00111100001100001111111100000000
	.dw 0b00111100000000001111110000111100
	.dw 0b11111111111100000000000000000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000001111111111110000
	.dw 0b00001111000000001111111111110000
	.dw 0b00001111000000000000111100000000
	.dw 0b11111111110000001111000011110000
	.dw 0b11110000111100001111111111001100
	.dw 0b11110000001111001111000011111111
	.dw 0b11110000001111001111000000111111
	.dw 0b00000000111111000000001111001111
	.dw 0b00000011110000000000111111110000
	.dw 0b00000011110000000000001111000000
	.dw 0b11110011110000000011111100000000
	.dw 0b00000011111100000000000000000000
	.dw 0b00111111110000000000000011110000
	.dw 0b00111111111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00001111110000000000000000000000
	.dw 0b00111111000000000000111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000001111110000
	.dw 0b00000000000000000011111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000001111110000
	.dw 0b00000000000000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111111111000000000000000000
	.dw 0b00000000000000001111111111000000
	.dw 0b00000000000000001111111111000000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000000000000000000
	.dw 0b11111111111100000000000000000000
	.dw 0b11110000111100001111110011110000
	.dw 0b11111111111100001111001111110000
	.dw 0b11110000111100000000000000000000
	.dw 0b00001111111100000011110011110000
	.dw 0b00111100111100000000111111111100
	.dw 0b00000000000000000011111111111100
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111110000000011110011110000
	.dw 0b00111100111100000000111111000000
	.dw 0b00000000000000000011111111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00001111000000000011110000000000
	.dw 0b11110000000000001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000001111111111110000
	.dw 0b11110000000000001111000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000111100000000000011110000
	.dw 0b00000000000000000000000000000000
	.dw 0b11110000000011111111000000111100
	.dw 0b11110000111100001111001111111100
	.dw 0b00001111000011110011110000111100
	.dw 0b11110000111100000000000011111111
	.dw 0b11110000000011111111000000111100
	.dw 0b11110000111100001111001111001111
	.dw 0b00001111001111110011110011111111
	.dw 0b11110000111111110000000000001111
	.dw 0b00000011110000000000001111000000
	.dw 0b00000000000000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000111100001111
	.dw 0b00111100001111001111000011110000
	.dw 0b00111100001111000000111100001111
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000001111000011110000
	.dw 0b00111100001111000000111100001111
	.dw 0b00111100001111001111000011110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001100000011001100000011000000
	.dw 0b00001100000011001100000011000000
	.dw 0b00001100000011001100000011000000
	.dw 0b00001100000011001100000011000000
	.dw 0b00110011001100111100110011001100
	.dw 0b00110011001100111100110011001100
	.dw 0b00110011001100111100110011001100
	.dw 0b00110011001100111100110011001100
	.dw 0b11110011110011110011111100111111
	.dw 0b11110011110011111111110011111100
	.dw 0b11110011110011110011111100111111
	.dw 0b11110011110011111111110011111100
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111110000000000001111000000
	.dw 0b11111111110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111110000000000001111000000
	.dw 0b11111111110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111001111000000000000111100
	.dw 0b11111111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111000000000000111100
	.dw 0b11111111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111001111000000000000111100
	.dw 0b11111111111111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111111111000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111110000000000001111000000
	.dw 0b11111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111110000111100000000
	.dw 0b00001111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111111111110000111100000000
	.dw 0b00001111001111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111001111110000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b11111111001111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111110000111100000000
	.dw 0b00001111001111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111001111110000000000000000
	.dw 0b11111111001111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111111111110000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111110000000000000000
	.dw 0b11111111111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011111111110000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111111111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b11111111111111110000111100111100
	.dw 0b00001111001111000000111100111100
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111111111110000001111000000
	.dw 0b11111111111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011111111110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b11111111111111111111111111111111
	.dw 0b11111111111111111111111111111111
	.dw 0b11111111111111111111111111111111
	.dw 0b11111111111111111111111111111111
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b11111111111111111111111111111111
	.dw 0b11111111111111111111111111111111
	.dw 0b11111111000000001111111100000000
	.dw 0b11111111000000001111111100000000
	.dw 0b11111111000000001111111100000000
	.dw 0b11111111000000001111111100000000
	.dw 0b00000000111111110000000011111111
	.dw 0b00000000111111110000000011111111
	.dw 0b00000000111111110000000011111111
	.dw 0b00000000111111110000000011111111
	.dw 0b11111111111111111111111111111111
	.dw 0b11111111111111111111111111111111
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111001111001111001111110000
	.dw 0b11110000110000001111001111110000
	.dw 0b00111111001111000000000000000000
	.dw 0b00000000000000000011111111000000
	.dw 0b11110000111100001111111111000000
	.dw 0b11110000111100001111111111000000
	.dw 0b11110000000000001111000000000000
	.dw 0b00000000000000001111111111110000
	.dw 0b11110000111100001111000000000000
	.dw 0b11110000000000001111000000000000
	.dw 0b11110000000000000000000000000000
	.dw 0b00000000000000001111111111111100
	.dw 0b00111100111100000011110011110000
	.dw 0b00111100111100000011110011110000
	.dw 0b00111100111100000000000000000000
	.dw 0b11111111111100001111000011110000
	.dw 0b00111100000000000000111100000000
	.dw 0b00111100000000001111000011110000
	.dw 0b11111111111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111111111001111001111000000
	.dw 0b11110011110000001111001111000000
	.dw 0b00111111000000000000000000000000
	.dw 0b00000000000000000011110000111100
	.dw 0b00111100001111000011110000111100
	.dw 0b00111100001111000011111111110000
	.dw 0b00111100000000001111000000000000
	.dw 0b00000000000000000011111100111100
	.dw 0b11110011111100000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000000000000000
	.dw 0b11111111111100000000111100000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000111100000011111111000000
	.dw 0b00001111000000001111111111110000
	.dw 0b00001111110000000011110011110000
	.dw 0b11110000001111001111111111111100
	.dw 0b11110000001111000011110011110000
	.dw 0b00001111110000000000000000000000
	.dw 0b00001111110000000011110011110000
	.dw 0b11110000001111001111000000111100
	.dw 0b00111100111100000011110011110000
	.dw 0b11111100111111000000000000000000
	.dw 0b00000011111100000000111100000000
	.dw 0b00000011110000000011111111110000
	.dw 0b11110000111100001111000011110000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111111111001111001111001111
	.dw 0b11110011110011110011111111111100
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000001111000000000011110000
	.dw 0b00111111111111001111001111001111
	.dw 0b11110011110011110011111111111100
	.dw 0b00111100000000001111000000000000
	.dw 0b00001111110000000011110000000000
	.dw 0b11110000000000001111111111000000
	.dw 0b11110000000000000011110000000000
	.dw 0b00001111110000000000000000000000
	.dw 0b00111111110000001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100001111000011110000
	.dw 0b11110000111100000000000000000000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111000000000000111100000000
	.dw 0b11111111111100000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b11111111111100000000000000000000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000000000000000000000
	.dw 0b11111111111100000000000000000000
	.dw 0b00000011110000000000111100000000
	.dw 0b00111100000000000000111100000000
	.dw 0b00000011110000000000000000000000
	.dw 0b11111111111100000000000000000000
	.dw 0b00000000111111000000001111001111
	.dw 0b00000011110011110000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000000000001111000000
	.dw 0b00000011110000001111001111000000
	.dw 0b11110011110000000011111100000000
	.dw 0b00001111000000000000111100000000
	.dw 0b00000000000000001111111111110000
	.dw 0b00000000000000000000111100000000
	.dw 0b00001111000000000000000000000000
	.dw 0b00000000000000000011111100111100
	.dw 0b11110011111100000000000000000000
	.dw 0b00111111001111001111001111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111110000000011110011110000
	.dw 0b00111100111100000000111111000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000001111000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000011110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000111111110000000011110000
	.dw 0b00000000111100000000000011110000
	.dw 0b11111100111100000011110011110000
	.dw 0b00001111111100000000001111110000
	.dw 0b00111111110000000011110011110000
	.dw 0b00111100111100000011110011110000
	.dw 0b00111100111100000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00111111000000000000001111000000
	.dw 0b00001111000000000011110000000000
	.dw 0b00111111110000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00001111111100000000111111110000
	.dw 0b00001111111100000000111111110000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	.dw 0b00000000000000000000000000000000
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_spiBeginTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	load32 0xC0272C r2
	load 0 r1
	write 0 r2 r1
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_spiEndTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ASMCODE
	push r1
	push r2
	load32 0xC0272C r2
	load 1 r1
	write 0 r2 r1
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_spiTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LOADARG
	; ASMCODE
	load32 0xC0272B r1
	write 0 r1 r5
	read 0 r1 r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_WaitGetStatus:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 81 rsp
	; SET
	load32 1 r1
	; LABEL
Label___shivyc_label66:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label67
	; SET
	load32 12592941 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; JUMP
	jump Label___shivyc_label66
	; LABEL
Label___shivyc_label67:
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 34 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -81 rbp r1
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -81 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_noWaitGetStatus:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 82 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 34 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -82 rbp r1
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -82 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_sendString:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 83 rsp
	; LOADARG
	write -83 rbp r5
	; READAT
	read -83 rbp r1
	read 0 r1 r5
	; SET
	; LABEL
Label___shivyc_label68:
	; SET
	or r0 r5 r1
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label543
	load32 0 r2
Label___shivyc_label543:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label69
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -83 rbp r1
	; ADD
	read -83 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -83 rbp r1
	; READAT
	read -83 rbp r1
	read 0 r1 r5
	; SET
	; JUMP
	jump Label___shivyc_label68
	; LABEL
Label___shivyc_label69:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_sendData:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 86 rsp
	; LOADARG
	write -84 rbp r5
	; LOADARG
	write -85 rbp r4
	; READAT
	read -84 rbp r1
	read 0 r1 r5
	; SET
	; SET
	load32 0 r12
	write -86 rbp r12
	; LABEL
Label___shivyc_label70:
	; LESSCMP
	load32 1 r1
	read -86 rbp r12
	read -85 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label544
	load32 0 r1
Label___shivyc_label544:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label72
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -84 rbp r1
	; ADD
	read -84 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -84 rbp r1
	; READAT
	read -84 rbp r1
	read 0 r1 r5
	; SET
	; LABEL
Label___shivyc_label71:
	; SET
	read -86 rbp r1
	; ADD
	read -86 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -86 rbp r1
	; JUMP
	jump Label___shivyc_label70
	; LABEL
Label___shivyc_label72:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_getICver:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 87 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -87 rbp r1
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -87 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_setUSBmode:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 89 rsp
	; LOADARG
	write -88 rbp r5
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 21 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	read -88 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -89 rbp r1
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -89 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_init:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 60 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 5 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 100 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_setUSBmode r1
	; CALL
	load32 5 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_connectDrive:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; LABEL
Label___shivyc_label73:
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 21 r13
	beq r13 r12 2
	jump Label___shivyc_label545
	load32 0 r2
Label___shivyc_label545:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label74
	; JUMP
	jump Label___shivyc_label73
	; LABEL
Label___shivyc_label74:
	; ADDROF
	addr2reg Label_FS_setUSBmode r1
	; CALL
	load32 7 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 81 r13
	beq r13 r12 2
	jump Label___shivyc_label546
	load32 0 r2
Label___shivyc_label546:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label75
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label75:
	; ADDROF
	addr2reg Label_FS_setUSBmode r1
	; CALL
	load32 6 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 81 r13
	beq r13 r12 2
	jump Label___shivyc_label547
	load32 0 r2
Label___shivyc_label547:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label76
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label76:
	; LABEL
Label___shivyc_label77:
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 21 r13
	beq r13 r12 2
	jump Label___shivyc_label548
	load32 0 r2
Label___shivyc_label548:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label78
	; JUMP
	jump Label___shivyc_label77
	; LABEL
Label___shivyc_label78:
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 48 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label549
	load32 0 r2
Label___shivyc_label549:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label79
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label79:
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 49 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 1048576 r2
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 47 r12
	write 0 r1 r12
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_getFileSize:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 90 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 12 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 104 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -90 rbp r1
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	or r0 r1 r12
	load32 8 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; ADD
	read -90 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -90 rbp r1
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	or r0 r1 r12
	load32 16 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; ADD
	read -90 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -90 rbp r1
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	or r0 r1 r12
	load32 24 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; ADD
	read -90 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -90 rbp r1
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -90 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_setCursor:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 91 rsp
	; LOADARG
	write -91 rbp r5
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 57 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	read -91 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; RBITSHIFT
	read -91 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; RBITSHIFT
	read -91 rbp r12
	load32 16 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; RBITSHIFT
	read -91 rbp r12
	load32 24 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_readFile:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 101 rsp
	; LOADARG
	write -92 rbp r5
	; LOADARG
	write -99 rbp r4
	; LOADARG
	write -93 rbp r3
	; EQUALCMP
	load32 1 r1
	read -99 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label550
	load32 0 r1
Label___shivyc_label550:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label80
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label80:
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 58 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	read -99 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; RBITSHIFT
	read -99 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -100 rbp r1
	; NOTEQUALCMP
	load32 1 r1
	read -100 rbp r12
	load32 29 r13
	beq r13 r12 2
	jump Label___shivyc_label551
	load32 0 r1
Label___shivyc_label551:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label81
	; RETURN
	read -100 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label81:
	; SET
	load32 0 r12
	write -94 rbp r12
	; SET
	load32 0 r12
	write -95 rbp r12
	; SET
	load32 0 r12
	write -96 rbp r12
	; SET
	read -95 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -92 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; SET
	load32 24 r12
	write -97 rbp r12
	; LABEL
Label___shivyc_label82:
	; EQUALCMP
	load32 1 r1
	read -96 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label552
	load32 0 r1
Label___shivyc_label552:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label83
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 39 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -98 rbp r1
	; SET
	load32 0 r12
	write -101 rbp r12
	; LABEL
Label___shivyc_label84:
	; LESSCMP
	load32 1 r1
	read -101 rbp r12
	read -98 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label553
	load32 0 r1
Label___shivyc_label553:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label86
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; JUMPZERO
	read -93 rbp r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label87
	; LBITSHIFT
	or r0 r1 r12
	read -97 rbp r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; SET
	; SET
	read -95 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -92 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r3
	read 0 r3 r2
	; SET
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	read -95 rbp r3
	; MULT
	or r0 r3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r3
	; ADD
	read -92 rbp r12
	or r0 r3 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; SETAT
	or r0 r3 r3
	write 0 r3 r2
	; EQUALCMP
	load32 1 r2
	read -97 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label554
	load32 0 r2
Label___shivyc_label554:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label88
	; SET
	load32 24 r12
	write -97 rbp r12
	; ADD
	read -95 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	write -95 rbp r2
	; SET
	read -95 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -92 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	load32 0 r12
	write 0 r2 r12
	; JUMP
	jump Label___shivyc_label89
	; LABEL
Label___shivyc_label88:
	; SUBTR
	read -97 rbp r12
	load32 8 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	write -97 rbp r2
	; LABEL
Label___shivyc_label89:
	; JUMP
	jump Label___shivyc_label90
	; LABEL
Label___shivyc_label87:
	; SET
	; SET
	read -94 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -92 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	write 0 r2 r1
	; ADD
	read -94 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -94 rbp r1
	; LABEL
Label___shivyc_label90:
	; LABEL
Label___shivyc_label85:
	; SET
	read -101 rbp r1
	; ADD
	read -101 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -101 rbp r1
	; JUMP
	jump Label___shivyc_label84
	; LABEL
Label___shivyc_label86:
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 59 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -100 rbp r1
	; EQUALCMP
	load32 1 r1
	read -100 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label555
	load32 0 r1
Label___shivyc_label555:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label91
	; SET
	load32 1 r12
	write -96 rbp r12
	; JUMP
	jump Label___shivyc_label92
	; LABEL
Label___shivyc_label91:
	; EQUALCMP
	load32 1 r1
	read -100 rbp r12
	load32 29 r13
	bne r13 r12 2
	jump Label___shivyc_label556
	load32 0 r1
Label___shivyc_label556:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label93
	; JUMP
	jump Label___shivyc_label94
	; LABEL
Label___shivyc_label93:
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1442 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -100 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label94:
	; LABEL
Label___shivyc_label92:
	; JUMP
	jump Label___shivyc_label82
	; LABEL
Label___shivyc_label83:
	; RETURN
	read -100 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_writeFile:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 107 rsp
	; LOADARG
	write -102 rbp r5
	; LOADARG
	write -105 rbp r4
	; EQUALCMP
	load32 1 r1
	read -105 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label557
	load32 0 r1
Label___shivyc_label557:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label95
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label95:
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 60 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	read -105 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; RBITSHIFT
	read -105 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -106 rbp r1
	; NOTEQUALCMP
	load32 1 r1
	read -106 rbp r12
	load32 30 r13
	beq r13 r12 2
	jump Label___shivyc_label558
	load32 0 r1
Label___shivyc_label558:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label96
	; RETURN
	read -106 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label96:
	; SET
	load32 0 r12
	write -103 rbp r12
	; SET
	load32 0 r12
	write -104 rbp r12
	; LABEL
Label___shivyc_label97:
	; EQUALCMP
	load32 1 r1
	read -104 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label559
	load32 0 r1
Label___shivyc_label559:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label98
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 45 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -107 rbp r1
	; ADDROF
	addr2reg Label_FS_sendData r1
	; SET
	read -103 rbp r5
	; MULT
	or r0 r5 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -102 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	read -107 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -103 rbp r12
	read -107 rbp r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -103 rbp r1
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 61 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -106 rbp r1
	; EQUALCMP
	load32 1 r1
	read -106 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label560
	load32 0 r1
Label___shivyc_label560:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label99
	; SET
	load32 1 r12
	write -104 rbp r12
	; JUMP
	jump Label___shivyc_label100
	; LABEL
Label___shivyc_label99:
	; EQUALCMP
	load32 1 r1
	read -106 rbp r12
	load32 30 r13
	bne r13 r12 2
	jump Label___shivyc_label561
	load32 0 r1
Label___shivyc_label561:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label101
	; JUMP
	jump Label___shivyc_label102
	; LABEL
Label___shivyc_label101:
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1443 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -106 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label102:
	; LABEL
Label___shivyc_label100:
	; JUMP
	jump Label___shivyc_label97
	; LABEL
Label___shivyc_label98:
	; RETURN
	read -106 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_open:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 50 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_delete:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 53 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_close:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 54 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_createDir:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 64 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_createFile:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 74 rsp
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 52 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label562
	load32 0 r2
Label___shivyc_label562:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label103
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label103:
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_close r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_sendSinglePath:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 108 rsp
	; LOADARG
	write -108 rbp r5
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 47 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendString r1
	; CALL
	read -108 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_sendFullPath:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 127 rsp
	; LOADARG
	write -125 rbp r5
	; SET
	load32 0 r12
	write -126 rbp r12
	; LABEL
Label___shivyc_label104:
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label563
	load32 0 r2
Label___shivyc_label563:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label105
	; ADDROF
	addr2reg Label_toUpper r2
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r5
	; CALL
	or r0 r2 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -126 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -125 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	write 0 r2 r1
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 92 r13
	bne r13 r12 2
	jump Label___shivyc_label564
	load32 0 r2
Label___shivyc_label564:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label106
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 47 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label106:
	; ADD
	read -126 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -126 rbp r1
	; JUMP
	jump Label___shivyc_label104
	; LABEL
Label___shivyc_label105:
	; SET
	load32 0 r1
	; GREATERCMP
	load32 1 r1
	read -126 rbp r12
	load32 1 r13
	bge r13 r12 2
	jump Label___shivyc_label565
	load32 0 r1
Label___shivyc_label565:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label107
	; SUBTR
	read -126 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label566
	load32 0 r2
Label___shivyc_label566:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label108
	; SUBTR
	read -126 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; SET
	load32 1 r1
	; LABEL
Label___shivyc_label108:
	; LABEL
Label___shivyc_label107:
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label567
	load32 0 r2
Label___shivyc_label567:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label109
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; ADDROF
	addr2reg Label___strlit1444 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label109:
	; SET
	load32 0 r12
	write -126 rbp r12
	; SET
	load32 0 r12
	write -127 rbp r12
	; LABEL
Label___shivyc_label110:
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label568
	load32 0 r2
Label___shivyc_label568:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label111
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label569
	load32 0 r2
Label___shivyc_label569:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label112
	; EQUALCMP
	load32 1 r1
	read -127 rbp r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label570
	load32 0 r1
Label___shivyc_label570:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label116
	; READREL
	read -124 rbp r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label571
	load32 0 r2
Label___shivyc_label571:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label116
	; JUMP
	jump Label___shivyc_label117
	; LABEL
Label___shivyc_label116:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label117:
	; SET
	load32 0 r5
	; JUMPNOTZERO
	or r0 r3 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label114
	; EQUALCMP
	load32 1 r1
	read -127 rbp r12
	load32 2 r13
	bne r13 r12 2
	jump Label___shivyc_label572
	load32 0 r1
Label___shivyc_label572:
	; SET
	load32 1 r4
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label120
	; READREL
	read -124 rbp r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label573
	load32 0 r2
Label___shivyc_label573:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label120
	; JUMP
	jump Label___shivyc_label121
	; LABEL
Label___shivyc_label120:
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label121:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label118
	; READREL
	read -123 rbp r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label574
	load32 0 r2
Label___shivyc_label574:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label118
	; JUMP
	jump Label___shivyc_label119
	; LABEL
Label___shivyc_label118:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label119:
	; JUMPNOTZERO
	or r0 r3 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label114
	; JUMP
	jump Label___shivyc_label115
	; LABEL
Label___shivyc_label114:
	; SET
	load32 1 r5
	; LABEL
Label___shivyc_label115:
	; JUMPZERO
	or r0 r5 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label113
	; RETURN
	load32 65 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label113:
	; SET
	read -127 rbp r1
	; SETREL
	load32 0 r13
	load32 1 r7
	mult r7 r1 r7
	sub r7 124 r7
	add r7 rbp r7
	write 0 r7 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 47 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendString r1
	; ADDRREL
	sub rbp 124 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	write -127 rbp r12
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label575
	load32 0 r2
Label___shivyc_label575:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label123
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 65 r13
	beq r13 r12 2
	jump Label___shivyc_label576
	load32 0 r2
Label___shivyc_label576:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label123
	; JUMP
	jump Label___shivyc_label124
	; LABEL
Label___shivyc_label123:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label124:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label122
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label122:
	; JUMP
	jump Label___shivyc_label125
	; LABEL
Label___shivyc_label112:
	; SET
	read -126 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -125 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r2
	; SET
	read -127 rbp r1
	; SETREL
	or r0 r2 r13
	load32 1 r7
	mult r7 r1 r7
	sub r7 124 r7
	add r7 rbp r7
	write 0 r7 r13
	; SET
	read -127 rbp r1
	; ADD
	read -127 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -127 rbp r1
	; GREATERCMP
	load32 1 r1
	read -127 rbp r12
	load32 13 r13
	bge r13 r12 2
	jump Label___shivyc_label577
	load32 0 r1
Label___shivyc_label577:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label126
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label126:
	; LABEL
Label___shivyc_label125:
	; SET
	read -126 rbp r1
	; ADD
	read -126 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -126 rbp r1
	; JUMP
	jump Label___shivyc_label110
	; LABEL
Label___shivyc_label111:
	; SET
	read -127 rbp r1
	; SETREL
	load32 0 r13
	load32 1 r7
	mult r7 r1 r7
	sub r7 124 r7
	add r7 rbp r7
	write 0 r7 r13
	; EQUALCMP
	load32 1 r1
	read -127 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label578
	load32 0 r1
Label___shivyc_label578:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label127
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label127:
	; EQUALCMP
	load32 1 r1
	read -127 rbp r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label579
	load32 0 r1
Label___shivyc_label579:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label131
	; READREL
	read -124 rbp r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label580
	load32 0 r2
Label___shivyc_label580:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label131
	; JUMP
	jump Label___shivyc_label132
	; LABEL
Label___shivyc_label131:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label132:
	; SET
	load32 0 r5
	; JUMPNOTZERO
	or r0 r3 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label129
	; EQUALCMP
	load32 1 r1
	read -127 rbp r12
	load32 2 r13
	bne r13 r12 2
	jump Label___shivyc_label581
	load32 0 r1
Label___shivyc_label581:
	; SET
	load32 1 r4
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label135
	; READREL
	read -124 rbp r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label582
	load32 0 r2
Label___shivyc_label582:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label135
	; JUMP
	jump Label___shivyc_label136
	; LABEL
Label___shivyc_label135:
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label136:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label133
	; READREL
	read -123 rbp r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label583
	load32 0 r2
Label___shivyc_label583:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label133
	; JUMP
	jump Label___shivyc_label134
	; LABEL
Label___shivyc_label133:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label134:
	; JUMPNOTZERO
	or r0 r3 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label129
	; JUMP
	jump Label___shivyc_label130
	; LABEL
Label___shivyc_label129:
	; SET
	load32 1 r5
	; LABEL
Label___shivyc_label130:
	; JUMPZERO
	or r0 r5 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label128
	; RETURN
	load32 65 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label128:
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 47 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendString r1
	; ADDRREL
	sub rbp 124 r5 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_parseFATstring:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 140 rsp
	; LOADARG
	write -137 rbp r5
	; LOADARG
	write -138 rbp r4
	; LOADARG
	write -139 rbp r3
	; LOADARG
	write -140 rbp r2
	; GREATERCMP
	load32 1 r1
	read -138 rbp r12
	load32 8 r13
	bge r13 r12 2
	jump Label___shivyc_label584
	load32 0 r1
Label___shivyc_label584:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label137
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1445 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label137:
	; SET
	load32 0 r1
	; SET
	read -138 rbp r2
	; SETREL
	load32 0 r13
	load32 1 r7
	mult r7 r2 r7
	sub r7 136 r7
	add r7 rbp r7
	write 0 r7 r13
	; SET
	load32 0 r4
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label138:
	; LESSCMP
	load32 1 r2
	or r0 r3 r12
	read -138 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label585
	load32 0 r2
Label___shivyc_label585:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label140
	; SET
	load32 1 r2
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label142
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label142:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label141
	; SUBTR
	read -138 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -137 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r5
	read 0 r5 r2
	; SET
	; EQUALCMP
	load32 1 r5
	or r0 r2 r12
	load32 32 r13
	bne r13 r12 2
	jump Label___shivyc_label586
	load32 0 r5
Label___shivyc_label586:
	; JUMPZERO
	or r0 r5 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label143
	; SUBTR
	read -138 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; SETREL
	load32 0 r13
	load32 1 r7
	mult r7 r2 r7
	sub r7 136 r7
	add r7 rbp r7
	write 0 r7 r13
	; JUMP
	jump Label___shivyc_label144
	; LABEL
Label___shivyc_label143:
	; SET
	load32 1 r4
	; SUBTR
	read -138 rbp r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	; SUBTR
	read -138 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -137 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r2
	read 0 r2 r5
	; SUBTR
	read -138 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; SETREL
	or r0 r5 r13
	load32 1 r7
	mult r7 r2 r7
	sub r7 136 r7
	add r7 rbp r7
	write 0 r7 r13
	; LABEL
Label___shivyc_label144:
	; JUMP
	jump Label___shivyc_label145
	; LABEL
Label___shivyc_label141:
	; SUBTR
	read -138 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -137 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r2
	read 0 r2 r5
	; SUBTR
	read -138 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SUBTR
	or r0 r2 r12
	or r0 r3 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	; SETREL
	or r0 r5 r13
	load32 1 r7
	mult r7 r2 r7
	sub r7 136 r7
	add r7 rbp r7
	write 0 r7 r13
	; LABEL
Label___shivyc_label145:
	; LABEL
Label___shivyc_label139:
	; SET
	or r0 r3 r2
	; ADD
	or r0 r3 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	or r0 r2 r3
	; JUMP
	jump Label___shivyc_label138
	; LABEL
Label___shivyc_label140:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label146:
	; SET
	or r0 r3 r2
	; READREL
	load32 1 r7
	mult r7 r2 r7
	sub r7 136 r7
	add r7 rbp r7
	read 0 r7 r12
	or r0 r12 r2
	; SET
	; NOTEQUALCMP
	load32 1 r4
	or r0 r2 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label587
	load32 0 r4
Label___shivyc_label587:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label147
	; SET
	or r0 r3 r2
	; READREL
	load32 1 r7
	mult r7 r2 r7
	sub r7 136 r7
	add r7 rbp r7
	read 0 r7 r12
	or r0 r12 r4
	; READAT
	read -140 rbp r5
	read 0 r5 r2
	; SET
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -139 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	write 0 r2 r4
	; READAT
	read -140 rbp r4
	read 0 r4 r2
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	read -140 rbp r4
	write 0 r4 r2
	; ADD
	or r0 r3 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; JUMP
	jump Label___shivyc_label146
	; LABEL
Label___shivyc_label147:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_parseFATdata:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 154 rsp
	; LOADARG
	; LOADARG
	write -151 rbp r4
	; LOADARG
	write -152 rbp r3
	; LOADARG
	write -153 rbp r2
	; NOTEQUALCMP
	load32 1 r1
	or r0 r5 r12
	load32 32 r13
	beq r13 r12 2
	jump Label___shivyc_label588
	load32 0 r1
Label___shivyc_label588:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label148
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1446 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label148:
	; ADDROF
	addr2reg Label_memcmp r1
	; ADDROF
	addr2reg Label___strlit1447 r4
	; SET
	; CALL
	read -151 rbp r5
	load32 11 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label149
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label149:
	; ADDROF
	addr2reg Label_memcmp r1
	; ADDROF
	addr2reg Label___strlit1448 r4
	; SET
	; CALL
	read -151 rbp r5
	load32 11 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label150
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label150:
	; ADDROF
	addr2reg Label_FS_parseFATstring r1
	; CALL
	read -151 rbp r5
	load32 8 r4
	read -152 rbp r3
	read -153 rbp r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -154 rbp r1
	; MULT
	load32 8 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 32 r13
	beq r13 r12 2
	jump Label___shivyc_label589
	load32 0 r2
Label___shivyc_label589:
	; SET
	load32 0 r4
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label154
	; MULT
	load32 9 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 32 r13
	beq r13 r12 2
	jump Label___shivyc_label590
	load32 0 r2
Label___shivyc_label590:
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label154
	; JUMP
	jump Label___shivyc_label155
	; LABEL
Label___shivyc_label154:
	; SET
	load32 1 r4
	; LABEL
Label___shivyc_label155:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r4 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label152
	; MULT
	load32 10 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 32 r13
	beq r13 r12 2
	jump Label___shivyc_label591
	load32 0 r2
Label___shivyc_label591:
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label152
	; JUMP
	jump Label___shivyc_label153
	; LABEL
Label___shivyc_label152:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label153:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label151
	; READAT
	read -153 rbp r2
	read 0 r2 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -152 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 46 r12
	write 0 r1 r12
	; READAT
	read -153 rbp r2
	read 0 r2 r1
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	read -153 rbp r2
	write 0 r2 r1
	; ADDROF
	addr2reg Label_FS_parseFATstring r1
	; MULT
	load32 8 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -151 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	load32 3 r4
	read -152 rbp r3
	read -153 rbp r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; ADD
	read -154 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -154 rbp r1
	; LABEL
Label___shivyc_label151:
	; LABEL
Label___shivyc_label156:
	; LESSCMP
	load32 1 r1
	read -154 rbp r12
	load32 16 r13
	bge r12 r13 2
	jump Label___shivyc_label592
	load32 0 r1
Label___shivyc_label592:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label157
	; READAT
	read -153 rbp r2
	read 0 r2 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -152 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 32 r12
	write 0 r1 r12
	; READAT
	read -153 rbp r2
	read 0 r2 r1
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	read -153 rbp r2
	write 0 r2 r1
	; ADD
	read -154 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -154 rbp r1
	; JUMP
	jump Label___shivyc_label156
	; LABEL
Label___shivyc_label157:
	; SET
	load32 0 r5
	; MULT
	load32 28 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r5
	; MULT
	load32 29 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; LBITSHIFT
	or r0 r1 r12
	load32 8 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r5
	; MULT
	load32 30 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; LBITSHIFT
	or r0 r1 r12
	load32 16 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r5
	; MULT
	load32 31 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -151 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; LBITSHIFT
	or r0 r1 r12
	load32 24 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r5
	; ADDROF
	addr2reg Label_itoa r1
	; ADDRREL
	sub rbp 150 r4 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label158:
	; SET
	or r0 r2 r1
	; READREL
	load32 1 r7
	mult r7 r1 r7
	sub r7 150 r7
	add r7 rbp r7
	read 0 r7 r12
	or r0 r12 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label593
	load32 0 r3
Label___shivyc_label593:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label159
	; SET
	or r0 r2 r1
	; READREL
	load32 1 r7
	mult r7 r1 r7
	sub r7 150 r7
	add r7 rbp r7
	read 0 r7 r12
	or r0 r12 r3
	; READAT
	read -153 rbp r4
	read 0 r4 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -152 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	write 0 r1 r3
	; READAT
	read -153 rbp r3
	read 0 r3 r1
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	read -153 rbp r3
	write 0 r3 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label158
	; LABEL
Label___shivyc_label159:
	; READAT
	read -153 rbp r2
	read 0 r2 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -152 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 10 r12
	write 0 r1 r12
	; READAT
	read -153 rbp r2
	read 0 r2 r1
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	read -153 rbp r2
	write 0 r2 r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_readFATdata:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 190 rsp
	; LOADARG
	write -187 rbp r5
	; LOADARG
	write -188 rbp r4
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 39 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -189 rbp r1
	; SET
	load32 0 r12
	write -190 rbp r12
	; LABEL
Label___shivyc_label160:
	; LESSCMP
	load32 1 r1
	read -190 rbp r12
	read -189 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label594
	load32 0 r1
Label___shivyc_label594:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label162
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -190 rbp r2
	; SET
	; SETREL
	or r0 r1 r13
	load32 1 r7
	mult r7 r2 r7
	sub r7 186 r7
	add r7 rbp r7
	write 0 r7 r13
	; LABEL
Label___shivyc_label161:
	; SET
	read -190 rbp r1
	; ADD
	read -190 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -190 rbp r1
	; JUMP
	jump Label___shivyc_label160
	; LABEL
Label___shivyc_label162:
	; ADDROF
	addr2reg Label_FS_parseFATdata r1
	; ADDRREL
	sub rbp 186 r4 ;lea
	; CALL
	read -189 rbp r5
	read -187 rbp r3
	read -188 rbp r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_listDir:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 193 rsp
	; LOADARG
	; LOADARG
	write -192 rbp r4
	; SET
	load32 0 r12
	write -191 rbp r12
	; ADDROF
	read -191 rbp r1
	; SET
	write -193 rbp r1
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	or r0 r1 r2
	; NOTEQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label595
	load32 0 r1
Label___shivyc_label595:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label163
	; RETURN
	or r0 r2 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label163:
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	or r0 r1 r2
	; SET
	; NOTEQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label596
	load32 0 r1
Label___shivyc_label596:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label165
	; NOTEQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 65 r13
	beq r13 r12 2
	jump Label___shivyc_label597
	load32 0 r1
Label___shivyc_label597:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label165
	; JUMP
	jump Label___shivyc_label166
	; LABEL
Label___shivyc_label165:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label166:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label164
	; RETURN
	or r0 r2 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label164:
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; ADDROF
	addr2reg Label___strlit1449 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	or r0 r1 r2
	; SET
	; NOTEQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 29 r13
	beq r13 r12 2
	jump Label___shivyc_label598
	load32 0 r1
Label___shivyc_label598:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label167
	; RETURN
	or r0 r2 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label167:
	; SETAT
	read -193 rbp r1
	load32 0 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label168:
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 29 r13
	bne r13 r12 2
	jump Label___shivyc_label599
	load32 0 r1
Label___shivyc_label599:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label169
	; ADDROF
	addr2reg Label_FS_readFATdata r1
	; CALL
	read -192 rbp r5
	read -193 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiTransfer r1
	; CALL
	load32 51 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	or r0 r1 r2
	; SET
	; JUMP
	jump Label___shivyc_label168
	; LABEL
Label___shivyc_label169:
	; READAT
	read -193 rbp r2
	read 0 r2 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -192 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; READAT
	read -193 rbp r2
	read 0 r2 r1
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	read -193 rbp r2
	write 0 r2 r1
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_changeDir:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 195 rsp
	; LOADARG
	write -194 rbp r5
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -194 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label600
	load32 0 r2
Label___shivyc_label600:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label171
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -194 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label601
	load32 0 r2
Label___shivyc_label601:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label171
	; JUMP
	jump Label___shivyc_label172
	; LABEL
Label___shivyc_label171:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label172:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label170
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; ADDROF
	addr2reg Label___strlit1450 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label170:
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -194 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -195 rbp r1
	; NOTEQUALCMP
	load32 1 r1
	read -195 rbp r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label602
	load32 0 r1
Label___shivyc_label602:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label173
	; RETURN
	read -195 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label173:
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -195 rbp r1
	; EQUALCMP
	load32 1 r1
	read -195 rbp r12
	load32 65 r13
	bne r13 r12 2
	jump Label___shivyc_label603
	load32 0 r1
Label___shivyc_label603:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label174
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label174:
	; EQUALCMP
	load32 1 r1
	read -195 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label604
	load32 0 r1
Label___shivyc_label604:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label175
	; ADDROF
	addr2reg Label_FS_close r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 180 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label176
	; LABEL
Label___shivyc_label175:
	; RETURN
	read -195 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label176:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_goUpDirectory:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; SET
	load32 1048576 r2
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; EQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label605
	load32 0 r3
Label___shivyc_label605:
	; SET
	load32 1 r4
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label178
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; EQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label606
	load32 0 r3
Label___shivyc_label606:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label178
	; JUMP
	jump Label___shivyc_label179
	; LABEL
Label___shivyc_label178:
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label179:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label177
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label177:
	; SET
	load32 0 r4
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label180:
	; SET
	or r0 r4 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r5
	read 0 r5 r1
	; SET
	; NOTEQUALCMP
	load32 1 r5
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label607
	load32 0 r5
Label___shivyc_label607:
	; JUMPZERO
	or r0 r5 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label181
	; SET
	or r0 r4 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r5
	read 0 r5 r1
	; SET
	; EQUALCMP
	load32 1 r5
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label608
	load32 0 r5
Label___shivyc_label608:
	; JUMPZERO
	or r0 r5 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label182
	; SET
	or r0 r4 r3
	; LABEL
Label___shivyc_label182:
	; ADD
	or r0 r4 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r4
	; SET
	; JUMP
	jump Label___shivyc_label180
	; LABEL
Label___shivyc_label181:
	; SET
	; MULT
	or r0 r3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r3
	; ADD
	or r0 r2 r12
	or r0 r3 r13
	add r12 r13 r12
	or r0 r12 r3
	; SETAT
	or r0 r3 r1
	load32 0 r12
	write 0 r1 r12
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 47 r13
	beq r13 r12 2
	jump Label___shivyc_label609
	load32 0 r3
Label___shivyc_label609:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label183
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 47 r12
	write 0 r1 r12
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label183:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_setRelativePath:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 197 rsp
	; LOADARG
	; SET
	load32 1048576 r12
	write -196 rbp r12
	; SET
	load32 0 r12
	write -197 rbp r12
	; LABEL
Label___shivyc_label184:
	; SET
	read -197 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -196 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label610
	load32 0 r2
Label___shivyc_label610:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label185
	; ADD
	read -197 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -197 rbp r1
	; JUMP
	jump Label___shivyc_label184
	; LABEL
Label___shivyc_label185:
	; EQUALCMP
	load32 1 r1
	read -197 rbp r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label611
	load32 0 r1
Label___shivyc_label611:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label186
	; SUBTR
	read -197 rbp r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	write -197 rbp r1
	; JUMP
	jump Label___shivyc_label187
	; LABEL
Label___shivyc_label186:
	; SET
	read -197 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -196 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 47 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label187:
	; ADD
	read -197 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label188:
	; SET
	or r0 r3 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r4
	read 0 r4 r1
	; SET
	; NOTEQUALCMP
	load32 1 r4
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label612
	load32 0 r4
Label___shivyc_label612:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label189
	; SET
	or r0 r3 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r4
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -196 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	write 0 r1 r4
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; ADD
	or r0 r3 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; JUMP
	jump Label___shivyc_label188
	; LABEL
Label___shivyc_label189:
	; SET
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -196 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; ADDROF
	addr2reg Label_FS_changeDir r1
	; CALL
	read -196 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label613
	load32 0 r2
Label___shivyc_label613:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label190
	; EQUALCMP
	load32 1 r2
	read -197 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label614
	load32 0 r2
Label___shivyc_label614:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label191
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -196 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	load32 47 r12
	write 0 r2 r12
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -196 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	load32 0 r12
	write 0 r2 r12
	; JUMP
	jump Label___shivyc_label192
	; LABEL
Label___shivyc_label191:
	; SET
	read -197 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -196 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	load32 0 r12
	write 0 r2 r12
	; LABEL
Label___shivyc_label192:
	; LABEL
Label___shivyc_label190:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_changePath:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 199 rsp
	; LOADARG
	write -198 rbp r5
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -198 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label615
	load32 0 r2
Label___shivyc_label615:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label193
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label193:
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -198 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label616
	load32 0 r2
Label___shivyc_label616:
	; SET
	load32 1 r4
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label197
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -198 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 46 r13
	bne r13 r12 2
	jump Label___shivyc_label617
	load32 0 r2
Label___shivyc_label617:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label197
	; JUMP
	jump Label___shivyc_label198
	; LABEL
Label___shivyc_label197:
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label198:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label195
	; MULT
	load32 2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -198 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label618
	load32 0 r2
Label___shivyc_label618:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label195
	; JUMP
	jump Label___shivyc_label196
	; LABEL
Label___shivyc_label195:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label196:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label194
	; ADDROF
	addr2reg Label_FS_goUpDirectory r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 20 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label199
	; LABEL
Label___shivyc_label194:
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -198 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label619
	load32 0 r2
Label___shivyc_label619:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label200
	; ADDROF
	addr2reg Label_FS_changeDir r1
	; CALL
	read -198 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -199 rbp r1
	; EQUALCMP
	load32 1 r1
	read -199 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label620
	load32 0 r1
Label___shivyc_label620:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label201
	; SET
	load32 1048576 r5
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -198 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label201:
	; RETURN
	read -199 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label202
	; LABEL
Label___shivyc_label200:
	; ADDROF
	addr2reg Label_FS_setRelativePath r1
	; CALL
	read -198 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label202:
	; LABEL
Label___shivyc_label199:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_FS_getFullPath:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 201 rsp
	; LOADARG
	write -200 rbp r5
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -200 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label621
	load32 0 r2
Label___shivyc_label621:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label203
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label203:
	; SET
	load32 1048576 r12
	write -201 rbp r12
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -200 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 47 r13
	bne r13 r12 2
	jump Label___shivyc_label622
	load32 0 r2
Label___shivyc_label622:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label204
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -201 rbp r5
	read -200 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label205
	; LABEL
Label___shivyc_label204:
	; ADDROF
	addr2reg Label_strcat r1
	; ADDROF
	addr2reg Label___strlit1451 r4
	; SET
	; CALL
	read -201 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_strcat r1
	; CALL
	read -201 rbp r5
	read -200 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label205:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_HID_FifoWrite:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 202 rsp
	; LOADARG
	write -202 rbp r5
	; EQUALCMP
	load32 1 r1
	read -202 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label623
	load32 0 r1
Label___shivyc_label623:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label206
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label206:
	; EQUALCMP
	load32 1 r1
	addr2reg Label_hidbufSize r7
	read 0 r7 r12
	load32 32 r13
	bne r13 r12 2
	jump Label___shivyc_label624
	load32 0 r1
Label___shivyc_label624:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label207
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1452 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label207:
	; ADDROF
	addr2reg Label_hidfifo r2
	; SET
	; SET
	; SET
	addr2reg Label_hidwriteIdx r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	read -202 rbp r12
	write 0 r1 r12
	; ADD
	addr2reg Label_hidbufSize r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_hidbufSize r7
	write 0 r7 r1
	; ADD
	addr2reg Label_hidwriteIdx r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_hidwriteIdx r7
	write 0 r7 r1
	; EQUALCMP
	load32 1 r1
	addr2reg Label_hidwriteIdx r7
	read 0 r7 r12
	load32 32 r13
	bne r13 r12 2
	jump Label___shivyc_label625
	load32 0 r1
Label___shivyc_label625:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label208
	; SET
	load32 0 r12
	addr2reg Label_hidwriteIdx r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label208:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_HID_FifoAvailable:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; EQUALCMP
	load32 1 r1
	addr2reg Label_hidbufSize r7
	read 0 r7 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label626
	load32 0 r1
Label___shivyc_label626:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label209
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label210
	; LABEL
Label___shivyc_label209:
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label210:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_HID_FifoRead:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; EQUALCMP
	load32 1 r1
	addr2reg Label_hidbufSize r7
	read 0 r7 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label627
	load32 0 r1
Label___shivyc_label627:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label211
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1453 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label211:
	; ADDROF
	addr2reg Label_hidfifo r1
	; SET
	; SET
	; ADDROF
	addr2reg Label_hidfifo r2
	; SET
	; SET
	addr2reg Label_hidreadIdx r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r2
	read 0 r2 r1
	; SET
	; SUBTR
	addr2reg Label_hidbufSize r7
	read 0 r7 r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r2
	; SET
	addr2reg Label_hidbufSize r7
	write 0 r7 r2
	; ADD
	addr2reg Label_hidreadIdx r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	addr2reg Label_hidreadIdx r7
	write 0 r7 r2
	; EQUALCMP
	load32 1 r2
	addr2reg Label_hidreadIdx r7
	read 0 r7 r12
	load32 32 r13
	bne r13 r12 2
	jump Label___shivyc_label628
	load32 0 r2
Label___shivyc_label628:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label212
	; SET
	load32 0 r12
	addr2reg Label_hidreadIdx r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label212:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_PS2SCANCODE_NORMAL:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 9 96 0
	.dw 0 0 0 0 0 113 49 0 0 0 122 115 97 119 50 0
	.dw 0 99 120 100 101 52 51 0 0 32 118 102 116 114 53 0
	.dw 0 110 98 104 103 121 54 0 0 44 109 106 117 55 56 0
	.dw 0 44 107 105 111 48 57 0 0 46 47 108 59 112 45 0
	.dw 0 0 39 0 91 61 0 0 0 0 10 93 0 92 0 0
	.dw 0 60 0 0 0 0 8 0 0 49 0 52 55 0 0 0
	.dw 48 46 50 53 54 56 27 0 0 43 51 45 42 57 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_PS2SCANCODE_SHIFTED:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 9 126 0
	.dw 0 0 0 0 0 81 33 0 0 0 90 83 65 87 64 0
	.dw 0 67 88 68 69 36 35 0 0 32 86 70 84 82 37 0
	.dw 0 78 66 72 71 89 94 0 0 59 77 74 85 38 42 0
	.dw 0 60 75 73 79 41 40 0 0 62 63 76 58 80 95 0
	.dw 0 0 34 0 123 43 0 0 0 0 10 125 0 124 0 0
	.dw 0 62 0 0 0 0 8 0 0 49 0 52 55 0 0 0
	.dw 48 46 50 53 54 56 27 0 0 43 51 45 42 57 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_PS2SCANCODE_EXTENDED:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 47 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 10 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 263 0 256 261 0 0 0
	.dw 260 127 259 0 257 258 0 0 0 0 264 0 0 262 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_PS2_HandleInterrupt:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 203 rsp
	; SET
	load32 12592960 r12
	write -203 rbp r12
	; JUMPZERO
	addr2reg Label_ps2released r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label213
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 89 r13
	bne r13 r12 2
	jump Label___shivyc_label629
	load32 0 r1
Label___shivyc_label629:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label215
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 18 r13
	bne r13 r12 2
	jump Label___shivyc_label630
	load32 0 r1
Label___shivyc_label630:
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label215
	; JUMP
	jump Label___shivyc_label216
	; LABEL
Label___shivyc_label215:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label216:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label214
	; SET
	load32 0 r12
	addr2reg Label_ps2shifted r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label214:
	; JUMPZERO
	addr2reg Label_ps2extended r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label217
	; SET
	load32 0 r12
	addr2reg Label_ps2extended r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label217:
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label631
	load32 0 r1
Label___shivyc_label631:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label218
	; SET
	load32 0 r12
	addr2reg Label_ps2controlled r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label218:
	; SET
	load32 0 r12
	addr2reg Label_ps2released r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label219
	; LABEL
Label___shivyc_label213:
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 224 r13
	bne r13 r12 2
	jump Label___shivyc_label632
	load32 0 r1
Label___shivyc_label632:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label220
	; SET
	load32 1 r12
	addr2reg Label_ps2extended r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label221
	; LABEL
Label___shivyc_label220:
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 89 r13
	bne r13 r12 2
	jump Label___shivyc_label633
	load32 0 r1
Label___shivyc_label633:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label223
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 18 r13
	bne r13 r12 2
	jump Label___shivyc_label634
	load32 0 r1
Label___shivyc_label634:
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label223
	; JUMP
	jump Label___shivyc_label224
	; LABEL
Label___shivyc_label223:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label224:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label222
	; SET
	load32 1 r12
	addr2reg Label_ps2shifted r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label225
	; LABEL
Label___shivyc_label222:
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 240 r13
	bne r13 r12 2
	jump Label___shivyc_label635
	load32 0 r1
Label___shivyc_label635:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label226
	; SET
	load32 1 r12
	addr2reg Label_ps2released r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label227
	; LABEL
Label___shivyc_label226:
	; READAT
	read -203 rbp r1
	read 0 r1 r2
	; EQUALCMP
	load32 1 r1
	or r0 r2 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label636
	load32 0 r1
Label___shivyc_label636:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label228
	; SET
	load32 1 r12
	addr2reg Label_ps2controlled r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label229
	; LABEL
Label___shivyc_label228:
	; JUMPZERO
	addr2reg Label_ps2extended r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label230
	; ADDROF
	addr2reg Label_DATA_PS2SCANCODE_EXTENDED r2
	; SET
	; SET
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; ADDROF
	addr2reg Label_HID_FifoWrite r3
	; READAT
	read -203 rbp r4
	read 0 r4 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r1
	read 0 r1 r5
	; CALL
	or r0 r3 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label231
	; LABEL
Label___shivyc_label230:
	; JUMPZERO
	addr2reg Label_ps2shifted r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label232
	; ADDROF
	addr2reg Label_DATA_PS2SCANCODE_SHIFTED r2
	; SET
	; SET
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; ADDROF
	addr2reg Label_HID_FifoWrite r3
	; READAT
	read -203 rbp r4
	read 0 r4 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r1
	read 0 r1 r5
	; CALL
	or r0 r3 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label233
	; LABEL
Label___shivyc_label232:
	; ADDROF
	addr2reg Label_DATA_PS2SCANCODE_NORMAL r2
	; SET
	; SET
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; ADDROF
	addr2reg Label_HID_FifoWrite r3
	; READAT
	read -203 rbp r4
	read 0 r4 r1
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r1
	read 0 r1 r5
	; CALL
	or r0 r3 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label233:
	; LABEL
Label___shivyc_label231:
	; LABEL
Label___shivyc_label229:
	; LABEL
Label___shivyc_label227:
	; LABEL
Label___shivyc_label225:
	; LABEL
Label___shivyc_label221:
	; LABEL
Label___shivyc_label219:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_USBSCANCODE_NORMAL:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	.dw 0 0 0 0 97 98 99 100 101 102 103 104 105 106 107 108
	.dw 109 110 111 112 113 114 115 116 117 118 119 120 121 122 49 50
	.dw 51 52 53 54 55 56 57 48 10 27 8 9 32 45 61 91
	.dw 93 92 92 59 39 96 44 46 47 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 260 261 262 127 263 264 257
	.dw 256 259 258 0 47 42 45 43 10 49 50 51 52 53 54 55
	.dw 56 57 48 46 92 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_DATA_USBSCANCODE_SHIFTED:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	.dw 0 0 0 0 65 66 67 68 69 70 71 72 73 74 75 76
	.dw 77 78 79 80 81 82 83 84 85 86 87 88 89 90 33 64
	.dw 35 36 37 94 38 42 40 41 10 27 8 9 32 95 43 123
	.dw 125 124 124 58 34 126 60 62 63 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 260 261 262 127 263 264 257
	.dw 256 259 258 0 47 42 45 43 10 49 50 51 52 53 54 55
	.dw 56 57 48 46 124 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	.dw 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_spiBeginTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	push r1
	push r2
	load32 0xC0272F r2
	load 0 r1
	write 0 r2 r1
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_spiEndTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	push r1
	push r2
	load32 0xC0272F r2
	load 1 r1
	write 0 r2 r1
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_spiTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; LOADARG
	; ASMCODE
	load32 0xC0272E r1
	write 0 r1 r5
	read 0 r1 r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_WaitGetStatus:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 204 rsp
	; SET
	load32 1 r1
	; LABEL
Label___shivyc_label234:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label235
	; SET
	load32 12592944 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; JUMP
	jump Label___shivyc_label234
	; LABEL
Label___shivyc_label235:
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 34 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -204 rbp r1
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -204 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_noWaitGetStatus:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 205 rsp
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 34 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -205 rbp r1
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -205 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_setUSBmode:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 207 rsp
	; LOADARG
	write -206 rbp r5
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 21 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	read -206 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label236:
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	load32 20000 r13
	bge r12 r13 2
	jump Label___shivyc_label637
	load32 0 r1
Label___shivyc_label637:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label238
	; LABEL
Label___shivyc_label237:
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label236
	; LABEL
Label___shivyc_label238:
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -207 rbp r1
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -207 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_setUSBspeed:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 208 rsp
	; LOADARG
	write -208 rbp r5
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 4 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	read -208 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_init:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 60 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 5 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 100 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_setUSBmode r1
	; CALL
	load32 5 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 12592955 r1
	; SETAT
	or r0 r1 r1
	load32 30 r12
	write 0 r1 r12
	; SET
	load32 12592956 r1
	; SETAT
	or r0 r1 r1
	load32 1 r12
	write 0 r1 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_connectDevice:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ADDROF
	addr2reg Label_USBkeyboard_setUSBmode r1
	; CALL
	load32 7 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_setUSBmode r1
	; CALL
	load32 6 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label239:
	; ADDROF
	addr2reg Label_USBkeyboard_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 21 r13
	beq r13 r12 2
	jump Label___shivyc_label638
	load32 0 r2
Label___shivyc_label638:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label240
	; JUMP
	jump Label___shivyc_label239
	; LABEL
Label___shivyc_label240:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_toggle_recv:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 28 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	addr2reg Label_USBkeyboard_endp_mode r7
	read 0 r7 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; XOR
	addr2reg Label_USBkeyboard_endp_mode r7
	read 0 r7 r12
	load32 64 r13
	xor r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_USBkeyboard_endp_mode r7
	write 0 r7 r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_issue_token:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 209 rsp
	; LOADARG
	write -209 rbp r5
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 79 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	read -209 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_receive_data:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 212 rsp
	; LOADARG
	write -210 rbp r5
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 40 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -211 rbp r1
	; NOTEQUALCMP
	load32 1 r1
	read -211 rbp r12
	load32 8 r13
	beq r13 r12 2
	jump Label___shivyc_label639
	load32 0 r1
Label___shivyc_label639:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label241
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label241:
	; SET
	load32 0 r12
	write -212 rbp r12
	; LABEL
Label___shivyc_label242:
	; LESSCMP
	load32 1 r1
	read -212 rbp r12
	read -211 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label640
	load32 0 r1
Label___shivyc_label640:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label244
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -212 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -210 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; SETAT
	or r0 r2 r2
	write 0 r2 r1
	; LABEL
Label___shivyc_label243:
	; SET
	read -212 rbp r1
	; ADD
	read -212 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -212 rbp r1
	; JUMP
	jump Label___shivyc_label242
	; LABEL
Label___shivyc_label244:
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_set_addr:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 213 rsp
	; LOADARG
	write -213 rbp r5
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 69 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	read -213 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 19 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	read -213 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_set_config:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 214 rsp
	; LOADARG
	write -214 rbp r5
	; ADDROF
	addr2reg Label_USBkeyboard_spiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	load32 73 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiTransfer r1
	; CALL
	read -214 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_spiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_WaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_sendToFifo:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 215 rsp
	; LOADARG
	write -215 rbp r5
	; LOADARG
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; AND
	or r0 r1 r12
	load32 2 r13
	and r12 r13 r12
	or r0 r12 r1
	; SET
	load32 0 r2
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label246
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; AND
	or r0 r1 r12
	load32 32 r13
	and r12 r13 r12
	or r0 r12 r1
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label246
	; JUMP
	jump Label___shivyc_label247
	; LABEL
Label___shivyc_label246:
	; SET
	load32 1 r2
	; LABEL
Label___shivyc_label247:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label245
	; ADDROF
	addr2reg Label_DATA_USBSCANCODE_SHIFTED r2
	; SET
	; SET
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; ADDROF
	addr2reg Label_HID_FifoWrite r3
	; SET
	read -215 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r1
	read 0 r1 r5
	; CALL
	or r0 r3 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label248
	; LABEL
Label___shivyc_label245:
	; ADDROF
	addr2reg Label_DATA_USBSCANCODE_NORMAL r2
	; SET
	; SET
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; ADDROF
	addr2reg Label_HID_FifoWrite r3
	; SET
	read -215 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r1
	read 0 r1 r5
	; CALL
	or r0 r3 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label248:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_parse_buffer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 218 rsp
	; LOADARG
	write -216 rbp r5
	; LOADARG
	write -217 rbp r4
	; SET
	load32 2 r12
	write -218 rbp r12
	; LABEL
Label___shivyc_label249:
	; LESSCMP
	load32 1 r1
	read -218 rbp r12
	load32 8 r13
	bge r12 r13 2
	jump Label___shivyc_label641
	load32 0 r1
Label___shivyc_label641:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label251
	; SET
	read -218 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -216 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label642
	load32 0 r2
Label___shivyc_label642:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label253
	; SET
	read -218 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -217 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label643
	load32 0 r2
Label___shivyc_label643:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label253
	; JUMP
	jump Label___shivyc_label254
	; LABEL
Label___shivyc_label253:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label254:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label252
	; SET
	read -218 rbp r12
	addr2reg Label_USBkeyboard_holdButton r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_USBkeyboard_sendToFifo r2
	; SET
	read -218 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -216 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r5
	; CALL
	read -216 rbp r4
	or r0 r2 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label252:
	; LABEL
Label___shivyc_label250:
	; SET
	read -218 rbp r1
	; ADD
	read -218 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -218 rbp r1
	; JUMP
	jump Label___shivyc_label249
	; LABEL
Label___shivyc_label251:
	; ADDROF
	addr2reg Label_memcpy r1
	; CALL
	read -217 rbp r5
	read -216 rbp r4
	load32 8 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_poll:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 219 rsp
	; ADDROF
	addr2reg Label_USBkeyboard_noWaitGetStatus r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -219 rbp r1
	; EQUALCMP
	load32 1 r1
	read -219 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label644
	load32 0 r1
Label___shivyc_label644:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label255
	; ADDROF
	addr2reg Label_USBkeyboard_receive_data r1
	; ADDROF
	addr2reg Label_USBkeyboard_buffer r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_parse_buffer r1
	; ADDROF
	addr2reg Label_USBkeyboard_buffer r5
	; SET
	; ADDROF
	addr2reg Label_USBkeyboard_buffer_prev r4
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_toggle_recv r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_issue_token r1
	; CALL
	load32 25 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label256
	; LABEL
Label___shivyc_label255:
	; EQUALCMP
	load32 1 r1
	read -219 rbp r12
	load32 21 r13
	bne r13 r12 2
	jump Label___shivyc_label645
	load32 0 r1
Label___shivyc_label645:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label257
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label258:
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	load32 100000 r13
	bge r12 r13 2
	jump Label___shivyc_label646
	load32 0 r1
Label___shivyc_label646:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label260
	; LABEL
Label___shivyc_label259:
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label258
	; LABEL
Label___shivyc_label260:
	; ADDROF
	addr2reg Label_USBkeyboard_connectDevice r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_setUSBspeed r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_set_addr r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_set_config r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_toggle_recv r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_USBkeyboard_issue_token r1
	; CALL
	load32 25 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label257:
	; LABEL
Label___shivyc_label256:
	; ADDROF
	addr2reg Label_USBkeyboard_buffer r4
	; SET
	; SET
	; NOTEQUALCMP
	load32 1 r1
	addr2reg Label_USBkeyboard_holdButton r7
	read 0 r7 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label647
	load32 0 r1
Label___shivyc_label647:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label261
	; SET
	addr2reg Label_USBkeyboard_holdButton r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label648
	load32 0 r2
Label___shivyc_label648:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label262
	; LESSCMP
	load32 1 r1
	addr2reg Label_USBkeyboard_holdCounter r7
	read 0 r7 r12
	load32 20 r13
	bge r12 r13 2
	jump Label___shivyc_label649
	load32 0 r1
Label___shivyc_label649:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label263
	; SET
	addr2reg Label_USBkeyboard_holdCounter r7
	read 0 r7 r1
	; ADD
	addr2reg Label_USBkeyboard_holdCounter r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_USBkeyboard_holdCounter r7
	write 0 r7 r1
	; LABEL
Label___shivyc_label263:
	; JUMP
	jump Label___shivyc_label264
	; LABEL
Label___shivyc_label262:
	; SET
	load32 0 r12
	addr2reg Label_USBkeyboard_holdButton r7
	write 0 r7 r12
	; SET
	load32 0 r12
	addr2reg Label_USBkeyboard_holdCounter r7
	write 0 r7 r12
	; LABEL
Label___shivyc_label264:
	; GREATEROREQCMP
	load32 1 r1
	addr2reg Label_USBkeyboard_holdCounter r7
	read 0 r7 r12
	load32 20 r13
	bgt r13 r12 2
	jump Label___shivyc_label650
	load32 0 r1
Label___shivyc_label650:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label265
	; ADDROF
	addr2reg Label_USBkeyboard_sendToFifo r2
	; SET
	addr2reg Label_USBkeyboard_holdButton r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r5
	; CALL
	or r0 r2 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label265:
	; LABEL
Label___shivyc_label261:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_USBkeyboard_HandleInterrupt:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ADDROF
	addr2reg Label_USBkeyboard_poll r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 12592955 r1
	; SETAT
	or r0 r1 r1
	load32 30 r12
	write 0 r1 r12
	; SET
	load32 12592956 r1
	; SETAT
	or r0 r1 r1
	load32 1 r12
	write 0 r1 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_WizSpiBeginTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	push r1
	push r2
	load32 0xC02732 r2
	load 0 r1
	write 0 r2 r1
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_WizSpiEndTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; ASMCODE
	push r1
	push r2
	load32 0xC02732 r2
	load 1 r1
	write 0 r2 r1
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_WizSpiTransfer:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; LOADARG
	; ASMCODE
	load32 0xC02731 r1
	write 0 r1 r5
	read 0 r1 r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizWrite:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 224 rsp
	; LOADARG
	write -222 rbp r5
	; LOADARG
	write -223 rbp r4
	; LOADARG
	write -220 rbp r3
	; LOADARG
	write -221 rbp r2
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -222 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -222 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -223 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	write -224 rbp r12
	; LABEL
Label___shivyc_label266:
	; LESSCMP
	load32 1 r1
	read -224 rbp r12
	read -221 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label651
	load32 0 r1
Label___shivyc_label651:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label268
	; ADDROF
	addr2reg Label_WizSpiTransfer r2
	; SET
	read -224 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -220 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r5
	; SET
	; CALL
	or r0 r2 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label267:
	; SET
	read -224 rbp r1
	; ADD
	read -224 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -224 rbp r1
	; JUMP
	jump Label___shivyc_label266
	; LABEL
Label___shivyc_label268:
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizWriteSingle:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 227 rsp
	; LOADARG
	write -225 rbp r5
	; LOADARG
	write -226 rbp r4
	; LOADARG
	write -227 rbp r3
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -225 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -225 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -226 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -227 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -227 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizWriteDouble:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 230 rsp
	; LOADARG
	write -228 rbp r5
	; LOADARG
	write -229 rbp r4
	; LOADARG
	write -230 rbp r3
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -228 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -228 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -229 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -230 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -230 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizRead:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 235 rsp
	; LOADARG
	write -233 rbp r5
	; LOADARG
	write -234 rbp r4
	; LOADARG
	write -231 rbp r3
	; LOADARG
	write -232 rbp r2
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -233 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -233 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -234 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	write -235 rbp r12
	; LABEL
Label___shivyc_label269:
	; LESSCMP
	load32 1 r1
	read -235 rbp r12
	read -232 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label652
	load32 0 r1
Label___shivyc_label652:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label271
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	read -235 rbp r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -231 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; SETAT
	or r0 r2 r2
	write 0 r2 r1
	; LABEL
Label___shivyc_label270:
	; SET
	read -235 rbp r1
	; ADD
	read -235 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -235 rbp r1
	; JUMP
	jump Label___shivyc_label269
	; LABEL
Label___shivyc_label271:
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizReadSingle:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 238 rsp
	; LOADARG
	write -236 rbp r5
	; LOADARG
	write -237 rbp r4
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -236 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -236 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -237 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -238 rbp r1
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -238 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizReadDouble:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 241 rsp
	; LOADARG
	write -239 rbp r5
	; LOADARG
	write -240 rbp r4
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -239 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -239 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -240 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	or r0 r1 r12
	load32 8 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; SET
	write -241 rbp r1
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -241 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -241 rbp r1
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -241 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizCmd:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 243 rsp
	; LOADARG
	write -242 rbp r5
	; LOADARG
	write -243 rbp r4
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; LBITSHIFT
	read -242 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r5
	; ADD
	load32 12 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -243 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label272:
	; ADDROF
	addr2reg Label_wizReadSingle r1
	; CALL
	load32 1 r5
	load32 8 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label273
	; JUMP
	jump Label___shivyc_label272
	; LABEL
Label___shivyc_label273:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizSetSockReg8:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 246 rsp
	; LOADARG
	write -244 rbp r5
	; LOADARG
	write -245 rbp r4
	; LOADARG
	write -246 rbp r3
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -245 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; LBITSHIFT
	read -244 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r5
	; ADD
	load32 12 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -246 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizGetSockReg8:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 249 rsp
	; LOADARG
	write -247 rbp r5
	; LOADARG
	write -248 rbp r4
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -248 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -248 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	read -247 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r5
	; ADD
	load32 8 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -249 rbp r1
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -249 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizSetSockReg16:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 252 rsp
	; LOADARG
	write -250 rbp r5
	; LOADARG
	write -251 rbp r4
	; LOADARG
	write -252 rbp r3
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -251 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; LBITSHIFT
	read -250 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r5
	; ADD
	load32 12 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -252 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -252 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizGetSockReg16:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 255 rsp
	; LOADARG
	write -253 rbp r5
	; LOADARG
	write -254 rbp r4
	; ADDROF
	addr2reg Label_WizSpiBeginTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RBITSHIFT
	read -254 rbp r12
	load32 8 r13
	shiftr r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	read -254 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	read -253 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r5
	; ADD
	load32 8 r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; SET
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LBITSHIFT
	or r0 r1 r12
	load32 8 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; SET
	write -255 rbp r1
	; ADDROF
	addr2reg Label_WizSpiTransfer r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -255 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -255 rbp r1
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	read -255 rbp r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wiz_Init:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 259 rsp
	; LOADARG
	write -256 rbp r5
	; LOADARG
	write -257 rbp r4
	; LOADARG
	write -258 rbp r3
	; LOADARG
	write -259 rbp r2
	; ADDROF
	addr2reg Label_WizSpiEndTransfer r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 100 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizWrite r1
	; CALL
	load32 15 r5
	load32 4 r4
	read -256 rbp r3
	load32 4 r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizWrite r1
	; CALL
	load32 1 r5
	load32 4 r4
	read -257 rbp r3
	load32 4 r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizWrite r1
	; CALL
	load32 9 r5
	load32 4 r4
	read -258 rbp r3
	load32 6 r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizWrite r1
	; CALL
	load32 5 r5
	load32 4 r4
	read -259 rbp r3
	load32 4 r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizInitSocketTCP:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 261 rsp
	; LOADARG
	write -260 rbp r5
	; LOADARG
	write -261 rbp r4
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -260 rbp r5
	load32 16 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizSetSockReg8 r1
	; CALL
	read -260 rbp r5
	load32 2 r4
	load32 255 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizSetSockReg8 r1
	; CALL
	read -260 rbp r5
	load32 0 r4
	load32 1 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizSetSockReg16 r1
	; CALL
	read -260 rbp r5
	load32 4 r4
	read -261 rbp r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -260 rbp r5
	load32 1 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -260 rbp r5
	load32 2 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 10 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizWriteDataFromMemory:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 269 rsp
	; LOADARG
	write -262 rbp r5
	; LOADARG
	write -263 rbp r4
	; LOADARG
	write -264 rbp r3
	; LESSOREQCMP
	load32 1 r1
	read -264 rbp r12
	load32 0 r13
	bgt r12 r13 2
	jump Label___shivyc_label653
	load32 0 r1
Label___shivyc_label653:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label274
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label274:
	; SET
	load32 0 r12
	write -265 rbp r12
	; LABEL
Label___shivyc_label275:
	; NOTEQUALCMP
	load32 1 r1
	read -265 rbp r12
	read -264 rbp r13
	beq r13 r12 2
	jump Label___shivyc_label654
	load32 0 r1
Label___shivyc_label654:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label276
	; ADDROF
	addr2reg Label_wizGetSockReg8 r1
	; CALL
	read -262 rbp r5
	load32 3 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label655
	load32 0 r2
Label___shivyc_label655:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label277
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label277:
	; SUBTR
	read -264 rbp r12
	read -265 rbp r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	write -266 rbp r1
	; GREATERCMP
	load32 1 r1
	read -266 rbp r12
	load32 2048 r13
	bge r13 r12 2
	jump Label___shivyc_label656
	load32 0 r1
Label___shivyc_label656:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label278
	; SET
	load32 2048 r12
	write -266 rbp r12
	; LABEL
Label___shivyc_label278:
	; ADDROF
	addr2reg Label_wizGetSockReg16 r1
	; CALL
	read -262 rbp r5
	load32 32 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -267 rbp r1
	; SET
	load32 0 r12
	write -268 rbp r12
	; LABEL
Label___shivyc_label279:
	; LESSCMP
	load32 1 r1
	read -267 rbp r12
	read -266 rbp r13
	bge r12 r13 2
	jump Label___shivyc_label657
	load32 0 r1
Label___shivyc_label657:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label280
	; SET
	read -268 rbp r1
	; ADD
	read -268 rbp r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -268 rbp r1
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 1 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizGetSockReg16 r1
	; CALL
	read -262 rbp r5
	load32 32 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -267 rbp r1
	; GREATERCMP
	load32 1 r1
	read -268 rbp r12
	load32 1000 r13
	bge r13 r12 2
	jump Label___shivyc_label658
	load32 0 r1
Label___shivyc_label658:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label281
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -262 rbp r5
	load32 8 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label281:
	; JUMP
	jump Label___shivyc_label279
	; LABEL
Label___shivyc_label280:
	; ADDROF
	addr2reg Label_wizGetSockReg16 r1
	; CALL
	read -262 rbp r5
	load32 36 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -269 rbp r1
	; ADDROF
	addr2reg Label_wizWrite r1
	; LBITSHIFT
	read -262 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r4
	; ADD
	load32 20 r12
	or r0 r4 r13
	add r12 r13 r12
	or r0 r12 r4
	; SET
	read -265 rbp r3
	; MULT
	or r0 r3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r3
	; ADD
	read -263 rbp r12
	or r0 r3 r13
	add r12 r13 r12
	or r0 r12 r3
	; CALL
	read -269 rbp r5
	read -266 rbp r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -269 rbp r12
	read -266 rbp r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; ADDROF
	addr2reg Label_wizSetSockReg16 r1
	; CALL
	read -262 rbp r5
	load32 36 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -262 rbp r5
	load32 32 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -265 rbp r12
	read -266 rbp r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -265 rbp r1
	; JUMP
	jump Label___shivyc_label275
	; LABEL
Label___shivyc_label276:
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizReadRecvData:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 273 rsp
	; LOADARG
	write -270 rbp r5
	; LOADARG
	write -271 rbp r4
	; LOADARG
	write -272 rbp r3
	; EQUALCMP
	load32 1 r1
	read -272 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label659
	load32 0 r1
Label___shivyc_label659:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label282
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label282:
	; GREATERCMP
	load32 1 r1
	read -272 rbp r12
	load32 2048 r13
	bge r13 r12 2
	jump Label___shivyc_label660
	load32 0 r1
Label___shivyc_label660:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label283
	; SET
	load32 2048 r12
	write -272 rbp r12
	; LABEL
Label___shivyc_label283:
	; ADDROF
	addr2reg Label_wizGetSockReg16 r1
	; CALL
	read -270 rbp r5
	load32 40 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -273 rbp r1
	; ADDROF
	addr2reg Label_wizRead r1
	; LBITSHIFT
	read -270 rbp r12
	load32 5 r13
	shiftl r12 r13 r12
	or r0 r12 r4
	; ADD
	load32 24 r12
	or r0 r4 r13
	add r12 r13 r12
	or r0 r12 r4
	; CALL
	read -273 rbp r5
	read -271 rbp r3
	read -272 rbp r2
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -273 rbp r12
	read -272 rbp r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; ADDROF
	addr2reg Label_wizSetSockReg16 r1
	; CALL
	read -270 rbp r5
	load32 40 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -270 rbp r5
	load32 64 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_wizFlush:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 275 rsp
	; LOADARG
	write -274 rbp r5
	; LOADARG
	write -275 rbp r4
	; GREATERCMP
	load32 1 r1
	read -275 rbp r12
	load32 0 r13
	bge r13 r12 2
	jump Label___shivyc_label661
	load32 0 r1
Label___shivyc_label661:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label284
	; ADDROF
	addr2reg Label_wizGetSockReg16 r1
	; CALL
	read -274 rbp r5
	load32 40 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; ADD
	or r0 r1 r12
	read -275 rbp r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r3
	; ADDROF
	addr2reg Label_wizSetSockReg16 r1
	; CALL
	read -274 rbp r5
	load32 40 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -274 rbp r5
	load32 64 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label284:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_NETLOADER_frameCompare:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; LOADARG
	; LOADARG
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label285:
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label662
	load32 0 r3
Label___shivyc_label662:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label286
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r4 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r3
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r8
	read 0 r8 r1
	; SET
	; SET
	; NOTEQUALCMP
	load32 1 r8
	or r0 r3 r12
	or r0 r1 r13
	beq r13 r12 2
	jump Label___shivyc_label663
	load32 0 r8
Label___shivyc_label663:
	; JUMPZERO
	or r0 r8 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label287
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label287:
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label285
	; LABEL
Label___shivyc_label286:
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_NETLOADER_appendBufferToRunAddress:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 191 rsp
	; LOADARG
	; LOADARG
	or r0 r4 r8
	; SET
	load32 4194304 r2
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label288:
	; LESSCMP
	load32 1 r1
	or r0 r4 r12
	or r0 r8 r13
	bge r12 r13 2
	jump Label___shivyc_label664
	load32 0 r1
Label___shivyc_label664:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label290
	; SET
	or r0 r4 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r5 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; SET
	; LBITSHIFT
	or r0 r1 r12
	addr2reg Label_NETLOADER_currentByteShift r7
	read 0 r7 r13
	shiftl r12 r13 r12
	or r0 r12 r1
	; SET
	; SET
	addr2reg Label_NETLOADER_wordPosition r7
	read 0 r7 r3
	; MULT
	or r0 r3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r3
	; ADD
	or r0 r2 r12
	or r0 r3 r13
	add r12 r13 r12
	or r0 r12 r3
	; READAT
	or r0 r3 r9
	read 0 r9 r3
	; SET
	; SET
	; ADD
	or r0 r3 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	addr2reg Label_NETLOADER_wordPosition r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	; SETAT
	or r0 r1 r1
	write 0 r1 r3
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_currentByteShift r7
	read 0 r7 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label665
	load32 0 r1
Label___shivyc_label665:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label291
	; SET
	load32 24 r12
	addr2reg Label_NETLOADER_currentByteShift r7
	write 0 r7 r12
	; ADD
	addr2reg Label_NETLOADER_wordPosition r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_NETLOADER_wordPosition r7
	write 0 r7 r1
	; SET
	addr2reg Label_NETLOADER_wordPosition r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; JUMP
	jump Label___shivyc_label292
	; LABEL
Label___shivyc_label291:
	; SUBTR
	addr2reg Label_NETLOADER_currentByteShift r7
	read 0 r7 r12
	load32 8 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_NETLOADER_currentByteShift r7
	write 0 r7 r1
	; LABEL
Label___shivyc_label292:
	; LABEL
Label___shivyc_label289:
	; SET
	or r0 r4 r1
	; ADD
	or r0 r4 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	or r0 r1 r4
	; JUMP
	jump Label___shivyc_label288
	; LABEL
Label___shivyc_label290:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_NETLOADER_handleSession:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 280 rsp
	; LOADARG
	write -276 rbp r5
	; ADDROF
	addr2reg Label_wizGetSockReg16 r1
	; CALL
	read -276 rbp r5
	load32 38 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -277 rbp r1
	; EQUALCMP
	load32 1 r1
	read -277 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label666
	load32 0 r1
Label___shivyc_label666:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label293
	; ADDROF
	addr2reg Label_wizCmd r1
	; CALL
	read -276 rbp r5
	load32 8 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label293:
	; SET
	load32 2097152 r12
	write -278 rbp r12
	; ADDROF
	addr2reg Label_wizReadRecvData r1
	; CALL
	read -276 rbp r5
	read -278 rbp r4
	read -277 rbp r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	write -279 rbp r12
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_transferState r7
	read 0 r7 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label667
	load32 0 r1
Label___shivyc_label667:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label294
	; ADDROF
	addr2reg Label_NETLOADER_frameCompare r1
	; ADDROF
	addr2reg Label___strlit1454 r4
	; SET
	; CALL
	read -278 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label295
	; SET
	load32 1 r12
	addr2reg Label_NETLOADER_transferState r7
	write 0 r7 r12
	; SET
	load32 0 r12
	addr2reg Label_NETLOADER_wordPosition r7
	write 0 r7 r12
	; SET
	load32 24 r12
	addr2reg Label_NETLOADER_currentByteShift r7
	write 0 r7 r12
	; SET
	load32 4194304 r2
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; JUMP
	jump Label___shivyc_label296
	; LABEL
Label___shivyc_label295:
	; ADDROF
	addr2reg Label_NETLOADER_frameCompare r1
	; ADDROF
	addr2reg Label___strlit1455 r4
	; SET
	; CALL
	read -278 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label297
	; SET
	load32 4 r12
	addr2reg Label_NETLOADER_transferState r7
	write 0 r7 r12
	; SET
	load32 1 r12
	write -279 rbp r12
	; SET
	load32 1048576 r12
	write -280 rbp r12
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -280 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label668
	load32 0 r2
Label___shivyc_label668:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label298
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label669
	load32 0 r2
Label___shivyc_label669:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label300
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 65 r13
	bne r13 r12 2
	jump Label___shivyc_label670
	load32 0 r2
Label___shivyc_label670:
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label300
	; JUMP
	jump Label___shivyc_label301
	; LABEL
Label___shivyc_label300:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label301:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label299
	; ADDROF
	addr2reg Label_strlen r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -278 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LESSOREQCMP
	load32 1 r2
	or r0 r1 r12
	load32 12 r13
	bgt r12 r13 2
	jump Label___shivyc_label671
	load32 0 r2
Label___shivyc_label671:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label302
	; ADDROF
	addr2reg Label_strToUpper r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -278 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -278 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_createFile r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label672
	load32 0 r2
Label___shivyc_label672:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label303
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -280 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -278 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label673
	load32 0 r2
Label___shivyc_label673:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label304
	; ADDROF
	addr2reg Label_FS_setCursor r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label674
	load32 0 r2
Label___shivyc_label674:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label305
	; SET
	load32 0 r12
	write -279 rbp r12
	; LABEL
Label___shivyc_label305:
	; LABEL
Label___shivyc_label304:
	; LABEL
Label___shivyc_label303:
	; LABEL
Label___shivyc_label302:
	; LABEL
Label___shivyc_label299:
	; LABEL
Label___shivyc_label298:
	; JUMP
	jump Label___shivyc_label306
	; LABEL
Label___shivyc_label297:
	; SET
	load32 1 r12
	write -279 rbp r12
	; LABEL
Label___shivyc_label306:
	; LABEL
Label___shivyc_label296:
	; JUMP
	jump Label___shivyc_label307
	; LABEL
Label___shivyc_label294:
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_transferState r7
	read 0 r7 r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label675
	load32 0 r1
Label___shivyc_label675:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label308
	; ADDROF
	addr2reg Label_NETLOADER_frameCompare r1
	; ADDROF
	addr2reg Label___strlit1456 r4
	; SET
	; CALL
	read -278 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label309
	; ADDROF
	addr2reg Label_NETLOADER_appendBufferToRunAddress r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -278 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; SUBTR
	read -277 rbp r12
	load32 4 r13
	sub r12 r13 r12
	or r0 r12 r4
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label310
	; LABEL
Label___shivyc_label309:
	; ADDROF
	addr2reg Label_NETLOADER_frameCompare r1
	; ADDROF
	addr2reg Label___strlit1457 r4
	; SET
	; CALL
	read -278 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label311
	; SET
	load32 2 r12
	addr2reg Label_NETLOADER_transferState r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label312
	; LABEL
Label___shivyc_label311:
	; SET
	load32 1 r12
	write -279 rbp r12
	; LABEL
Label___shivyc_label312:
	; LABEL
Label___shivyc_label310:
	; JUMP
	jump Label___shivyc_label313
	; LABEL
Label___shivyc_label308:
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_transferState r7
	read 0 r7 r12
	load32 4 r13
	bne r13 r12 2
	jump Label___shivyc_label676
	load32 0 r1
Label___shivyc_label676:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label314
	; ADDROF
	addr2reg Label_NETLOADER_frameCompare r1
	; ADDROF
	addr2reg Label___strlit1458 r4
	; SET
	; CALL
	read -278 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label315
	; ADDROF
	addr2reg Label_FS_writeFile r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -278 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; SUBTR
	read -277 rbp r12
	load32 4 r13
	sub r12 r13 r12
	or r0 r12 r4
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label677
	load32 0 r2
Label___shivyc_label677:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label316
	; SET
	load32 1 r12
	write -279 rbp r12
	; LABEL
Label___shivyc_label316:
	; JUMP
	jump Label___shivyc_label317
	; LABEL
Label___shivyc_label315:
	; ADDROF
	addr2reg Label_NETLOADER_frameCompare r1
	; ADDROF
	addr2reg Label___strlit1459 r4
	; SET
	; CALL
	read -278 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label318
	; ADDROF
	addr2reg Label_FS_close r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	addr2reg Label_NETLOADER_transferState r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label319
	; LABEL
Label___shivyc_label318:
	; SET
	load32 1 r12
	write -279 rbp r12
	; LABEL
Label___shivyc_label319:
	; LABEL
Label___shivyc_label317:
	; JUMP
	jump Label___shivyc_label320
	; LABEL
Label___shivyc_label314:
	; SET
	load32 1 r12
	write -279 rbp r12
	; LABEL
Label___shivyc_label320:
	; LABEL
Label___shivyc_label313:
	; LABEL
Label___shivyc_label307:
	; NOTEQUALCMP
	load32 1 r1
	read -279 rbp r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label678
	load32 0 r1
Label___shivyc_label678:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label321
	; ADDROF
	addr2reg Label___strlit1460 r4
	; SET
	; SET
	; ADDROF
	addr2reg Label_wizWriteDataFromMemory r1
	; CALL
	read -276 rbp r5
	load32 5 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	addr2reg Label_NETLOADER_transferState r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label322
	; LABEL
Label___shivyc_label321:
	; ADDROF
	addr2reg Label___strlit1461 r4
	; SET
	; SET
	; ADDROF
	addr2reg Label_wizWriteDataFromMemory r1
	; CALL
	read -276 rbp r5
	load32 4 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label322:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_NETLOADER_init:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 299 rsp
	; LOADARG
	write -299 rbp r5
	; SETREL
	load32 192 r12
	write -284 rbp r12
	; SETREL
	load32 168 r12
	write -283 rbp r12
	; SETREL
	load32 0 r12
	write -282 rbp r12
	; SETREL
	load32 213 r12
	write -281 rbp r12
	; SETREL
	load32 192 r12
	write -288 rbp r12
	; SETREL
	load32 168 r12
	write -287 rbp r12
	; SETREL
	load32 0 r12
	write -286 rbp r12
	; SETREL
	load32 1 r12
	write -285 rbp r12
	; SETREL
	load32 222 r12
	write -294 rbp r12
	; SETREL
	load32 173 r12
	write -293 rbp r12
	; SETREL
	load32 190 r12
	write -292 rbp r12
	; SETREL
	load32 239 r12
	write -291 rbp r12
	; SETREL
	load32 36 r12
	write -290 rbp r12
	; SETREL
	load32 100 r12
	write -289 rbp r12
	; SETREL
	load32 255 r12
	write -298 rbp r12
	; SETREL
	load32 255 r12
	write -297 rbp r12
	; SETREL
	load32 255 r12
	write -296 rbp r12
	; SETREL
	load32 0 r12
	write -295 rbp r12
	; ADDROF
	addr2reg Label_wiz_Init r1
	; ADDRREL
	sub rbp 284 r5 ;lea
	; ADDRREL
	sub rbp 288 r4 ;lea
	; ADDRREL
	sub rbp 294 r3 ;lea
	; ADDRREL
	sub rbp 298 r2 ;lea
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_wizInitSocketTCP r1
	; CALL
	read -299 rbp r5
	load32 6969 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_NETLOADER_loop:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 301 rsp
	; LOADARG
	write -300 rbp r5
	; ADDROF
	addr2reg Label_wizGetSockReg8 r1
	; CALL
	read -300 rbp r5
	load32 3 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -301 rbp r1
	; EQUALCMP
	load32 1 r1
	read -301 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label679
	load32 0 r1
Label___shivyc_label679:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label323
	; ADDROF
	addr2reg Label_wizInitSocketTCP r1
	; CALL
	read -300 rbp r5
	load32 6969 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label324
	; LABEL
Label___shivyc_label323:
	; EQUALCMP
	load32 1 r1
	read -301 rbp r12
	load32 23 r13
	bne r13 r12 2
	jump Label___shivyc_label680
	load32 0 r1
Label___shivyc_label680:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label325
	; ADDROF
	addr2reg Label_NETLOADER_handleSession r1
	; CALL
	read -300 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 10 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label326
	; LABEL
Label___shivyc_label325:
	; EQUALCMP
	load32 1 r1
	read -301 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label681
	load32 0 r1
Label___shivyc_label681:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label330
	; EQUALCMP
	load32 1 r1
	read -301 rbp r12
	load32 21 r13
	bne r13 r12 2
	jump Label___shivyc_label682
	load32 0 r1
Label___shivyc_label682:
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label330
	; JUMP
	jump Label___shivyc_label331
	; LABEL
Label___shivyc_label330:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label331:
	; SET
	load32 0 r2
	; JUMPNOTZERO
	or r0 r3 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label328
	; EQUALCMP
	load32 1 r1
	read -301 rbp r12
	load32 22 r13
	bne r13 r12 2
	jump Label___shivyc_label683
	load32 0 r1
Label___shivyc_label683:
	; JUMPNOTZERO
	or r0 r1 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label328
	; JUMP
	jump Label___shivyc_label329
	; LABEL
Label___shivyc_label328:
	; SET
	load32 1 r2
	; LABEL
Label___shivyc_label329:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label327
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label332
	; LABEL
Label___shivyc_label327:
	; ADDROF
	addr2reg Label_wizInitSocketTCP r1
	; CALL
	read -300 rbp r5
	load32 6969 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label332:
	; LABEL
Label___shivyc_label326:
	; LABEL
Label___shivyc_label324:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_NETLOADER_checkDone:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 298 rsp
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_transferState r7
	read 0 r7 r12
	load32 2 r13
	bne r13 r12 2
	jump Label___shivyc_label684
	load32 0 r1
Label___shivyc_label684:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label333
	; SET
	load32 0 r12
	addr2reg Label_NETLOADER_transferState r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_BDOS_Backup r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 1 r12
	addr2reg Label_UserprogramRunning r7
	write 0 r7 r12
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push rbp
	push rsp
	savpc r1
	push r1
	jump 0x400000
	pop rsp
	pop rbp
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; SET
	load32 0 r12
	addr2reg Label_UserprogramRunning r7
	write 0 r7 r12
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label333:
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_print_prompt:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 298 rsp
	; SET
	load32 1048576 r5
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1462 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	addr2reg Label_GFX_cursor r7
	read 0 r7 r12
	addr2reg Label_SHELL_promptCursorPos r7
	write 0 r7 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_init:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 298 rsp
	; SET
	load32 1049088 r2
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; SET
	load32 0 r12
	addr2reg Label_SHELL_commandIdx r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_SHELL_print_prompt r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_commandCompare:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 298 rsp
	; LOADARG
	; LOADARG
	; SET
	load32 1 r1
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label334:
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r4 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r8
	read 0 r8 r2
	; SET
	; NOTEQUALCMP
	load32 1 r8
	or r0 r2 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label685
	load32 0 r8
Label___shivyc_label685:
	; JUMPZERO
	or r0 r8 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label335
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r4 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r2
	read 0 r2 r8
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r9
	read 0 r9 r2
	; SET
	; SET
	; NOTEQUALCMP
	load32 1 r9
	or r0 r8 r12
	or r0 r2 r13
	beq r13 r12 2
	jump Label___shivyc_label686
	load32 0 r9
Label___shivyc_label686:
	; JUMPZERO
	or r0 r9 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label336
	; SET
	load32 0 r1
	; LABEL
Label___shivyc_label336:
	; ADD
	or r0 r3 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; JUMP
	jump Label___shivyc_label334
	; LABEL
Label___shivyc_label335:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label337
	; SET
	load32 0 r1
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r4
	read 0 r4 r2
	; SET
	; EQUALCMP
	load32 1 r8
	or r0 r2 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label687
	load32 0 r8
Label___shivyc_label687:
	; SET
	load32 0 r4
	; JUMPNOTZERO
	or r0 r8 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label339
	; SET
	; MULT
	or r0 r3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r3
	; ADD
	or r0 r5 r12
	or r0 r3 r13
	add r12 r13 r12
	or r0 r12 r3
	; READAT
	or r0 r3 r3
	read 0 r3 r2
	; SET
	; EQUALCMP
	load32 1 r3
	or r0 r2 r12
	load32 32 r13
	bne r13 r12 2
	jump Label___shivyc_label688
	load32 0 r3
Label___shivyc_label688:
	; JUMPNOTZERO
	or r0 r3 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label339
	; JUMP
	jump Label___shivyc_label340
	; LABEL
Label___shivyc_label339:
	; SET
	load32 1 r4
	; LABEL
Label___shivyc_label340:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label338
	; SET
	load32 1 r1
	; LABEL
Label___shivyc_label338:
	; LABEL
Label___shivyc_label337:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_numberOfArguments:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 298 rsp
	; LOADARG
	; SET
	load32 0 r1
	; SET
	load32 0 r4
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label341:
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r8
	read 0 r8 r2
	; SET
	; NOTEQUALCMP
	load32 1 r8
	or r0 r2 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label689
	load32 0 r8
Label___shivyc_label689:
	; JUMPZERO
	or r0 r8 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label342
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r8
	read 0 r8 r2
	; SET
	; EQUALCMP
	load32 1 r8
	or r0 r2 r12
	load32 32 r13
	bne r13 r12 2
	jump Label___shivyc_label690
	load32 0 r8
Label___shivyc_label690:
	; JUMPZERO
	or r0 r8 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label343
	; SET
	load32 1 r4
	; JUMP
	jump Label___shivyc_label344
	; LABEL
Label___shivyc_label343:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label345
	; SET
	or r0 r3 r2
	; MULT
	or r0 r2 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	or r0 r5 r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; READAT
	or r0 r2 r4
	read 0 r4 r2
	; SET
	; NOTEQUALCMP
	load32 1 r4
	or r0 r2 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label691
	load32 0 r4
Label___shivyc_label691:
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label346
	; ADD
	or r0 r1 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	; LABEL
Label___shivyc_label346:
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label345:
	; LABEL
Label___shivyc_label344:
	; ADD
	or r0 r3 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r3
	; SET
	; JUMP
	jump Label___shivyc_label341
	; LABEL
Label___shivyc_label342:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_ldir:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 305 rsp
	; LOADARG
	write -304 rbp r5
	; SET
	load32 1048576 r12
	write -302 rbp r12
	; SET
	load32 1048832 r12
	write -303 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -303 rbp r5
	read -302 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_changePath r1
	; CALL
	read -304 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label692
	load32 0 r2
Label___shivyc_label692:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label347
	; SET
	load32 2097152 r12
	write -305 rbp r12
	; ADDROF
	addr2reg Label_FS_listDir r1
	; CALL
	read -302 rbp r5
	read -305 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label693
	load32 0 r2
Label___shivyc_label693:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label348
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; CALL
	read -305 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label348:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -302 rbp r5
	read -303 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label349
	; LABEL
Label___shivyc_label347:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1463 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label349:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_runFile:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 313 rsp
	; LOADARG
	write -312 rbp r5
	; LOADARG
	write -306 rbp r4
	; SET
	load32 1048576 r12
	write -307 rbp r12
	; SET
	load32 1048832 r12
	write -308 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -308 rbp r5
	read -307 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	read -306 rbp r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label350
	; ADDROF
	addr2reg Label_strcpy r1
	; ADDROF
	addr2reg Label___strlit1464 r4
	; SET
	; CALL
	read -307 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_strcat r1
	; CALL
	read -307 rbp r5
	read -312 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label351
	; LABEL
Label___shivyc_label350:
	; ADDROF
	addr2reg Label_FS_getFullPath r1
	; CALL
	read -312 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label351:
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -307 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label694
	load32 0 r2
Label___shivyc_label694:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label352
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label695
	load32 0 r2
Label___shivyc_label695:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label353
	; ADDROF
	addr2reg Label_FS_getFileSize r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -309 rbp r1
	; LESSOREQCMP
	load32 1 r1
	read -309 rbp r12
	load32 3145728 r13
	bgt r12 r13 2
	jump Label___shivyc_label696
	load32 0 r1
Label___shivyc_label696:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label354
	; ADDROF
	addr2reg Label_FS_setCursor r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label697
	load32 0 r2
Label___shivyc_label697:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label355
	; SET
	load32 4194304 r12
	write -310 rbp r12
	; SET
	load32 0 r12
	write -311 rbp r12
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1465 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label356:
	; NOTEQUALCMP
	load32 1 r1
	read -311 rbp r12
	read -309 rbp r13
	beq r13 r12 2
	jump Label___shivyc_label698
	load32 0 r1
Label___shivyc_label698:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label357
	; SUBTR
	read -309 rbp r12
	read -311 rbp r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	write -313 rbp r1
	; GREATERCMP
	load32 1 r1
	read -313 rbp r12
	load32 4096 r13
	bge r13 r12 2
	jump Label___shivyc_label699
	load32 0 r1
Label___shivyc_label699:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label358
	; SET
	load32 4096 r12
	write -313 rbp r12
	; LABEL
Label___shivyc_label358:
	; ADDROF
	addr2reg Label_FS_readFile r1
	; CALL
	read -310 rbp r5
	read -313 rbp r4
	load32 1 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label700
	load32 0 r2
Label___shivyc_label700:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label359
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1466 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label359:
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; CALL
	load32 46 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -311 rbp r12
	read -313 rbp r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -311 rbp r1
	; ADDROF
	addr2reg Label_MATH_div r1
	; CALL
	read -313 rbp r5
	load32 4 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -310 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -310 rbp r1
	; JUMP
	jump Label___shivyc_label356
	; LABEL
Label___shivyc_label357:
	; ADDROF
	addr2reg Label_FS_close r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1467 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_BDOS_Backup r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 1 r12
	addr2reg Label_UserprogramRunning r7
	write 0 r7 r12
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push rbp
	push rsp
	savpc r1
	push r1
	jump 0x400000
	pop rsp
	pop rbp
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; SET
	load32 0 r12
	addr2reg Label_UserprogramRunning r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_BDOS_Restore r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label360
	; LABEL
Label___shivyc_label355:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1468 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label360:
	; JUMP
	jump Label___shivyc_label361
	; LABEL
Label___shivyc_label354:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1469 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label361:
	; JUMP
	jump Label___shivyc_label362
	; LABEL
Label___shivyc_label353:
	; JUMPZERO
	read -306 rbp r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label363
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1470 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label364
	; LABEL
Label___shivyc_label363:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1471 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label364:
	; LABEL
Label___shivyc_label362:
	; JUMP
	jump Label___shivyc_label365
	; LABEL
Label___shivyc_label352:
	; JUMPZERO
	read -306 rbp r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label366
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1472 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label367
	; LABEL
Label___shivyc_label366:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1473 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label367:
	; LABEL
Label___shivyc_label365:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -307 rbp r5
	read -308 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_printFile:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 320 rsp
	; LOADARG
	write -319 rbp r5
	; SET
	load32 1048576 r12
	write -314 rbp r12
	; SET
	load32 1048832 r12
	write -315 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -315 rbp r5
	read -314 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_getFullPath r1
	; CALL
	read -319 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -314 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label701
	load32 0 r2
Label___shivyc_label701:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label368
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label702
	load32 0 r2
Label___shivyc_label702:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label369
	; ADDROF
	addr2reg Label_FS_getFileSize r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -316 rbp r1
	; ADDROF
	addr2reg Label_FS_setCursor r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label703
	load32 0 r2
Label___shivyc_label703:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label370
	; SET
	load32 2097152 r12
	write -317 rbp r12
	; SET
	load32 0 r12
	write -318 rbp r12
	; LABEL
Label___shivyc_label371:
	; NOTEQUALCMP
	load32 1 r1
	read -318 rbp r12
	read -316 rbp r13
	beq r13 r12 2
	jump Label___shivyc_label704
	load32 0 r1
Label___shivyc_label704:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label372
	; SUBTR
	read -316 rbp r12
	read -318 rbp r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	write -320 rbp r1
	; GREATERCMP
	load32 1 r1
	read -320 rbp r12
	load32 512 r13
	bge r13 r12 2
	jump Label___shivyc_label705
	load32 0 r1
Label___shivyc_label705:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label373
	; SET
	load32 512 r12
	write -320 rbp r12
	; LABEL
Label___shivyc_label373:
	; ADDROF
	addr2reg Label_FS_readFile r1
	; CALL
	read -317 rbp r5
	read -320 rbp r4
	load32 0 r3
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label706
	load32 0 r2
Label___shivyc_label706:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label374
	; ADDROF
	addr2reg Label_uprintln r1
	; ADDROF
	addr2reg Label___strlit1474 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label374:
	; SET
	read -320 rbp r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -317 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; CALL
	read -317 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADD
	read -318 rbp r12
	read -320 rbp r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	write -318 rbp r1
	; JUMP
	jump Label___shivyc_label371
	; LABEL
Label___shivyc_label372:
	; ADDROF
	addr2reg Label_FS_close r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; CALL
	load32 10 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label375
	; LABEL
Label___shivyc_label370:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1475 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label375:
	; JUMP
	jump Label___shivyc_label376
	; LABEL
Label___shivyc_label369:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1476 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label376:
	; JUMP
	jump Label___shivyc_label377
	; LABEL
Label___shivyc_label368:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1477 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label377:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -314 rbp r5
	read -315 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_remove:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 324 rsp
	; LOADARG
	write -323 rbp r5
	; SET
	load32 1048576 r12
	write -321 rbp r12
	; SET
	load32 1048832 r12
	write -322 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -322 rbp r5
	read -321 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_getFullPath r1
	; CALL
	read -323 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -321 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label707
	load32 0 r2
Label___shivyc_label707:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label378
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -324 rbp r1
	; EQUALCMP
	load32 1 r1
	read -324 rbp r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label708
	load32 0 r1
Label___shivyc_label708:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label379
	; ADDROF
	addr2reg Label_FS_delete r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label709
	load32 0 r2
Label___shivyc_label709:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label380
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1478 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label381
	; LABEL
Label___shivyc_label380:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1479 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label381:
	; JUMP
	jump Label___shivyc_label382
	; LABEL
Label___shivyc_label379:
	; EQUALCMP
	load32 1 r1
	read -324 rbp r12
	load32 65 r13
	bne r13 r12 2
	jump Label___shivyc_label710
	load32 0 r1
Label___shivyc_label710:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label383
	; ADDROF
	addr2reg Label_FS_delete r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label711
	load32 0 r2
Label___shivyc_label711:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label384
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1480 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label385
	; LABEL
Label___shivyc_label384:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1481 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label385:
	; JUMP
	jump Label___shivyc_label386
	; LABEL
Label___shivyc_label383:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1482 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label386:
	; LABEL
Label___shivyc_label382:
	; JUMP
	jump Label___shivyc_label387
	; LABEL
Label___shivyc_label378:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1483 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label387:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -321 rbp r5
	read -322 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_createFile:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 327 rsp
	; LOADARG
	write -325 rbp r5
	; SET
	load32 1048576 r12
	write -326 rbp r12
	; SET
	load32 1048832 r12
	write -327 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -327 rbp r5
	read -326 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -326 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label712
	load32 0 r2
Label___shivyc_label712:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label388
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label713
	load32 0 r2
Label___shivyc_label713:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label390
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 65 r13
	bne r13 r12 2
	jump Label___shivyc_label714
	load32 0 r2
Label___shivyc_label714:
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label390
	; JUMP
	jump Label___shivyc_label391
	; LABEL
Label___shivyc_label390:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label391:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label389
	; ADDROF
	addr2reg Label_strlen r1
	; CALL
	read -325 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LESSOREQCMP
	load32 1 r2
	or r0 r1 r12
	load32 12 r13
	bgt r12 r13 2
	jump Label___shivyc_label715
	load32 0 r2
Label___shivyc_label715:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label392
	; ADDROF
	addr2reg Label_strToUpper r1
	; CALL
	read -325 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; CALL
	read -325 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_createFile r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label716
	load32 0 r2
Label___shivyc_label716:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label393
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1484 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label394
	; LABEL
Label___shivyc_label393:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1485 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label394:
	; JUMP
	jump Label___shivyc_label395
	; LABEL
Label___shivyc_label392:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1486 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label395:
	; JUMP
	jump Label___shivyc_label396
	; LABEL
Label___shivyc_label389:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1487 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label396:
	; JUMP
	jump Label___shivyc_label397
	; LABEL
Label___shivyc_label388:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1488 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label397:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -326 rbp r5
	read -327 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_createDir:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 330 rsp
	; LOADARG
	write -328 rbp r5
	; SET
	load32 1048576 r12
	write -329 rbp r12
	; SET
	load32 1048832 r12
	write -330 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -330 rbp r5
	read -329 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -329 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label717
	load32 0 r2
Label___shivyc_label717:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label398
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label718
	load32 0 r2
Label___shivyc_label718:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label400
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 65 r13
	bne r13 r12 2
	jump Label___shivyc_label719
	load32 0 r2
Label___shivyc_label719:
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label400
	; JUMP
	jump Label___shivyc_label401
	; LABEL
Label___shivyc_label400:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label401:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label399
	; ADDROF
	addr2reg Label_strlen r1
	; CALL
	read -328 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LESSOREQCMP
	load32 1 r2
	or r0 r1 r12
	load32 8 r13
	bgt r12 r13 2
	jump Label___shivyc_label720
	load32 0 r2
Label___shivyc_label720:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label402
	; ADDROF
	addr2reg Label_strToUpper r1
	; CALL
	read -328 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendSinglePath r1
	; CALL
	read -328 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_createDir r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label721
	load32 0 r2
Label___shivyc_label721:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label403
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1489 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label404
	; LABEL
Label___shivyc_label403:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1490 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label404:
	; JUMP
	jump Label___shivyc_label405
	; LABEL
Label___shivyc_label402:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1491 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label405:
	; JUMP
	jump Label___shivyc_label406
	; LABEL
Label___shivyc_label399:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1492 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label406:
	; JUMP
	jump Label___shivyc_label407
	; LABEL
Label___shivyc_label398:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1493 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label407:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -329 rbp r5
	read -330 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_copy:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 332 rsp
	; LOADARG
	; LOADARG
	; SET
	load32 1048576 r12
	write -331 rbp r12
	; SET
	load32 1048832 r12
	write -332 rbp r12
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -332 rbp r5
	read -331 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_sendFullPath r1
	; CALL
	read -331 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label722
	load32 0 r2
Label___shivyc_label722:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label408
	; ADDROF
	addr2reg Label_FS_open r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	bne r13 r12 2
	jump Label___shivyc_label723
	load32 0 r2
Label___shivyc_label723:
	; SET
	load32 0 r3
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label410
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 65 r13
	bne r13 r12 2
	jump Label___shivyc_label724
	load32 0 r2
Label___shivyc_label724:
	; JUMPNOTZERO
	or r0 r2 r12
	sub r12 0 r12
	beq r0 r12 2
	jump Label___shivyc_label410
	; JUMP
	jump Label___shivyc_label411
	; LABEL
Label___shivyc_label410:
	; SET
	load32 1 r3
	; LABEL
Label___shivyc_label411:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label409
	; JUMP
	jump Label___shivyc_label412
	; LABEL
Label___shivyc_label409:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1494 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label412:
	; JUMP
	jump Label___shivyc_label413
	; LABEL
Label___shivyc_label408:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1495 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label413:
	; ADDROF
	addr2reg Label_strcpy r1
	; CALL
	read -331 rbp r5
	read -332 rbp r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_printHelp:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 298 rsp
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1496 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1497 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1498 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1499 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1500 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1501 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1502 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1503 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1504 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1505 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1506 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1507 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1508 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1509 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_parseCommand:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 351 rsp
	; LOADARG
	write -349 rbp r5
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1510 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label414
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 1 r13
	beq r13 r12 2
	jump Label___shivyc_label725
	load32 0 r2
Label___shivyc_label725:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label415
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1511 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label416
	; LABEL
Label___shivyc_label415:
	; ADDROF
	addr2reg Label_SHELL_runFile r1
	; MULT
	load32 4 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	load32 0 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label416:
	; JUMP
	jump Label___shivyc_label417
	; LABEL
Label___shivyc_label414:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1512 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label418
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -350 rbp r1
	; GREATERCMP
	load32 1 r1
	read -350 rbp r12
	load32 1 r13
	bge r13 r12 2
	jump Label___shivyc_label726
	load32 0 r1
Label___shivyc_label726:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label419
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1513 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label420
	; LABEL
Label___shivyc_label419:
	; EQUALCMP
	load32 1 r1
	read -350 rbp r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label727
	load32 0 r1
Label___shivyc_label727:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label421
	; ADDROF
	addr2reg Label_SHELL_ldir r1
	; MULT
	load32 3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label422
	; LABEL
Label___shivyc_label421:
	; ADDROF
	addr2reg Label_SHELL_ldir r1
	; ADDROF
	addr2reg Label___strlit1514 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label422:
	; LABEL
Label___shivyc_label420:
	; JUMP
	jump Label___shivyc_label423
	; LABEL
Label___shivyc_label418:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1515 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label424
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -351 rbp r1
	; GREATERCMP
	load32 1 r1
	read -351 rbp r12
	load32 1 r13
	bge r13 r12 2
	jump Label___shivyc_label728
	load32 0 r1
Label___shivyc_label728:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label425
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1516 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label426
	; LABEL
Label___shivyc_label425:
	; EQUALCMP
	load32 1 r1
	read -351 rbp r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label729
	load32 0 r1
Label___shivyc_label729:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label427
	; ADDROF
	addr2reg Label_FS_changePath r1
	; MULT
	load32 3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label730
	load32 0 r2
Label___shivyc_label730:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label428
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1517 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label428:
	; JUMP
	jump Label___shivyc_label429
	; LABEL
Label___shivyc_label427:
	; SET
	load32 1048576 r2
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 47 r12
	write 0 r1 r12
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label429:
	; LABEL
Label___shivyc_label426:
	; JUMP
	jump Label___shivyc_label430
	; LABEL
Label___shivyc_label424:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1518 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label431
	; ADDROF
	addr2reg Label_GFX_clearWindowtileTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearWindowpaletteTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	addr2reg Label_GFX_cursor r7
	write 0 r7 r12
	; JUMP
	jump Label___shivyc_label432
	; LABEL
Label___shivyc_label431:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1519 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label433
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 1 r13
	beq r13 r12 2
	jump Label___shivyc_label731
	load32 0 r2
Label___shivyc_label731:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label434
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1520 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label435
	; LABEL
Label___shivyc_label434:
	; ADDROF
	addr2reg Label_SHELL_printFile r1
	; MULT
	load32 6 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label435:
	; JUMP
	jump Label___shivyc_label436
	; LABEL
Label___shivyc_label433:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1521 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label437
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 1 r13
	beq r13 r12 2
	jump Label___shivyc_label732
	load32 0 r2
Label___shivyc_label732:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label438
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1522 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label439
	; LABEL
Label___shivyc_label438:
	; ADDROF
	addr2reg Label_SHELL_remove r1
	; MULT
	load32 3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label439:
	; JUMP
	jump Label___shivyc_label440
	; LABEL
Label___shivyc_label437:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1523 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label441
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 1 r13
	beq r13 r12 2
	jump Label___shivyc_label733
	load32 0 r2
Label___shivyc_label733:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label442
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1524 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label443
	; LABEL
Label___shivyc_label442:
	; ADDROF
	addr2reg Label_SHELL_createFile r1
	; MULT
	load32 7 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label443:
	; JUMP
	jump Label___shivyc_label444
	; LABEL
Label___shivyc_label441:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1525 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label445
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 1 r13
	beq r13 r12 2
	jump Label___shivyc_label734
	load32 0 r2
Label___shivyc_label734:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label446
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1526 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label447
	; LABEL
Label___shivyc_label446:
	; ADDROF
	addr2reg Label_SHELL_createDir r1
	; MULT
	load32 6 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label447:
	; JUMP
	jump Label___shivyc_label448
	; LABEL
Label___shivyc_label445:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1527 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label449
	; ADDROF
	addr2reg Label_SHELL_printHelp r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label450
	; LABEL
Label___shivyc_label449:
	; ADDROF
	addr2reg Label_SHELL_commandCompare r1
	; ADDROF
	addr2reg Label___strlit1528 r4
	; SET
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label451
	; ADDROF
	addr2reg Label_SHELL_numberOfArguments r1
	; CALL
	read -349 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 2 r13
	beq r13 r12 2
	jump Label___shivyc_label735
	load32 0 r2
Label___shivyc_label735:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label452
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1529 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label453
	; LABEL
Label___shivyc_label452:
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r4
	; ADD
	read -349 rbp r12
	or r0 r4 r13
	add r12 r13 r12
	or r0 r12 r4
	; SET
	; ADDROF
	addr2reg Label_SHELL_copy r1
	; MULT
	load32 3 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r5
	; ADD
	read -349 rbp r12
	or r0 r5 r13
	add r12 r13 r12
	or r0 r12 r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label453:
	; JUMP
	jump Label___shivyc_label454
	; LABEL
Label___shivyc_label451:
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -349 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	; EQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label736
	load32 0 r2
Label___shivyc_label736:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label455
	; JUMP
	jump Label___shivyc_label456
	; LABEL
Label___shivyc_label455:
	; SET
	load32 0 r2
	; SETREL
	load32 0 r12
	write -348 rbp r12
	; LABEL
Label___shivyc_label457:
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -349 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label737
	load32 0 r3
Label___shivyc_label737:
	; SET
	load32 1 r4
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label461
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -349 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r3
	read 0 r3 r1
	; SET
	; NOTEQUALCMP
	load32 1 r3
	or r0 r1 r12
	load32 32 r13
	beq r13 r12 2
	jump Label___shivyc_label738
	load32 0 r3
Label___shivyc_label738:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label461
	; JUMP
	jump Label___shivyc_label462
	; LABEL
Label___shivyc_label461:
	; SET
	load32 0 r4
	; LABEL
Label___shivyc_label462:
	; SET
	load32 1 r3
	; JUMPZERO
	or r0 r4 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label459
	; LESSCMP
	load32 1 r1
	or r0 r2 r12
	load32 16 r13
	bge r12 r13 2
	jump Label___shivyc_label739
	load32 0 r1
Label___shivyc_label739:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label459
	; JUMP
	jump Label___shivyc_label460
	; LABEL
Label___shivyc_label459:
	; SET
	load32 0 r3
	; LABEL
Label___shivyc_label460:
	; JUMPZERO
	or r0 r3 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label458
	; SET
	or r0 r2 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -349 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r3
	; SET
	or r0 r2 r1
	; SETREL
	or r0 r3 r13
	load32 1 r7
	mult r7 r1 r7
	sub r7 348 r7
	add r7 rbp r7
	write 0 r7 r13
	; SET
	or r0 r2 r1
	; ADD
	or r0 r2 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SET
	; JUMP
	jump Label___shivyc_label457
	; LABEL
Label___shivyc_label458:
	; SET
	; SETREL
	load32 0 r13
	load32 1 r7
	mult r7 r2 r7
	sub r7 348 r7
	add r7 rbp r7
	write 0 r7 r13
	; ADDROF
	addr2reg Label_SHELL_runFile r1
	; ADDRREL
	sub rbp 348 r5 ;lea
	; CALL
	load32 1 r4
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label456:
	; LABEL
Label___shivyc_label454:
	; LABEL
Label___shivyc_label450:
	; LABEL
Label___shivyc_label448:
	; LABEL
Label___shivyc_label444:
	; LABEL
Label___shivyc_label440:
	; LABEL
Label___shivyc_label436:
	; LABEL
Label___shivyc_label432:
	; LABEL
Label___shivyc_label430:
	; LABEL
Label___shivyc_label423:
	; LABEL
Label___shivyc_label417:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_SHELL_loop:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 353 rsp
	; ADDROF
	addr2reg Label_HID_FifoAvailable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label463
	; ADDROF
	addr2reg Label_HID_FifoRead r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -352 rbp r1
	; GREATERCMP
	load32 1 r1
	read -352 rbp r12
	load32 255 r13
	bge r13 r12 2
	jump Label___shivyc_label740
	load32 0 r1
Label___shivyc_label740:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label464
	; JUMP
	jump Label___shivyc_label465
	; LABEL
Label___shivyc_label464:
	; EQUALCMP
	load32 1 r1
	read -352 rbp r12
	load32 8 r13
	bne r13 r12 2
	jump Label___shivyc_label741
	load32 0 r1
Label___shivyc_label741:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label466
	; NOTEQUALCMP
	load32 1 r1
	addr2reg Label_SHELL_commandIdx r7
	read 0 r7 r12
	load32 0 r13
	beq r13 r12 2
	jump Label___shivyc_label742
	load32 0 r1
Label___shivyc_label742:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label467
	; SUBTR
	addr2reg Label_SHELL_commandIdx r7
	read 0 r7 r12
	load32 1 r13
	sub r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_SHELL_commandIdx r7
	write 0 r7 r1
	; SET
	load32 1049088 r2
	; SET
	addr2reg Label_SHELL_commandIdx r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label467:
	; GREATERCMP
	load32 1 r1
	addr2reg Label_GFX_cursor r7
	read 0 r7 r12
	addr2reg Label_SHELL_promptCursorPos r7
	read 0 r7 r13
	bge r13 r12 2
	jump Label___shivyc_label743
	load32 0 r1
Label___shivyc_label743:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label468
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; SET
	read -352 rbp r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label468:
	; JUMP
	jump Label___shivyc_label469
	; LABEL
Label___shivyc_label466:
	; EQUALCMP
	load32 1 r1
	read -352 rbp r12
	load32 9 r13
	bne r13 r12 2
	jump Label___shivyc_label744
	load32 0 r1
Label___shivyc_label744:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label470
	; JUMP
	jump Label___shivyc_label471
	; LABEL
Label___shivyc_label470:
	; EQUALCMP
	load32 1 r1
	read -352 rbp r12
	load32 27 r13
	bne r13 r12 2
	jump Label___shivyc_label745
	load32 0 r1
Label___shivyc_label745:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label472
	; JUMP
	jump Label___shivyc_label473
	; LABEL
Label___shivyc_label472:
	; EQUALCMP
	load32 1 r1
	read -352 rbp r12
	load32 10 r13
	bne r13 r12 2
	jump Label___shivyc_label746
	load32 0 r1
Label___shivyc_label746:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label474
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; SET
	read -352 rbp r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 1049088 r12
	write -353 rbp r12
	; ADDROF
	addr2reg Label_SHELL_parseCommand r1
	; CALL
	read -353 rbp r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -353 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; SET
	load32 0 r12
	addr2reg Label_SHELL_commandIdx r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_SHELL_print_prompt r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label475
	; LABEL
Label___shivyc_label474:
	; SET
	load32 1049088 r2
	; SET
	addr2reg Label_SHELL_commandIdx r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	read -352 rbp r3
	; SETAT
	or r0 r1 r1
	write 0 r1 r3
	; ADD
	addr2reg Label_SHELL_commandIdx r7
	read 0 r7 r12
	load32 1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SET
	addr2reg Label_SHELL_commandIdx r7
	write 0 r7 r1
	; SET
	addr2reg Label_SHELL_commandIdx r7
	read 0 r7 r1
	; MULT
	or r0 r1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; SET
	read -352 rbp r5
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label475:
	; LABEL
Label___shivyc_label473:
	; LABEL
Label___shivyc_label471:
	; LABEL
Label___shivyc_label469:
	; LABEL
Label___shivyc_label465:
	; LABEL
Label___shivyc_label463:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_BDOS_Init_FS:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; ADDROF
	addr2reg Label_FS_init r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 81 r13
	beq r13 r12 2
	jump Label___shivyc_label747
	load32 0 r2
Label___shivyc_label747:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label476
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1530 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label476:
	; ADDROF
	addr2reg Label_delay r1
	; CALL
	load32 10 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_FS_connectDrive r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; NOTEQUALCMP
	load32 1 r2
	or r0 r1 r12
	load32 20 r13
	beq r13 r12 2
	jump Label___shivyc_label748
	load32 0 r2
Label___shivyc_label748:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label477
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1531 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label477:
	; RETURN
	load32 1 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_BDOS_Reinit_VRAM:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; ADDROF
	addr2reg Label_GFX_initVram r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_copyPaletteTable r1
	; ADDROF
	addr2reg Label_DATA_PALETTE_DEFAULT r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_copyPatternTable r1
	; ADDROF
	addr2reg Label_DATA_ASCII_DEFAULT r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 0 r12
	addr2reg Label_GFX_cursor r7
	write 0 r7 r12
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_BDOS_Backup:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_BDOS_Restore:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; ADDROF
	addr2reg Label_GFX_copyPaletteTable r1
	; ADDROF
	addr2reg Label_DATA_PALETTE_DEFAULT r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_copyPatternTable r1
	; ADDROF
	addr2reg Label_DATA_ASCII_DEFAULT r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearBGtileTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearBGpaletteTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearWindowpaletteTable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_clearSprites r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_NETLOADER_init r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_main:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; SET
	load32 0 r12
	addr2reg Label_UserprogramRunning r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_BDOS_Reinit_VRAM r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1532 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_NETLOADER_init r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_BDOS_Init_FS r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 1 r2
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label479
	; SET
	load32 0 r2
	; LABEL
Label___shivyc_label479:
	; JUMPZERO
	or r0 r2 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label478
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; LABEL
Label___shivyc_label478:
	; ADDROF
	addr2reg Label_USBkeyboard_init r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_SHELL_init r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label480:
	; JUMPZERO
	load32 1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label481
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_transferState r7
	read 0 r7 r12
	load32 4 r13
	bne r13 r12 2
	jump Label___shivyc_label749
	load32 0 r1
Label___shivyc_label749:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label482
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1533 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label483:
	; EQUALCMP
	load32 1 r1
	addr2reg Label_NETLOADER_transferState r7
	read 0 r7 r12
	load32 4 r13
	bne r13 r12 2
	jump Label___shivyc_label750
	load32 0 r1
Label___shivyc_label750:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label484
	; ADDROF
	addr2reg Label_NETLOADER_loop r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r1
	; CALL
	load32 46 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label483
	; LABEL
Label___shivyc_label484:
	; ADDROF
	addr2reg Label_GFX_PrintConsole r1
	; ADDROF
	addr2reg Label___strlit1534 r5
	; SET
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	load32 1049088 r2
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	or r0 r2 r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r1
	load32 0 r12
	write 0 r1 r12
	; SET
	load32 0 r12
	addr2reg Label_SHELL_commandIdx r7
	write 0 r7 r12
	; ADDROF
	addr2reg Label_SHELL_print_prompt r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label482:
	; ADDROF
	addr2reg Label_SHELL_loop r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_NETLOADER_loop r1
	; CALL
	load32 0 r5
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_NETLOADER_checkDone r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label485
	; ADDROF
	addr2reg Label_BDOS_Restore r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; ADDROF
	addr2reg Label_SHELL_print_prompt r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label485:
	; JUMP
	jump Label___shivyc_label480
	; LABEL
Label___shivyc_label481:
	; RETURN
	load32 0 r1
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_syscall:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 355 rsp
	; SET
	load32 2097152 r12
	write -354 rbp r12
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -354 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r2
	read 0 r2 r1
	; SET
	write -355 rbp r1
	; EQUALCMP
	load32 1 r1
	read -355 rbp r12
	load32 1 r13
	bne r13 r12 2
	jump Label___shivyc_label751
	load32 0 r1
Label___shivyc_label751:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label486
	; ADDROF
	addr2reg Label_HID_FifoAvailable r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -354 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	write 0 r2 r1
	; JUMP
	jump Label___shivyc_label487
	; LABEL
Label___shivyc_label486:
	; EQUALCMP
	load32 1 r1
	read -355 rbp r12
	load32 2 r13
	bne r13 r12 2
	jump Label___shivyc_label752
	load32 0 r1
Label___shivyc_label752:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label488
	; ADDROF
	addr2reg Label_HID_FifoRead r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r2
	; ADD
	read -354 rbp r12
	or r0 r2 r13
	add r12 r13 r12
	or r0 r12 r2
	; SETAT
	or r0 r2 r2
	write 0 r2 r1
	; JUMP
	jump Label___shivyc_label489
	; LABEL
Label___shivyc_label488:
	; EQUALCMP
	load32 1 r1
	read -355 rbp r12
	load32 3 r13
	bne r13 r12 2
	jump Label___shivyc_label753
	load32 0 r1
Label___shivyc_label753:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label490
	; ADDROF
	addr2reg Label_GFX_PrintcConsole r2
	; MULT
	load32 1 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -354 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; READAT
	or r0 r1 r1
	read 0 r1 r5
	; SET
	; CALL
	or r0 r2 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -354 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; JUMP
	jump Label___shivyc_label491
	; LABEL
Label___shivyc_label490:
	; EQUALCMP
	load32 1 r1
	read -355 rbp r12
	load32 4 r13
	bne r13 r12 2
	jump Label___shivyc_label754
	load32 0 r1
Label___shivyc_label754:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label492
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -354 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 1049088 r12
	write 0 r1 r12
	; JUMP
	jump Label___shivyc_label493
	; LABEL
Label___shivyc_label492:
	; EQUALCMP
	load32 1 r1
	read -355 rbp r12
	load32 5 r13
	bne r13 r12 2
	jump Label___shivyc_label755
	load32 0 r1
Label___shivyc_label755:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label494
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -354 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 1048832 r12
	write 0 r1 r12
	; JUMP
	jump Label___shivyc_label495
	; LABEL
Label___shivyc_label494:
	; MULT
	load32 0 r12
	load32 1 r13
	mult r12 r13 r12
	or r0 r12 r1
	; ADD
	read -354 rbp r12
	or r0 r1 r13
	add r12 r13 r12
	or r0 r12 r1
	; SETAT
	or r0 r1 r1
	load32 0 r12
	write 0 r1 r12
	; LABEL
Label___shivyc_label495:
	; LABEL
Label___shivyc_label493:
	; LABEL
Label___shivyc_label491:
	; LABEL
Label___shivyc_label489:
	; LABEL
Label___shivyc_label487:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_int1:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; SET
	load32 1 r12
	addr2reg Label_timer1Value r7
	write 0 r7 r12
	; JUMPZERO
	addr2reg Label_UserprogramRunning r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label496
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push rbp
	push rsp
	load32 0x400001 r2
	savpc r1
	push r1
	jumpr 0 r2
	pop rsp
	pop rbp
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label497
	; LABEL
Label___shivyc_label496:
	; LABEL
Label___shivyc_label497:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_int2:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 356 rsp
	; ADDROF
	addr2reg Label_getIntID r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; SET
	write -356 rbp r1
	; EQUALCMP
	load32 1 r1
	read -356 rbp r12
	load32 2 r13
	bne r13 r12 2
	jump Label___shivyc_label756
	load32 0 r1
Label___shivyc_label756:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label498
	; ADDROF
	addr2reg Label_PS2_HandleInterrupt r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; JUMP
	jump Label___shivyc_label499
	; LABEL
Label___shivyc_label498:
	; EQUALCMP
	load32 1 r1
	read -356 rbp r12
	load32 0 r13
	bne r13 r12 2
	jump Label___shivyc_label757
	load32 0 r1
Label___shivyc_label757:
	; JUMPZERO
	or r0 r1 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label500
	; ADDROF
	addr2reg Label_USBkeyboard_HandleInterrupt r1
	; CALL
	or r0 r1 r13
	savpc r12
	sub rsp 1 rsp
	write 0 rsp r12
	jumpr 0 r13
	; LABEL
Label___shivyc_label500:
	; LABEL
Label___shivyc_label499:
	; JUMPZERO
	addr2reg Label_UserprogramRunning r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label501
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push rbp
	push rsp
	load32 0x400002 r2
	savpc r1
	push r1
	jumpr 0 r2
	pop rsp
	pop rbp
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label502
	; LABEL
Label___shivyc_label501:
	; LABEL
Label___shivyc_label502:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_int3:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; JUMPZERO
	addr2reg Label_UserprogramRunning r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label503
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push rbp
	push rsp
	load32 0x400003 r2
	savpc r1
	push r1
	jumpr 0 r2
	pop rsp
	pop rbp
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label504
	; LABEL
Label___shivyc_label503:
	; LABEL
Label___shivyc_label504:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
Label_int4:
	sub rsp 1 rsp
	write 0 rsp rbp
	or r0 rsp rbp
	sub rsp 348 rsp
	; JUMPZERO
	addr2reg Label_UserprogramRunning r7
	read 0 r7 r12
	sub r12 0 r12
	bne r0 r12 2
	jump Label___shivyc_label505
	; ASMCODE
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push rbp
	push rsp
	load32 0x400004 r2
	savpc r1
	push r1
	jumpr 0 r2
	pop rsp
	pop rbp
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
	; JUMP
	jump Label___shivyc_label506
	; LABEL
Label___shivyc_label505:
	; LABEL
Label___shivyc_label506:
	; RETURN
	or r0 rbp rsp
	read 0 rsp rbp
	add rsp 1 rsp
	read 0 rsp r12
	add rsp 1 rsp
	jumpr 4 r12
; END OF COMPILED C CODE

; Interrupt handlers
; Has some administration before jumping to Label_int[ID]
; To prevent interfering with other stacks, they have their own stack
; Also, all registers have to be backed up and restored to hardware stack
; A return function has to be put on the stack as wel that the C code interrupt handler
; will jump to when it is done


Int1:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push rbp
    push rsp

    load32 0x7FFFFF rsp     ; initialize (BDOS) int stack address
    addr2reg Return_Interrupt r1 ; get address of return function
    sub r1 4 r1             ; remove 4 from address, since function return has offset 4
    write 0 rsp r1          ; write return address on stack
    jump Label_int1         ; jump to interrupt handler of C program
                            ; should return to the address we just put on the stack
    halt                    ; should not get here


Int2:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push rbp
    push rsp

    load32 0x7FFFFF rsp     ; initialize (BDOS) int stack address
    addr2reg Return_Interrupt r1 ; get address of return function
    sub r1 4 r1             ; remove 4 from address, since function return has offset 4
    write 0 rsp r1          ; write return address on stack
    jump Label_int2         ; jump to interrupt handler of C program
                            ; should return to the address we just put on the stack
    halt                    ; should not get here


Int3:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push rbp
    push rsp

    load32 0x7FFFFF rsp     ; initialize (BDOS) int stack address
    addr2reg Return_Interrupt r1 ; get address of return function
    sub r1 4 r1             ; remove 4 from address, since function return has offset 4
    write 0 rsp r1          ; write return address on stack
    jump Label_int3         ; jump to interrupt handler of C program
                            ; should return to the address we just put on the stack
    halt                    ; should not get here


Int4:
    ; backup registers
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push rbp
    push rsp

    load32 0x7FFFFF rsp     ; initialize (BDOS) int stack address
    addr2reg Return_Interrupt r1 ; get address of return function
    sub r1 4 r1             ; remove 4 from address, since function return has offset 4
    write 0 rsp r1          ; write return address on stack
    jump Label_int4         ; jump to interrupt handler of C program
                            ; should return to the address we just put on the stack
    halt                    ; should not get here


; Function that is called after any interrupt handler from C has returned
; Restores all registers and issues RETI instruction to continue from original code
Return_Interrupt:
    ; restore registers
    pop rsp
    pop rbp
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

    reti        ; return from interrrupt

    halt        ; should not get here


; Syscall handler for OS
; Because this is not called during an interrupt, we use a different stack
;  located at the end of BDOS heap

Syscall:
    load32 0x3FFFFF rsp     ; initialize syscall stack address
    addr2reg Return_Syscall r1 ; get address of return function
    sub r1 4 r1             ; remove 4 from address, since function return has offset 4
    write 0 rsp r1          ; write return address on stack
    jump Label_syscall      ; jump to syscall handler of C program
                            ; should return to the address we just put on the stack
    halt                    ; should not get here

Return_Syscall:
    pop r1
    jumpr 3 r1

    halt        ; should not get here


