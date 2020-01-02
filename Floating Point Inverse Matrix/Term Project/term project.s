	AREA Term_project, CODE, READONLY

Main
	;Phase 1 : Create Identity Matrix
;REGISTER MAP
;r0 = size N
;r1 = N-1
;r9 = Loop_1 interation count
;r10 = 0x3f800000			;1
;r11 = Matrix_data(addr)
;r12 = Result_data(addr)

	;Init
	LDR r11, =Matrix_data
	LDR r12, Result_data
	LDR r0, [r11], #4		;size N
	SUB r1, r0, #1			;N-1
	MOV r10, #0x3f800000

	MOV r9, r0				
Loop_1
	SUBS r9, #1
	STR	r10, [r12], #4			;Init 1
	ADD r12, r12, r0, LSL #2	;Diagonal
	BNE Loop_1
	
	;Phase 2 : Upper triangular
;REGISTER MAP
;r0 = size N
;r1 = operand_1
;r2 = operand_2
;r3 = Arithmetic Result
;r4 = Pivot addr
;r5 = Under Pivot addr
;r6 = Loop_row_oper iteration count
;r7 = Loop_under_pivot iteration count
;r8 = Loop_pivot iteration count
;r9 = Matrix_Cur_data(addr)
;r10 = Result_Cur_data(addr)
;r11 = Matrix_data(addr)
;r12 = Result_data(addr)

	;Init
	LDR r11, =Matrix_data
	LDR r12, Result_data
	LDR sp, _Stack				;sp <- 0x4000										
	MOV r10, r12				;Result_cur_data
	MOV r4, r11 				;Pivot addr
	ADD r11, r11, #4
	MOV r9, r11

	LDR r1, [r11]
	CMP r1, #0
	STMIAEQ sp!, {r2, r11-r12}
	BEQ	Swap_Rows				; Swapping Two Rows, if pivot is 0
Upper_triangular
	
	MOV r8, #1					;for(int i=1; i<N; i++)
Loop_pivot_U
	CMP r8, r0
	BEQ Diagonal
	ADD r11, r9, r0, LSL #2
	ADD r12, r10, r0, LSL #2
	ADD r4, r4, #4
	ADD r5, r4, r0, LSL #2		;Under pivot addr
	MOV r7, r8					;for(int j=i; j<N; j++)
	ADD r8, r8, #1
Loop_under_pivot
	CMP r7, r0
	ADDEQ r4, r4, r0, LSL #2	;Update pivot addr
	ADDEQ r9, r9, r0, LSL #2
	ADDEQ r10, r10, r0, LSL #2
	BEQ Loop_pivot_U

	ADD r7, r7, #1

	;Calculate Under pivot / Pivot
	LDR r1, [r5]				;Operand1 = Under Pivot
	LDR r2, [r4]				;Operand2 = Pivot
	STMIA sp!, {r4-r8}
	BL FUNC_DIV
	STMIA sp!, {r3}
	
	;Row operation
	MOV r6, #0					;for(int k=0; k<N; k++)
Row_oper_U
	CMP r6, r0
	SUBEQ r9, r9, r0, LSL #2
	SUBEQ r10, r10, r0, LSL #2
	ADDEQ r5, r5, r0, LSL #2
	BEQ Loop_under_pivot
	ADD r6, r6, #1
	LDMDB sp, {r3}
	MOV r1, r3					;operand1 <- Under pivot/pivot
	;Matrix_data Elimination
	LDR r2, [r9], #4			;operand2(pivot)
	STMIA sp!, {r4-r8}
	BL FUNC_MUL					;(Under pivot/pivot)*pivot
	MOV r2, r3
	LDR r1, [r11]				;Under pivot
	STMIA sp!, {r4-r8}
	BL FUNC_SUB					;Under pivot - (Under pivot/pivot)*pivot : approximately 0
	CMP r5, r11
	MOVEQ r3, #0
	STR r3, [r11], #4	
	;Result_data Elimination
	LDMDB sp, {r3}
	MOV r1, r3	
	LDR r2, [r10], #4			;Result pivot
	STMIA sp!, {r4-r8}
	BL FUNC_MUL
	MOV r2, r3
	LDR r1, [r12]	
	STMIA sp!, {r4-r8}
	BL FUNC_SUB					;Under pivot - (Under pivot/pivot)*pivot
	STR r3, [r12], #4	
	B Row_oper_U
	
