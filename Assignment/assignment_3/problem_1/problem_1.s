	AREA ARMex, CODE, READONLY
		ENTRY

start
	LDR r0, tempaddr
	MOV r1, #1					; r1 = 1
	ADD r2, r1, r1      		; r2 = 2
	ADD r3, r2, r2, LSL #1  	; r3 = 1*2*3
	ADD r4, r3, r3, LSL #1      ; r4 = 1*2*3*3
	ADD r4, r4, r3				; r4 = 1*2*3*4
	ADD r5, r4, r4, LSL #2		; r5 = 1*2*3*4*5
	ADD r6, r5, r5, LSL #2		; r6 = r5 + 4 * r5
	ADD r6, r6, r5				; r6 = 1*2*3*4*5*6
	RSB r7, r6, r6, LSL #2		; r7 = r6 + 4 * r6
	ADD r7, r7, r6, LSL #2		; r7 = 1*2*3*4*5*6*7
	RSB r8, r7, r7, LSL #3		; r8 = 8 * r7 - r7
	ADD r8, r8, r7				; r8 = 1*2*3*4*5*6*7*8
	ADD r9, r8, r8, LSL #3		; r9 = 1*2*3*4*5*6*7*8*9
	ADD r10, r9, r9, LSL #3		; r10 = r9 * 8 + r9
	ADD r10, r10, r9			; r10 = 1*2*3*4*5*6*7*8*9*10
	
	
	str r1, [r0], #4			; Save word(data) from r1
	str r2, [r0], #4			; Save word(data) from r2
	str r3, [r0], #4			; Save word(data) from r3
	str r4, [r0], #4			; Save word(data) from r4
	str r5, [r0], #4			; Save word(data) from r5			
	str r6, [r0], #4			; Save word(data) from r6
	str r7, [r0], #4			; Save word(data) from r7
	str r8, [r0], #4			; Save word(data) from r8
	str r9, [r0], #4			; Save word(data) from r9
	str r10, [r0], #4			; Save word(data) from r10

	
	mov pc, lr				; Restart at the end of the program
	
tempaddr & &40000

	end						; Mark end of file