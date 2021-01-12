	.text
	.equ	LEDs,		0xFF200000
	.equ	SWITCHES,	0xFF200040
	.global _start
_start:
	movia	r2, LEDs		# Address of LEDs         
	movia	r3, SWITCHES	# Address of switches

LOOP:
	ldwio	r4, (r3)		# Read the state of switches
	srli	r5, r4, 5		# Get first number by shifting 
	slli	r6, r5, 5		# Shift first number back to same location as they are in r4
	sub		r7, r4, r6		# Subtract r6 from r4 to only have digits of first five switches
	add     r4, r5, r7		# Add values
	stwio	r4, (r2)		# Display the state on LEDs
	br		LOOP

	.end

	# Notes:
	# r0 = 0
	# r1 = at
	# r2 = LEDs
	# r3 = SWs
	# r4 = sum
	# r5 = first val in indexes 4-0
	# r6 = first val in indexes 9-5
	# r7 = second val