Swap_Rows
	SUB r3, r0, #1				; N-1
	MOV r2, #0
Loop_Swap_Matrix
	CMP r2, r0
	MOVEQ r2, #0
	BEQ Loop_Swap_Result
	LDR r1, [r11]
	ADD r11, r11, r0, LSL #2	
	SWP r1, r1, [r11]
	SUB r11, r11, r0, LSL #2
	SWP r1, r1, [r11]
	ADD r11, r11, #4
	ADD r2, r2, #1
	B Loop_Swap_Matrix
Loop_Swap_Result
	CMP r2, r0
	LDMDBEQ sp!, {r2, r11-r12}
	BEQ Upper_triangular
	LDR r1, [r12]
	ADD r12, r12, r0, LSL #2
	SWP r1, r1, [r12]
	SUB r12, r12, r0, LSL #2
	SWP r1, r1, [r12]
	ADD r12, r12, #4
	ADD r2, r2, #1
	B Loop_Swap_Result
	
	;Phase 3 : Diagonal
;REGISTER MAP
;r0 = size N
;r1 = operand_1
;r2 = operand_2
;r3 = Arithmetic Result
;r4 = Pivot addr
;r5 = 0x3f800000				;1
;r6 = Loop_row_oper iteration count
;r7 = Loop_pivot iteration count
;r10 = Pivot
;r11 = Matrix_data(addr)
;r12 = Result_data(addr)

Diagonal
	;init
	LDR r11, =Matrix_data
	LDR r12, Result_data
	MOV r4, r11					;Pivot addr
	ADD r11, r11, #4
	MOV r5, #0x3f800000			;1
	
	MOV r7, #0					;for(int i=0; i<N; i++)
Loop_pivot_D
	CMP r7, r0
	BEQ Lower_triangular
	ADD r7, r7, #1
	MOV r6, #0
	ADD r4, r4, #4
	LDR r10, [r4]				;Pivot
Loop_row_oper					;for(int j=0; j<N; j++)
	CMP r6, r0
	ADDEQ r4, r4, r0, LSL #2
	BEQ Loop_pivot_D
	ADD r6, r6, #1
	;Matrix_data division
	LDR r1, [r11]							
	MOV r2, r10
	STMIA sp!, {r4-r8}
	BL FUNC_DIV
	CMP r4, r11
	STREQ r5, [r11], #4
	STRNE r3, [r11], #4
	;Result_data division
	LDR r1, [r12]
	MOV r2, r10
	STMIA sp!, {r4-r8}
	BL FUNC_DIV
	STR r3, [r12], #4
	B Loop_row_oper
	
	;Phase 4 : Lower Triangular
;REGISTER MAP
;r0 = size N
;r1 = operand_1
;r2 = operand_2
;r3 = Arithmetic Result
;r4 = Pivot addr
;r5 = Above Pivot addr
;r6 = Loop_row_oper iteration count
;r7 = Loop_above_pivot iteration count
;r8 = Loop_pivot iteration count
;r9 = Matrix_Cur_data(addr)
;r10 = Result_Cur_data(addr)
;r11 = Matrix_data(addr)
;r12 = Result_data(addr)

Lower_triangular	
	;init
	SUB r12, r12, #4
	MOV r10, r12				;Init Result_cur_data(addr)
	MOV r4, r11
	SUB r11, r11, #4
	MOV r9, r11
	
	MOV r8, #1					;for(int i=1; i<N; i++)
Loop_pivot_L
	CMP r8, r0
	BEQ Finish_Main
	SUB r11, r9, r0, LSL #2		
	SUB r12, r10, r0, LSL #2
	SUB r4, r4, #4
	SUB r5, r4, r0, LSL #2		;Above pivot addr
	MOV r7, r8					;for(int j=i; j<N; j++)
	ADD r8, r8, #1
