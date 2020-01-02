	AREA ARMex, CODE, READONLY
		ENTRY
		
start
	LDR r0, tempaddr	; Load word into a r0
	MOV r1, #1			; r1 = 1
	MOV r11, #2			; r11 = 2
	MUL r2, r1, r11		; r2 = 1 * 2
	ADD r11, r11, #1	; r11 = 3
	MUL r3, r2, r11		; r3 = 1 * 2 * 3
	ADD r11, r11, #1	; r11 = 4
	MUL r4, r3, r11		; r4 = 1 * 2 * 3 * 4
	ADD r11, r11, #1	; r11 = 5
	MUL r5, r4, r11		; r5 = 1 * 2 * 3 * 4 * 5
	ADD r11, r11, #1	; r11 = 6
	MUL r6, r5, r11		; r6 = 1 * 2 * 3 * 4 * 5 * 6
	ADD r11, r11, #1	; r11 = 7
	MUL r7, r6, r11		; r7 = 1 * 2 * 3 * 4 * 5 * 6  * 7
	ADD r11, r11, #1	; r11 = 8
	MUL r8, r7, r11		; r8 = 1 * 2 * 3 * 4 * 5 * 6  * 7 * 8
	ADD r11, r11, #1	; r11 = 9
	MUL r9, r8, r11		; r9 = 1 * 2 * 3 * 4 * 5 * 6  * 7 * 8 * 9
	ADD r11, r11, #1	; r11 = 10
	MUL r10, r9, r11	; r10 = 1 * 2 * 3 * 4 * 5 * 6  * 7 * 8 * 9 * 10

	str r1, [r0], #4	; Save word(data) from r1
	str r2, [r0], #4	; Save word(data) from r2
	str r3, [r0], #4	; Save word(data) from r3
	str r4, [r0], #4	; Save word(data) from r4
	str r5, [r0], #4	; Save word(data) from r5
	str r6, [r0], #4	; Save word(data) from r6
	str r7, [r0], #4	; Save word(data) from r7
	str r8, [r0], #4	; Save word(data) from r8
	str r9, [r0], #4	; Save word(data) from r9
	str r10, [r0], #4	; Save word(data) from r10
	
	mov pc, lr			; Restart at the end of the program
	
tempaddr & &40000

	end					; Mark end of file
	