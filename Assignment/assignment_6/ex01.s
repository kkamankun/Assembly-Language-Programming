cr equ 0x0D								; #define cr 0x0d
	AREA strcpy, CODE, READONLY
		ENTRY

start
	LDR	r0, =string1					; Load the address of the string1
	LDR r3, addr						; Load the address of the addr
	
Loop
	LDRB r1, [r0], #1					; Load the first byte into r1
	STRB r1, [r3], #1					; Store the first byte into r3
	CMP r1, #cr							; Is it the terminator?
	BEQ Done							; yes => stop loop
	
	B Loop								; Repeat until the end of string1
	
Done
	mov pc, #0
	
addr DCD 0x40000
string1 DCB "Hello world" ,cr
	END