Loop_above_pivot
	CMP r7, r0
	SUBEQ r4, r4, r0, LSL #2
	SUBEQ r9, r9, r0, LSL #2
	SUBEQ r10, r10, r0, LSL #2
	BEQ Loop_pivot_L
	
	ADD r7, r7, #1
	
	;Calculate above pivot / pivot
	LDR r1, [r5]				;Above pivot
	LDR r2, [r4]				;Pivot
	STMIA sp!, {r4-r8}
	BL FUNC_DIV
	STMIA sp!, {r3}
	
	
	MOV r6, #0					;for(int k=0; k<N; k++)
Row_oper_L
	CMP r6, r0
	ADDEQ r9, r9, r0, LSL #2
	ADDEQ r10, r10, r0, LSL #2
	SUBEQ r5, r5, r0, LSL #2
	BEQ Loop_above_pivot
	ADD r6, r6, #1
	LDMDB sp, {r3}
	;Matrix_data elimination
	MOV r1, r3
	LDR r2, [r9], #-4
	STMIA sp!, {r4-r8}
	BL FUNC_MUL
	MOV r2, r3
	LDR r1, [r11]				;Above pivot
	STMIA sp!, {r4-r8}
	BL FUNC_SUB					;Above pivot - (Above pivot/pivot)*pivot : approximately 0
	CMP r5, r11
	MOVEQ r3, #0
	STR r3, [r11], #-4	
	;Result data elimination
	LDMDB sp, {r3}
	MOV r1, r3
	LDR r2, [r10], #-4
	STMIA sp!, {r4-r8}
	BL FUNC_MUL
	MOV r2, r3
	LDR r1, [r12]	
	STMIA sp!, {r4-r8}
	BL FUNC_SUB					;Abobe pivot - (Above pivot/pivot)*pivot
	STR r3, [r12], #-4	
	B Row_oper_L
	
Finish_Main
	MOV pc, #0					;Program end
	
	
; ==========  REGISTER MAP ===========
;	ARITHMETIC
;	r1 = Operand_1
;	r2 = Operand_2
;	r3 = Result
;=====================================
	
; #### SUBTRACTION ####	
FUNC_SUB
Special_case_SUB
	MOV r7, r1, LSL #1
	CMP r7, #0					; 0 - r2 
	ADDEQ r2, #2147483648		; 2^31 = 2,147,483,648
	MOVEQ r3, r2				; Result = -Num2
	BEQ	Finish_SUB
	MOV r7, r2, LSL #1
	CMP r7, #0					; r1 - 0
	MOVEQ r3, r1				; Result = Num1
	BEQ Finish_SUB
		
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
	
	ADD r5, r5, #0x800000		; Prepend leading 1
	ADD r6, r6, #0x800000		; Prepend leading 1
	
	; Phase 2 : Compare exponents + Shift smaller mantissa if necessary
	CMP r3, r4
	RSBLT r8, r3, r4			; r3 < r4
	MOVLT r5, r5, LSR r8 		; Shift num1's mantissa
	MOVLT r3, r4				; Standard exponent
	SUBGT r8, r3, r4			; r3 > r4
	MOVGT r6, r6, LSR r8		; Shift num2's mantissa 
	
	; Phase 3 : Add or subtract mantissas according to the sign bit
	CMP r1, r2	
	BNE ADDM_SUB				; Add mantissas
	
	CMP r5, r6					; Sub mantissas
	BEQ Finish_SUB				; Result = 0
	SUBLT r5, r6, r5			; r5 = r6 - f5, if r5 < r6
	ADDLT r1, r1, #1			; Sign bit depends on mantissa addition
	SUBGT r5, r5, r6			; r5 = r5 - r6, if r5 > r6
Loop_SUB
	CMP r5, #8388608			; 2^23 = 8,388,608
	MOVLT r5, r5, LSL #1		; Normalize mantissa until 1.xxxxxx
	SUBLT r3, r3, #1			; Adjust exponent
	BLT	Loop_SUB
	BGE	Assemble_SUB
	
ADDM_SUB
	ADD r5, r5, r6
	CMP r5, #16777216			; 2^24 = 16777216
	MOVGE r5, r5, LSR #1		; Normalize mantissa, if 10.xxxxxx
	ADDGE r3, r3, #1			; Adjust exponent
	
	; Phase 4 : Assemble sign, exponent, and fraction back into floating-point format
