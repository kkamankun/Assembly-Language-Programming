	AREA	ARMex, CODE, READONLY
		ENTRY
Main
	LDR		r0, Address_1	; Load word(address) into a r0
	MOV		r1, #1			; Move a 32-bit value into a r1
	
	MOV r2, r1, LSL #1		; r2 = 0b10
	ADD		r3, r2, r1		; r3 = 3
	LSL		r4, r1, r3		; r4 = 0b1000
	ADD		r2, r2, r4		; r2 = 10
	
	; n * (n + 10)
	MOV		r3, r2			; r3 = 10
	ADD		r3, r3, r3		; r3 = 20
	MUL		r4, r3, r2		; r4 = 20 * 10
	
	STR		r4, [r0]		; Save word(data) from a r4
	MOV		pc, lr			; Restart at the end of the program
	
Address_1	DCD &4000000
	END