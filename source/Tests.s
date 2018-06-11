.sect	.data

/******************************************************
 * Purpose: To test printing all of the screens
 * will eventually make the print a general function
 *
 *
 ******************************************************/
.global	testBackgrounds
testBackgrounds:
	push	{lr}

	@ call print background to test functionality of linking
	@ to print the backing to the screen, you only need to pass the image address

	@ clear and print background
	ldr	r2, =splashStart
	bl	printBacking
	
	ldr	r0, =0x000FFFFF
	bl	delayMicroseconds	@ delay so that I can see image
	
	@ clear and print background
	ldr	r2, =splashQuit
	bl	printBacking

	ldr	r0, =0x000FFFFF
	bl	delayMicroseconds	@ delay so that I can see image

	@ clear and print background
	ldr	r2, =gameBackground	@ pass the address for image to print
	bl	printBacking
	bl	drawPaddle
	
	pop	{lr}
	bx	lr

/******************************************************
 * Purpose: To test printing all of the screens
 * will eventually make the print a general function
 *
 *
 ******************************************************/
/*
.global	testPaddle
testPaddle:
	push	{r4-r6, r10, lr}
	ldr	r4, =gameBackground
	ldr	r10, =paddleImage
	
	
inputLoop:
	bl	Read_SNES			@ get the input from the SNES paddle
	
	@ start button
	
	mvn	r0, r0				@ get the compliment of r0
	mov	r1, #0x8			@ for seeing if start was pressed
	and	r1, r1, r0			@ extract the bit for start
	lsr	r1, #3				@ shift the bit for testing if on for start
	teq	r1, #1				@ see if bit is turned on
	beq	resetGame			@ if start was pressed proceed
	
	@select button
	
	mvn	r0, r0				@ get the compliment of r0
	mov	r1, #0x4			@ for seeing if select was pressed
	and	r1, r1, r0			@ extract the bit for select
	lsr	r1, #2				@ shift the bit for testing if on for select
	teq	r1, #1				@ see if bit is turned on
	beq	mainMenu			@ if select was pressed proceed
	
	@ if start was pressed, go to label resetPositions, write values in label into the paddle and ball labels to reset
	@ if select was pressed, branch to the main menu label (also reset values in paddle and ball)

//	beq	endTestPaddle	

	@ loop of updates and drawing functions 
	bl	updatePaddle
	bl	updateBall
	mov	r2, r4
	bl	printBacking
	bl	drawPaddle
	bl	drawBall
	b	inputLoop
	

endTestPaddle:	
	pop	{r4-r6, r10, lr}
	bx	lr
*/