Assemble_SUB
	SUB r5, r5, #0x800000		; Remove leading 1  
	MOV r1, r1, LSL #31			; Sign bit
	MOV r3, r3, LSL #23			; Exponent bit
	ADD r3, r1, r3				; Assemble sign bit, exponent,
	ADD r3, r3, r5				; and fraction
	
Finish_SUB
	LDMDB sp!, {r4-r8}
	MOV pc, lr
	
; #### MULTIPLICATION ####
FUNC_MUL
Special_case_MUL
	MOV r7, r1, LSL #1
	CMP r7, #0
	MOVEQ r3, #0				; Result = 0
	BEQ	Finish_MUL
	MOV r7, r2, LSL #1
	CMP r7, #0
	MOVEQ r3, #0				; Result = 0
	BEQ Finish_MUL
	
	; Phase 1 : Extract sign, exponent, and fraction bit + Prepend leading 1 to form mantissa
	; Exponent
	MOV r3, r1, LSL #1	
	MOV r3, r3, LSR #24			; Exponent of num1
	MOV r4, r2, LSL #1
	MOV r4, r4, LSR #24			; Exponent of num2
	ADD r3, r3, r4
	SUB r3, r3, #127
	
	; Fraction
	MOV r5, r1, LSL #9
	MOV r5, r5, LSR #9			; Fraction bits of num1
	MOV r6, r2, LSL #9
	MOV r6, r6, LSR #9 			; Fraction bits of num2
	
	; Sign bit
	MOV r1, r1, LSR #31			; Sign bit of num1
	MOV r2, r2, LSR #31 		; Sign bit of num2
	EOR r1, r1, r2
	
	ADD r5, r5, #0x800000		; Prepend leading 1
	ADD r6, r6, #0x800000		; Prepend leading 1
	
	; Phase 2 : Multiply mantissas
	MOV r5, r5, LSL #6			; r5 = A
	ADD r8, r5, r5				; r8 = 2A
	MOV r6, r6, LSL #1			; {X, X-1}

	MOV r2, #14
Radix_4
	SUBS r2, r2, #1
	BEQ Normalize_MUL
				
	MOV r7, r6, LSL #29			
	MOVS r7, r7, LSR #29			; r7 = {X+1, X, X-1}, Y = 3bits
	BEQ SHIFT
		
	CMP r7, #2
	BLE ADD_1A
	
	CMP r7, #4
	BLT ADD_2A
	BEQ SUB_2A
	
	CMP r7, #6
	BLE SUB_1A
	BGT SHIFT

SHIFT
	MOV r6, r6, LSR #2		
	MOV r4, r4, ASR #2		; Shift only
	B Radix_4	
ADD_1A
	ADD r4, r4, r5			; Result + A
	MOV r4, r4, ASR #2		; Add 1A and Shift
	MOV r6, r6, LSR #2	
	B Radix_4
ADD_2A
	ADD r4, r4, r8			; Result + 2A
	MOV r4, r4, ASR #2		; Add 2A and Shift
	MOV r6, r6, LSR #2
	B Radix_4
SUB_1A
	SUB r4, r4, r5			; Result - A
	MOV r4, r4, ASR #2		; Add 1A and Shift
	MOV r6, r6, LSR #2
	B Radix_4
SUB_2A
	SUB r4, r4, r8			; Result - 2A
	MOV r4, r4, ASR #2		; Add 2A and Shift
	MOV r6, r6, LSR #2
	B Radix_4

	; Phase 3 : Normalize mantissa, if necessary
Normalize_MUL					
	CMP r4, #134217728			; 2^28
	MOVGE r4, r4, LSR #1		; Normalize mantissa, if 10.xxxxxx
	ADDGE r3, r3, #1			; Adjust exponent
	
	MOV r7, r4, LSL #30
	MOV r7, r7, LSR #31
	CMP r7, #1
	
	; Phase 4 : Assemble sign, exponent, and fraction back into floating-point format	
Assemble_MUL
	MOV r1, r1, LSL #31			; Sign bit
	MOV r3, r3, LSL #23			; Exponent bit
	MOV r4, r4, LSL #6
	MOV r4, r4, LSR #9			; Fraction bit
	ADDEQ r4, r4, #1
	ADD r3, r1, r3				; Assemble sign bit, exponent,
	ADD r3, r3, r4				; and fraction
	
