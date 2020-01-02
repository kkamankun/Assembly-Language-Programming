	AREA subrout, CODE, READONLY	; Name this block of code
		ENTRY						; Mark first instruction to execute
		
start
	MOV r0, #10						; Set up parameters
	MOV r1, #11						; Set up parameters
	MOV r2, #12						; Set up parameters
	MOV r3, #13						; Set up parameters
	MOV r4, #14						; Set up parameters
	MOV r5, #15						; Set up parameters
	MOV r6, #16						; Set up parameters
	MOV r7, #17						; Set up parameters	
	MOV r10, #160					; Set up parameters	
	
	LDR r11, TEMPADDR1				; Set start address
	BL doRegister
	BL doGCD
		
stop
	MOV pc, #0						; end

doRegister
	STMFD sp!, {r0-r7, lr}			; PUSH into stack
	ADD r9, r9, r0
	ADD r0, r0, r0

	MOV r8, r1
	ADD r1, r1, #1					; Addition
	ADD r9, r9, r1					; r9 = r0 + r1
	ADD r1, r1, r8
	
	MOV r8, r2
	ADD r2, r2, #2					; Addition
	ADD r9, r9, r2					; r9 = r0 + r1 + r2
	ADD r2, r2, r8

	MOV r8, r3
	ADD r3, r3, #3					; Addition
	ADD r9, r9, r3					; r9 = r0 + r1 + r2 + r3
	ADD r3, r3, r8
	
	MOV r8, r4
	ADD r4, r4, #4					; Addition
	ADD r9, r9, r4					; r9 = r0 + r1 + r2 + r3 + r4
	ADD r4, r4, r8

	MOV r8, r5
	ADD r5, r5, #5					; Addition
	ADD r9, r9, r5					; r9 = r0 + r1 + r2 + r3 + r4 + r5
	ADD r5, r5, r8
	
	MOV r8, r6
	ADD r6, r6, #6					; Addition
	ADD r9, r9, r6					; r9 = r0 + r1 + r2 + r3 + r4 + r5 + r6
	ADD r6, r6, r8
	
	MOV r8, r7
	ADD r7, r7, #7					; Addition
	ADD r9, r9, r7					; r9 = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7
	ADD r7, r7, r8					
	STMIB r11, {r0-r7}				
	LDMFD sp!, {r0-r7, pc}			; POP from stack

doGCD
	CMP r9, r10						; while(r9 != r10)
	SUBGT r9, r9, r10				; if(r9 > r10)	r9 = r9 - r10
	SUBLE r10, r10, r9				; else r10 = r10 - r9
	BNE doGCD
	STR	r9, [r11]					; store on mem
	MOV pc, lr						; go BL
	
TEMPADDR1 & &40000					; Stack start address
	END