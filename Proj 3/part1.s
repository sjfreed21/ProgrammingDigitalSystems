.text
.global sum_two
sum_two:
	addi sp, sp, -12
	stw  ra, 8(sp)
	stw  r4, 4(sp)
	stw  r5, 0(sp)
	
	add  r2, r4, r5
	
	ldw  r5, 0(sp)
	ldw  r4, 4(sp)
	ldw  ra, 8(sp)
	addi sp, sp, 12
	ret

.global op_three
op_three:
	addi sp, sp, -16
	stw  ra, 12(sp)
	stw  r4, 8(sp)
	stw  r5, 4(sp)
	stw  r6, 0(sp)
	
	call sum_two
	mov  r4, r2
	mov  r5, r6
	call sum_two
	
	ldw  r6, 0(sp)
	ldw  r5, 4(sp)
	ldw  r4, 8(sp)
	ldw  ra, 12(sp)
	addi sp, sp, 16
	ret

.global fibonacci
fibonacci:
	addi sp, sp, -4
	stw  ra, 0(sp)
	
	movi r8, 1
	movi r9, 2
	beq  r4, r8, one
	beq  r4, r9, base
	beq  r0, r4, zero
	subi r4, r4, 1
	
	call fibonacci
	
back:
	add  r2, r8, r9
	mov  r8, r9
	mov  r9, r2
end:
	ldw  ra, 0(sp)
	addi sp, sp, 4
	ret
	
base:
	movi r8, 0
	movi r9, 1
	br 	 back
	
one:
	movi r2, 1
	br   end
	
zero:
	movi r2, 0
	br   end