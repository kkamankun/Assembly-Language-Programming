	AREA ARMex, CODE, READONLY
		ENTRY
start
	LDR r3, TEMPADDR1	; Load address into a register
	
	MOV r4, #8			; Set up parameters
	STRB r4, [r3]		; Save byte from a register
	
	MOV r4, #10			; Set up parameters
	STRB r4, [r3, #1]	; Save byte from a register
	
	MOV r4, #12			; Set up parameters
	STRB r4, [r3, #2]	; Save byte from a register
	
	MOV r4, #10			; Set up parameters
	
	LDRB r0, [r3]		; Load byte into a register
	LDRB r1, [r3, #1]	; Load byte into a register
	LDRB r2, [r3, #2]	; Load byte into a register
	
	CMP r0, r4			; compare(r0 - r4)
	MOVGT r5, #1		; Store integer 1 to r5, if r0 > r4
	MOVMI r5, #2		; Store integer 2 to r5, if r0 < r4
	MOVEQ r5, #3		; Store integer 3 to r5, if r0 = r4
	
	CMP r1, r4			; compare(r1 - r4)
	MOVGT r5, #1		; Store integer 1 to r5, if r1 > r4
	MOVMI r5, #2		; Store integer 2 to r5, if r1 < r4
	MOVEQ r5, #3		; Store integer 3 to r5, if r1 = r4
		
	CMP r2, r4			; compare(r2 - r4)
	MOVGT r5, #1		; Store integer 1 to r5, if r2 > r4
	MOVMI r5, #2		; Store integer 2 to r5, if r2 < r4
	MOVEQ r5, #3		; Store integer 3 to r5, if r2 = r4
	
TEMPADDR1 & &00001000	; Address specified

	MOV pc, lr			; Go to first instruction
	END					; Mark end of file
		