	AREA ARMex, CODE, READONLY
		ENTRY
Main
	LDR		r0, Address_1	; Load word(address) into a r0
	MOV		r1, #1			; Move a 32-bit value into a r1
	
	MOV	r2, r1, LSL #1		; r2 = 0b10
	ADD		r3, r2, r1		; r3 = r2 + r1
	LSL		r4, r1, r3		; r4 = 0b1000
	ADD		r3, r3, r4		; r3 = 11 
	MOV		r4, r3			; r4 = 11
	
Loop
	ADD		r3, r3, r2		; r3 = r3 + 2
	ADD		r4, r4, r3		; r4 = 11 + 13
	CMP		r3, #29			; Compare
	BEQ		EndLine			; Jump to first instruction of EndLine Label, if Equal
	B		Loop			; Jump to first instruction of Loop Label
	
EndLine	
	STR		r4, [r0]		; Save word(data) from a r4
	MOV		pc, lr			; Restart at the end of the program
	
Address_1	DCD &4000000
	END						; Mark end of file
	