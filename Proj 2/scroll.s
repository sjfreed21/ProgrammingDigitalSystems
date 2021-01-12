.text

DELAY:
	# 0x8FFFFF was found to be a good pace for the DE10-Lite
	# 0x8FFFF  was found to be a good pace for the CPUlator
	movia r10, 0x8FFFFF
D1:
	subi  r10, r10, 1
	bne   r10, r0, D1
	ret

.global _start
_start:
	# r3 will be loaded to the HEX displays
	# r4 will be OR compared with previous display shifted
	# r5 will be byte pointer for the text
	# r6 will be byte compare for the text
	# r7 will be word pointer for the patterns
	# r8 will be word compare for the patterns
	
	movia r2, 0xff200020
	movia r3, 0x0
	movia r5, TEXT
	addi  r6, r5, 18
	movia r7, PTRN
	addi  r8, r7, 48
	
CLEAR:
	ldb   r4, 0(r5)
	or    r3, r3, r4
	stwio r3, 0(r2)
	addi  r5, r5, 1
	slli  r3, r3, 8
	call  DELAY
	bne   r5, r6, CLEAR
	movia r5, TEXT
	
PATRN:
	ldw   r3, 0(r7)
	stwio r3, 0(r2)
	addi  r7, r7, 4
	call  DELAY
	bne   r7, r8, PATRN	
	movia r7, PTRN
	
	br    CLEAR
	
	break
	
	
.data
TEXT:
	.word 0x38387976, 0x3E7F003F, 0x406D7171, 0x00004040, 0x0
	
PTRN:
	.word 0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x49494949, 0x36363636, 0x7f7f7f7f, 0x0, 0x7f7f7f7f, 0x0, 0x7f7f7f7f, 0x0