Finish_MUL
	LDMDB sp!, {r4-r8}
	MOV pc, lr
	
; #### DIVISION ####	
FUNC_DIV
Special_case_DIV
	MOV r7, r1, LSL #1
	CMP r7, #0
	MOVEQ r3, #0            	 ; Result = 0
	BEQ   Finish_DIV
;	MOV r10, r2, LSL #1
;	CMP r10, #0
;	MOVEQ r9, #0x7F800000      ; Result = Infinity
;	BEQ Finish
   
	; Phase 1 : Extract sign, exponent, and fraction bit + Prepend leading 1 to form mantissa
	; Exponent
	MOV r3, r1, LSL #1   
	MOV r3, r3, LSR #24         ; Exponent of num1
	MOV r4, r2, LSL #1
	MOV r4, r4, LSR #24         ; Exponent of num2
	SUB r3, r3, r4				; Exponent bit
	ADD r3, r3, #127
   
	; Fraction
	MOV r5, r1, LSL #9
	MOV r5, r5, LSR #9         ; Fraction bits of num1
	MOV r6, r2, LSL #9
	MOV r6, r6, LSR #9         ; Fraction bits of num2
   
	; Sign bit
	MOV r1, r1, LSR #31       ; Sign bit of num1
	MOV r2, r2, LSR #31       ; Sign bit of num2
	EOR r1, r1, r2				; Sign bit
   
	ADD r5, r5, #0x800000  		; Prepend leading 1
	ADD r6, r6, #0x800000		; Prepend leading 1
   
	; Phase 2 : Divide mantissas
	MOV r8, r5					; R <- Dividend
	MOV r7, #0					; Q <- 32'b0
   
Division
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	;10
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	
	CMP r8, r6				
	ADDGE r7, r7, #1			; Q = Q + 1, if R >= D
	SUBGE r8, r8, r6			; R = R - D
	MOV r7, r7, LSL #1
	MOV r8, r8, LSL #1
	;23
			
	; Phase 3 : Normalize mantissa, if necessary
Normalize_DIV
	CMP r7, #8388608				
	MOVLT r7, r7, LSL #1		; Normalize mantissa until 1.xxxxxx
	SUBLT r3, r3, #1			; Adjust exponent
  
	; Phase 4 : Assemble sign, exponent, and fraction back into floating-point format   
Assemble_DIV
	MOV r1, r1, LSL #31         ; Sign bit
	MOV r3, r3, LSL #23         ; Exponent bit
	SUB r7, r7, #8388608	
	ADD r3, r1, r3              ; Assemble sign bit, exponent,
	ADD r3, r3, r7              ; and fraction
   
Finish_DIV
	LDMDB sp!, {r4-r8}
	MOV pc, lr
	
Matrix_data
	DCD 5
	DCD 2_01000010101010000000000000000000
	DCD 2_01000001000000000000000000000000
	DCD 2_01000011011010000000000000000000
	DCD 2_01000001010001000000000000000000
	DCD 2_01000001111000000000000000000000
	DCD 2_01000010101100000000000000000000
	DCD 2_11000001000110000000000000000000
	DCD 2_11000010001110000000000000000000
	DCD 2_00000000000000000000000000000000
	DCD 2_01000100011110000000000000000000
	DCD 2_00000000000000000000000000000000
	DCD 2_11000010011110000000000000000000
	DCD 2_01000001110010000000000000000000
	DCD 2_11000010101110000000000000000000
	DCD 2_00000000000000000000000000000000
	DCD 2_01000011011101000000000000000000
	DCD 2_11000010110110000000000000000000
	DCD 2_11000000000100000000000000000000
	DCD 2_01000000010010000000000000000000
	DCD 2_01000010000000000000000000000000
	DCD 2_01000010000110000000000000000000
	DCD 2_01000010001000000000000000000000
	DCD 2_00000000000000000000000000000000
	DCD 2_11000100001110000000000000000000
	DCD 2_11000010001110000000000000000000


Result_data
	DCD 0x60000000

_Stack
	DCD 0x4000
	END