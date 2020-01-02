	AREA	ARMex, CODE, READONLY
		ENTRY

Main
	LDR		r0, =Array_1		; Load word(address) into a r0
	LDR		r1, Address_1		; Load word(data) into a r1
	MOV		r2, #9				; Move a 32-bit value into a r2
	MOV		r3, #4				; Move a 32-bit value into a r3
	
Loop
	MUL		r4, r2, r3			; r4 = r2 * r3
	LDR		r5, [r0, r4]		; Load word(data) into a r5
	STR		r5, [r1], r3		; Save word(data) from r5
	
	SUB		r2, r2, #1			; Count loops
	CMP		r2, #-1				; compare
	BEQ		EndLine				; Terminate, if they are equal
	B		Loop				; Jump to first instruction of Loop Label
	
EndLine
	MOV		pc, lr				; Restart at the end of the program
	
Array_1 	DCD	10, 9, 8, 7, 6, 5, 4, 3, 2, 1
Address_1	DCD	&4000000
	END							; Mark end of file