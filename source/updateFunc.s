
.sect	.text

/******************************************
 *
 * r0 - buttons pressed (hex value)s
 * no return value
 ******************************************/
.global updatePaddle	@there is an error in here
updatePaddle:
	push	{r4-r6, lr}

	ldr	r4, =paddleImage		@ get the address of the paddle image
	ldr	r6, [r4]	
	ldr	r5, [r4, #16]			@ obtain the value for the velocity
	mvn	r0, r0				@ get the compliment of r0
	mov	r1, #0x40			@ for seeing if left was pressed
	mov	r2, #0x80			@ for seeing if right was pressed
	and	r1, r1, r0			@ extract the bit for left
	and	r2, r2, r0			@ extract the bit for right
	lsr	r1, #6				@ shift the bit for testing if on for left
	lsr	r2, #7				@ shift the bit for testing if on for right
	teq	r1, #1				@ see if bit is turned on
	beq	leftPressed			@ if left was pressed proceed
	teq	r2, #1				@ see if bit was turned on
	beq	rightPressed			@ if right was pressed proceed
	b	endUpdate			@ if neither were pressed, exit

leftPressed:
	mov	r1, #0x100			@ create mask for seeing if A was pressed
	and	r1, r1, r0			@ extract the bit
	lsr	r1, #8				@ shift A button bit over
	teq	r1, #1				@ check to see if A was pressed
	lsleq	r5, #1				@ multiply the velocity by 2 if A was pressed			
	sub	r6, r5				@ add the velocity value to the displacement
	b	testCollisions
	
rightPressed:
	mov	r1, #0x100			@ create mask for seeing if A was pressed
	and	r1, r1, r0			@ extract the bit
	lsr	r1, #8				@ shift A button bit over
	teq	r1, #1				@ check to see if A was pressed
	lsleq	r5, #1				@ multiply the velocity by 2 if A was pressed	
	add	r6, r5				@ add the velocity value to the displacement
	b	testCollisions			@ go to the end if done
	
	@ test collisions
testCollisions:
	@r4 has paddle image, r6 has the new offset
	@ get screen dimensions
	ldr	r5, =gameBackground		@ get the address of the game background
	ldr	r5, [r5]			@ get the width of the board
	lsr	r5, #1				@ divide the board to get half the width
	rsb	r1, r5, #0			@ get the negative value of the board
	add	r1, #32				@ left boarder threshold 
	add	r5, #-32			@ right boarder threshold
	add	r2, r6, #-48			@ get the left side of the paddle (from current position)
	add	r3, r6, #48			@ get the right side of the paddle (from current position)
	
	@ test thresholds
	cmp	r2, r1				@ see if the paddle is touching the left boarder
	ble	endUpdate			@ if there is a collision, exit instead of updating	
	cmp	r3, r5				@ see if the paddle is touching the right boarder
	bge	endUpdate			@ if there is a collision, exit with no update
 	@ if their are no collisions, update the displacement
	str	r6, [r4]			@ load the new displacement back into the paddle image

endUpdate:	
	
	pop	{r4-r6, lr}
	bx	lr
	


.end