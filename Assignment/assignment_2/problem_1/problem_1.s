	AREA ARMex, CODE, READONLY
	ENTRY

Main
	LDR		r0, Address_1 	; Load word into a r0
	LDR 	r1,	=string_1 	; Load word into a r1
	LDR 	r2, =string_2 	; Load word into a r2
	MOV		r5, #0x0A	  	; Move a 32-bit value into a r5
	MOV		r6, #0x0B		; Move a 32-bit value into a r6
	
Loop
	LDRB	r3, [r1], #1	; r3 = mem[r1], r1 = r1 + 1
	LDRB	r4, [r2], #1	; r4 = mem[r2], r2 = r2 + 1
	
	CMP		r3, r4			; Compare string_1 and string_2
	STRNE	r6, [r0]		; Save byte or word from a r6, if they are equal
	BNE		EndLine			; Jump to first instruction of EndLine Label
	
	CMPEQ	r3, #0			; If any string is equal to NULL
	STREQ	r5, [r0]		; Save byte or word from a r5, if they are equal
	BEQ		EndLine			; Jump to first instruction of EndLine Label
	B		Loop			; Loop
	
EndLine
	MOV		pc, lr			; Restart at the end of the program
	
string_1	DCB	"Hello",0
string_2	DCB "Hello_keil",0
Address_1	DCD	&40000000
	END						; Mark end of file