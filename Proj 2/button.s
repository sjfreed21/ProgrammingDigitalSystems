.text

DC:
	# 0x8FFFFF was found to be a good pace for the DE10-Lite
	# 0x8FFFF  was found to be a good pace for the CPUlator
	movia r12, 0x8FFFFF
D1:
	ldwio r10, 0(r9)
	subi  r12, r12, 1
	bne   r10, r0, SW
	bne   r12, r0, D1
	ret

.global _start
_start:
	# r3 will be loaded to the HEX displays
	# r4 will be OR compared with previous display shifted
	# r5 will be pointer for left
	# r6 will be compare for left
	# r7 will be pointer for right
	# r8 will be compare for right
	# r9 will be button address
	# r10 will be button values
	# r11 will store state
	
	movia r2, 0xff200020
	movia r3, 0x0
	movia r5, L
	addi  r6, r5, 8
	movia r7, R
	addi  r8, r7, 8
	movia r9, 0xff200050	
	
LEFT:
	ldb   r4, 0(r5)
	or    r3, r3, r4
	stwio r3, 0(r2)
	addi  r5, r5, 1
	slli  r3, r3, 8
	movi  r11, 0
	call  DC
	bne   r5, r6, LEFT
	movia r5, L
	br    LEFT
	
RIGHT:
	ldb   r4, 0(r7)
	slli  r4, r4, 24
	or    r3, r3, r4
	stwio r3, 0(r2)
	addi  r7, r7, 1
	srli  r3, r3, 8
	movi  r11, 1
	call  DC
	bne   r7, r8, RIGHT
	movia r7, R
	br    RIGHT
	
SW:
	movi  r3, 0
	stwio r3, 0(r2)
	ldwio r10, 0(r9)
	bne   r10, r0, SW
	movia r5, L
	movia r7, R
	beq   r11, r0, RIGHT
	br    LEFT
		
.data
L:
	.word 0x49497900, 0x49

R:
	.word 0x49494F00, 0x49
