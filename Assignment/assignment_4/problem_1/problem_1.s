	AREA blockData, CODE, READONLY	; Name this block of code
		ENTRY						; Mark first instruction to execute
		
start
	mov r0, #1						; Set parameters
	mov r1, #2						; Set parameters
	mov r2, #3						; Set parameters
	mov r3, #4						; Set parameters
	mov r4, #5						; Set parameters
	mov r5, #6						; Set parameters
	mov r6, #7						; Set parameters
	mov r7, #8						; Set parameters
	
	ldr r8, TEMPADDR1				; Set start address
	
	STMIA r8!, {r0-r7}				; Store r0-r7 on mem
	
	LDR r8, TEMPADDR1				; Set start address
	LDMIA r8!, {r1}					; load from r0 to r1
	LDMIA r8!, {r6}					; load from r1 to r6
	LDMIA r8!, {r0}					; load from r2 to r0
	LDMIA r8!, {r2}					; load from r3 to r2
	LDMIA r8!, {r7}					; load from r4 to r7
	LDMIA r8!, {r3}					; load from r5 to r3
	LDMIA r8!, {r4}					; load from r6 to r4
	LDMIA r8!, {r5}					; load from r7 to r5
	
	
	MOV pc, #0						; end
	
TEMPADDR1 & &40000					; stack start address
	end								; Mark end of file
		