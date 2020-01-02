	AREA ARMex, CODE, READONLY
		ENTRY
start
	MOV r0, #1			; Set up parameters
	MOV r1, #2			; Set up parameters
	MOV r2, #3			; Set up parameters
	MOV r3, #4			; Set up parameters
	
	LDR r4, TEMPADDR1	; Load word into r4
	LDR r5, TEMPADDR1	; Load word into r5
	LDR r6, TEMPADDR2	; Load word into r6
	
	STRB r0, [r5], #1	; Save byte from a register
	STRB r1, [r5], #1	; Save byte from a register
	STRB r2, [r5], #1	; Save byte from a register
	STRB r3, [r5], #1	; Save byte from a register
	
	STRB r3, [r6], #1	; Save byte from a register
	STRB r2, [r6], #1	; Save byte from a register
	STRB r1, [r6], #1	; Save byte from a register
	STRB r0, [r6], #1	; Save byte from a register
	
	LDR r6, [r5]		; Load word into r6
	LDR r5, [r4]		; Load word into r5
	
TEMPADDR1 & &00001000	; Address specified
TEMPADDR2 & &00001004	; Address specified
	
	MOV pc, lr			; Go to first instruction
	END					; Mark end of file