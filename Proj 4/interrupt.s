# REGISTER NOTES
# These were how the registers were originally intended -
# 	slowly fell apart for some but partially true
# r2 will be the address of the HEX displays
# r3 will be the loaded to HEX displays 		
# r4 will be OR compared with previous display	
# r5 will be byte pointer for the text			
# r6 will be byte compare for the text
# r7 thru r10 ended up being general use...
# r11 will be speed status
# r12 will be speed max
# r13 will be pointer temp
# r14 will be value temp
# r16 will be Timer 0 base address
# r17 will be Button base address
.section .reset, "ax"
	br		_start
	
.section .exceptions, "ax"
	# Prefix
	subi 	sp, sp, 48
	stw 	et, 0(sp)
	stw 	r3, 4(sp)
	stw		r4, 8(sp)
	stw		r5, 12(sp)
	stw		r6, 16(sp)
	stw 	r7, 20(sp)
	stw		r8, 24(sp)
	stw 	r9, 28(sp)
	stw		r10, 32(sp)
	stw		r11, 36(sp)
	stw		r12, 40(sp)
	stw		r13, 44(sp)
	
	# Check interrupt
	rdctl	et, ipending
	beq 	et, r0, key_hold
	
	# Derement ea for external
	subi 	ea, ea, 4
	
	# Check if interrupt is KEY0/KEY1/Both
key_hold:
	ldwio 	r7, 0(r17)
	beq 	r7, r0, timer_hold
	movia 	r8, CURRENT
	ldw		r11, 8(r8)
	ldw 	r12, 12(r8)
	movi 	r9, 2
	beq		r7, r9, spd_dn
	subi	r9, r9, 1
	beq 	r7, r9, spd_up
	
	# Handle Button
both_bttn:
	ldwio 	r7, 0(r17)
	bne		r7, r0, both_bttn
	br		clear
spd_up:
	ldwio 	r7, 0(r17)
	bne		r7, r0, spd_up
	beq		r11, r12, clear
	addi	r11, r11, 1
	ldw		r8, 4(r8)
	movi	r9, 4
	div		r8, r8, r9
	muli	r8, r8, 2
	stwio   r8, 8(r16)
	srli    r8, r8, 16
	stwio   r8, 12(r16)	
	movia 	r12, CURRENT
	stw		r8, 4(r12)
	stw		r11, 8(r12)
	br		clear
spd_dn:
	ldwio	r7, 0(r17)
	bne 	r7, r0, spd_dn
	beq 	r11, r0, clear
	subi	r11, r11, 1
	ldw		r8, 4(r8)
	movi	r9, 4
	div		r8, r8, r9
	muli	r8, r8, 6
	stwio   r8, 8(r16)
	srli    r8, r8, 16
	stwio   r8, 12(r16)	
	movia 	r12, CURRENT
	stw		r8, 4(r12)
	stw		r11, 8(r12)
	br 		clear
	
	
	# Check if interrupt is Timer
timer_hold:
	ldwio	r7, 0(r16)
	movia	r8, 3
	bne		r7, r8, clear
	
	# Shift Data
	movia	r3, CURRENT
	ldw		r3, 0(r3)
	movia	r5, POINT
	ldw		r5, 0(r5)
	ldb		r4, 0(r5)
	or		r3, r3, r4
	stwio	r3, 0(r2)
	addi	r5, r5, 1
	slli 	r3, r3, 8
	movia	r13, CURRENT
	stw		r3, 0(r13)
	movia	r6, TAIL
	ldw		r6, 0(r6)
	movia	r13, POINT
	stw		r5, 0(r13)
	bne		r5, r6, clear
	movia 	r5, TEXT
	movia 	r6, POINT
	stw		r5, 0(r6)
	
	# Clear Interrupts
clear:
	movi	r0, 0(r16)
	stwio   r10, 12(r17)
	
	# Suffix
end:
	ldw		r13, 44(sp)
	ldw 	r12, 40(sp)
	ldw		r11, 36(sp)
	ldw		r10, 32(sp)
	ldw		r9, 28(sp)
	ldw		r8, 24(sp)
	ldw		r7, 20(sp)
	ldw		r6, 16(sp)
	ldw		r5, 12(sp)
	ldw		r4, 8(sp)
	ldw		r3, 4(sp)
	ldw 	et, 0(sp)
	addi 	sp, sp, 48
	
	# Return from exception
	eret
	
.text
.global _start
_start:
	movia	sp, 0x04000000 - 4
	
	# Configure Timer with Default Speed
	movia	r7, 100000000
	movia   r16, 0xFF202000
	stwio   r7, 8(r16)
	srli    r7, r7, 16
	stwio   r7, 12(r16)
	movi 	r8, 7
	stwio	r8, 4(r16)
	
	# Configure Pushbutton Interrupts
	movia	r17, 0xFF200050
	movia	r9, 0b11
	stwio	r9, 8(r17)
	
	# Enable IRQs
	movi	r10, 0b11
	wrctl	ienable, r10
	
	
	# Setup
	movia r2, 0xff200020 
	movia r5, TEXT
	movia r6, POINT
	stw	  r5, 0(r6)
	addi  r5, r5, 15
	movia r6, TAIL
	stw	  r5, 0(r6)	
	movia r8, CURRENT
	stw	  r7, 4(r8)
	movia r11, 3
	stw	  r11, 8(r8)
	
	# Enable interrupts globally
	movi	r10, 1
	wrctl 	status, r10
	
IDLE:
	br	  IDLE

.data
TEXT: 
	.word 0x38387976, 0x3E7F003F, 0x006D7171, 0x0
POINT:
	.word 0x0
TAIL:
	.word 0x0
CURRENT:
	.word 0x0, 0x0, 0x0, 0x6
	# display, speed, min, max
