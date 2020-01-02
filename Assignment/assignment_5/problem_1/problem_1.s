	AREA P_1, CODE, READONLY
		ENTRY
		
Main
	LDR r0, Addr1				; Result adress
	LDR r1, Num1				; Floating-point number 1
	LDR r2, Num2				; Floating-point number 2

Special_case
	MOV r10, r1, LSL #1
	CMP r10, #0
	MOVEQ r9, r2				; Result = Num2
	BEQ	Finish
	MOV r10, r2, LSL #1
	CMP r10, #0
	MOVEQ r9, r1				; Result = Num1
	BEQ Finish
	
	LDR r7, Value1				; 1000 0000 0000 0000 0000 0000
	
	; Phase 1 : Extract sign, exponent, and fraction bit + Prepend leading 1 to form mantissa
	; Exponent
	MOV r3, r1, LSL #1	
	MOV r3, r3, LSR #24			; Exponent of num1
	MOV r4, r2, LSL #1
	MOV r4, r4, LSR #24			; Exponent of num2
	
	; Fraction
	MOV r5, r1, LSL #9
	MOV r5, r5, LSR #9			; Fraction bits of num1
	MOV r6, r2, LSL #9
	MOV r6, r6, LSR #9 			; Fraction bits of num2
	
	; Sign bit
	MOV r1, r1, LSR #31			; Sign bit of num1
	MOV r2, r2, LSR #31 		; Sign bit of num2
	
	ORR r5, r5, r7				; Prepend leading 1
	ORR r6, r6, r7				; Prepend leading 1
	
	; Phase 2 : Compare exponents + Shift smaller mantissa if necessary
	CMP r3, r4
	RSBLT r8, r3, r4			; r3 < r4
	MOVLT r5, r5, LSR r8 		; Shift num1's mantissa
	MOVLT r3, r4				; Standard exponent
	SUBGT r8, r3, r4			; r3 > r4
	MOVGT r6, r6, LSR r8		; Shift num2's mantissa 
	
	; Phase 3 : Add or subtract mantissas according to the sign bit
	CMP r1, r2	
	BEQ ADDM					; Add mantissas
	
	CMP r5, r6					; Sub mantissas
	BEQ Finish					; Result = 0
	SUBLT r5, r6, r5			; r5 = r6 - f5, if r5 < r6
	MOVLT r1, r2				; Sign bit depends on mantissa addition
	SUBGT r5, r5, r6			; r5 = r5 - r6, if r5 > r6
Loop
	CMP r5, #16777216			; 2^24 = 16777216
	MOVLT r5, r5, LSL #1		; Normalize mantissa until 1.xxxxxx
	SUBLT r3, r3, #1			; Adjust exponent
	BLT	Loop
	BGE	Assemble
	
ADDM
	ADD r5, r5, r6
	CMP r5, #16777216			; 2^24 = 16777216
	MOVGE r5, r5, LSR #1		; Normalize mantissa, if 10.xxxxxx
	ADDGE r3, r3, #1			; Adjust exponent
		
Assemble
	SUB r5, r5, r7 				; Remove leading 1  
	MOV r1, r1, LSL #31			; Sign bit
	MOV r3, r3, LSL #23			; Exponent bit
	ADD r9, r1, r3				; Assemble sign bit, exponent,
	ADD r9, r9, r5				; and fraction
	
Finish
	STR r9, [r0]				; Store result
	MOV pc, #0
		
;Num1 DCD 0x3FC00000 			; 1.5
;Num2 DCD 0x40500000  			; 3.25
;Num1 DCD 0xC2680000			 ; -58
Num1 DCD 0x42680000 			; 58
;Num1 DCD 0x426C0000				; 59
Num2 DCD 0xC26c0000				; -59
;Num2 DCD 0x80000000 				; Special case

Addr1 DCD &40000000
Value1 DCD 0x800000				; 1000 0000 0000 0000 0000 0000
	END