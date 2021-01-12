.data
COUNT: .word 0

.section .reset, "ax"
	br	_start


.section .exceptions, "ax"

	# Allocate stack/Save registers used in exception handler
	subi	sp, sp, 16
	stw     et, 0(sp)
	stw     r7, 4(sp)
	stw		r8, 8(sp)
	stw     r9, 12(sp)
	
	# Check for internal interrupt (ipending)
	rdctl	et, ipending
	beq 	et, r0, hold
	
	# Decrement ea on instruction for external interrupts
	subi 	ea, ea, 4
	
	# Check if interrupt is Interval Timer 0
hold:
	ldwio   r7, 0(r16)
	movia   r8, 3
	bne     r7, r8, hold
	
	# Increment Count/LEDs
	ldw		r9, 0(r18)
	addi 	r9, r9, 1
	stwio	r9, 0(r17)
	stw		r9, 0(r18)
	
	# Clear Interval Timer 0 interrupt
	stwio	r0, 0(r16)
	
	# Restore registers / deallocate stack
	ldw     r9, 12(sp)
	ldw		r8, 8(sp)
	ldw		r7, 4(sp)
	ldw 	et, 0(sp)
	addi	sp, sp, 16
	
	# Return from exception
	eret


.global _start
_start:
	movia	sp, 0x04000000-4
	
	# 1. Configure Interval Timer 0 (device)
	movia	r4, 100000000
	movia   r16, 0xFF202000
	movia   r17, 0xFF200000
	movia   r18, COUNT
	stwio	r4, 8(r16)
	srli	r4, r4, 16
	stwio 	r4, 12(r16)
	movi    r5, 7
	stwio   r5, 4(r16)
	
	# 2. Enable IRQ for Interval Timer 0 (ienable)
	movi	r6, 1
	wrctl   ienable, r6
	
	# 3. Enable interrupts globally (PIE)
	wrctl	status, r6

IDLE:
	br	IDLE