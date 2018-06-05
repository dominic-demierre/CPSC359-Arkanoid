
.sect	.text

/******************************************
 *
 * r0 - buttons pressed (hex value)s
 * no return value
 ******************************************/
.global updatePaddle
updatePaddle:
	push	{lr}

	ldr	r4, =paddleImage		@ get the address of the paddle image
	ldr	r6, [r4]	

	@ r0 - has the ascii value
	@ if A is held, the ball will speed up, increase the velocity and decrease when depressed
	@ might need to adjust so that it just tests the individual bits incase other buttons are pressed
	@ test if right and A are pressed
	mov	r1, #0xFE7F
	teq	r0, r1
	ldreq	r5, [r4, #16]			@ if a is also pressed, double velocity first
	lsleq	r5, #1				@ multiply r5 by 2
	addeq	r6, r5				@ add the velocity value to the displacement
	beq	testCollisions			@ go to the end if done

	@ test if left and A are pressed
	mov	r1, #0xFEBF
	teq	r0, r1
	ldreq	r5, [r4, #16]			@ if a is also pressed, double velocity first
	lsleq	r5, #1				@ multiply r5 by 2
	subeq	r6, r5				@ add the velocity value to the displacement
	beq	testCollisions			@ go to the end if done

	@ test if right and not A are pressed
	mov	r1, #0xFF7F
	teq	r0, r1
	ldreq	r5, [r4, #16]			@ if a is also pressed, double velocity first
	lsleq	r5, #1				@ multiply r5 by 2
	addeq	r6, r5				@ add the velocity value to the displacement
	beq	testCollisions			@ go to the end if done

	@ test if left and not A are pressed
	mov	r1, #0xFFBF
	teq	r0, r1
	ldreq	r5, [r4, #16]			@ if a is also pressed, double velocity first
	lsleq	r5, #1				@ multiply r5 by 2
	subeq	r6, r5				@ add the velocity value to the displacement
	beq	testCollisions			@ go to the end if done	

	@ test collisions
testCollisions:
	@r4 has paddle image, r6 has the new offset
	@ get screen dimensions
	ldr	r5, =gameBackground		@ get the address of the game background
	ldr	r5, [r5]			@ get the width of the board
	lsr	r5, #1				@ divide the board to get half the width
	rsb	r1, #0				@ get the negative value of the board
	add	r1, #32				@ left boarder threshold 
	add	r5, #-32				@ right boarder threshold
	add	r2, r6, #-48			@ get the left side of the paddle
	add	r3, r6, #48			@ get the right side of the paddle
	
	@ test thresholds
	cmp	r2, r1				@ see if the paddle is touching the left boarder
	beq	endUpdate			@ if there is a collision, exit instead of updating	
	cmp	r3, r5				@ see if the paddle is touching the right boarder
	beq	endUpdate			@ if there is a collision, exit with no update
 	@ if their are no collisions, update the displacement
	ldr	r6, [r4]			@ load the new displacement back into the paddle image
endUpdate:	
	
	pop	{r4-r6, lr}
	bx	lr
	


.end