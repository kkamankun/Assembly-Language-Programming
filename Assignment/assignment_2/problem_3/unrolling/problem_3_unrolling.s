	AREA ARMex, CODE, READONLY
		ENTRY
Main
	LDR		r0, Address_1		; Load word(address) into a r0
	MOV		r1, #1				; Move a 32-bit value into a r1
	
	MOV	r2, r1, LSL #1			; r2 = 0b10
	ADD		r3, r2, r1			; r3 = 3
	LSL		r4, r1, r3			; r4 = 0b1000
	ADD		r3, r3, r4			; r3 = 11
	MOV		r4, r3				; r4 = 11
	
	ADD	r3, r3, r2			; r3=r3+r2			r3=13
	ADD r4, r4, r3			; r4=r4+r3				 r4=24
	ADD	r3, r3, r2			; r3=r3+r2			r3=15
	ADD r4, r4, r3			; r4=r4+r3				 r4=39
	ADD	r3, r3, r2			; r3=r3+r2			r3=17
	ADD r4, r4, r3			; r4=r4+r3				 r4=56
	ADD	r3, r3, r2			; r3=r3+r2			r3=19
	ADD r4, r4, r3			; r4=r4+r3				 r4=75
	ADD	r3, r3, r2			; r3=r3+r2			r3=21
	ADD r4, r4, r3			; r4=r4+r3				 r4=96
	ADD	r3, r3, r2			; r3=r3+r2			r3=23
	ADD r4, r4, r3			; r4=r4+r3				 r4=119
	ADD	r3, r3, r2			; r3=r3+r2			r3=25
	ADD r4, r4, r3			; r4=r4+r3				 r4=144
	ADD	r3, r3, r2			; r3=r3+r2			r3=27
	ADD r4, r4, r3			; r4=r4+r3				 r4=171
	ADD	r3, r3, r2			; r3=r3+r2			r3=29
	ADD r4, r4, r3			; r4=r4+r3				 r4=200

	STR	r4, [r0]			; Save word(data) from r4
	MOV	pc, lr				; Restart at the end of the program

Address_1	DCD	&4000000
	END