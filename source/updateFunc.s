
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
	b	testPaddleCollisions
	
rightPressed:
	mov	r1, #0x100			@ create mask for seeing if A was pressed
	and	r1, r1, r0			@ extract the bit
	lsr	r1, #8				@ shift A button bit over
	teq	r1, #1				@ check to see if A was pressed
	lsleq	r5, #1				@ multiply the velocity by 2 if A was pressed	
	add	r6, r5				@ add the velocity value to the displacement
	b	testPaddleCollisions		@ go to the end if done
	
	@ test collisions
testPaddleCollisions:
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
	
/*********************************
 * takes no arguments and returns nothing
 *********************************/
.global	updateBall
updateBall:
	push	{r4-r6, lr}

	ldr 	r0, =ballImage

	ldr 	r2, [r0]	@get x
	ldr 	r3, [r0, #4]	@get y
	ldr 	r4, [r0, #12]	@get velocity
	ldr 	r5, [r0, #16]	@get direction

	@test bit 0 of direction
	mov 	r6, #1
	tst	r5, r6
	subeq 	r0, r2, r4	@bit 0 = 0: left
	addne	r0, r2, r4	@bit 0 = 1: right

	@test bit 1 of direction
	lsl	r6, #1
	tst	r5, r6
	subeq	r1, r3, r4	@bit 1 = 0: up
	addne 	r1, r3, r4	@bit 1 = 1: down
	
	bl	testBallCollisions

	ldr	r3, =ballImage
	str 	r0, [r3]
	str 	r1, [r3, #4]
	str	r2, [r3, #16]

	pop	{r4-r6, lr}
	bx	lr

testBallCollisions:
	push	{r4-r10, lr}

	x	.req	r4
	y	.req	r5
	dia	.req	r6
	vel	.req	r7
	dir	.req	r8
	temp	.req	r9
	edge	.req	r10

	mov	x, r0
	mov	y, r1
	
	ldr	r0, =ballImage
	ldr	dia, [r0, #8]
	ldr	vel, [r0, #12]		@get velocity
	ldr	dir, [r0, #16]		@get direction

	ldr	r0, =gameBackground
	ldr	temp, [r0]		@get background width
	lsr	temp, #1		@cut in half
	rsb	r2, temp, #0		@get the negative value of the board
	add	r2, #38			@left border threshold 
	add	r1, temp, #-38		@right border threshold

	cmp	x, r1			@test x against right border
	movgt	x, r1
	bicgt	dir, dir, #1		@and start moving left

	cmp	x, r2			@test x against left border
	movlt	x, r2
	orrlt	dir, dir, #1		@and start moving right

	ldr	temp, [r0, #4]		@get background height
	lsr	temp, #1		@cut in half
	rsb	r1, temp, #0		@get the negative value of the board
	add	r1, #160		@find top border threshold	

	cmp	y, r1			@test y against top border
	movlt	y, r1
	orrlt	dir, dir, #2		@and start moving down

	ldr	r0, =paddleImage
	ldr	temp, [r0]		@get x of paddle
	sub	r1, temp, #48		@find left edge of paddle
	add	r2, temp, #48		@find right edge of paddle

	cmp	x, r1			@test lower bound of ball x value
	moveq	edge, r1		@if ball is touching left edge store its x

	bgt	tbc_checkRange
	beq	tbc_checkEdge
	blt	tbc_done 

tbc_checkRange:
	cmp	x, r2			@test upper bound of ball x value
	moveq	edge, r2		@if ball is touching right edge store its x

	blt	tbc_inRange
	beq	tbc_checkEdge
	bgt	tbc_done

tbc_inRange:
	mov	r1, #358

	cmp	y, r1			@compare y to paddle height
	movgt	y, r1
	bicgt	dir, dir, #2		@start moving back up

	b	tbc_done

tbc_checkEdge:
	mov	r1, #358
	mov	r2, #386

	cmp	y, r1			@test lower bound of ball y value
	bge	tbc_checkEdgeRange
	blt	tbc_done

tbc_checkEdgeRange:
	cmp	y, r2			@test upper bound of ball y value
	ble	tbc_onEdge
	bgt	tbc_done

tbc_onEdge:
	mov	x, edge
	eor	dir, dir, #1
	bic	dir, dir, #2

tbc_done:	
	mov	r0, x
	mov 	r1, y
	mov	r2, dir
	.unreq	x
	.unreq	y
	.unreq	dia
	.unreq	vel
	.unreq	dir
	.unreq	temp
	.unreq	edge
	pop	{r4-r10, lr}
	bx	lr

.end