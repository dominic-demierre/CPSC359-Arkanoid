/*****************************************************
 * CPSC 359 Assignment 2, Arkanoid
 * Dominic (last name), Maha (last name), 
 * Jessica (last name), Glenn Skelton
 *
 * Due June 12, 2018
 *
 *****************************************************/

.sect	.data

.align
.globl	frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen hight

.global	GpioPtr
GpioPtr:
	.int	0		@ pointer to the address of the GPIO base register


.global clearBoard
clearBoard:
	.int	768		@ width of the clear screen
	.int	896		@ height of the clear screen


/*----------------------- CODE ----------------------*/
.sect	.data
.global	main

main:

	ldr	r0, =frameBufferInfo
	bl	initFbInfo
	
	bl	getInput			@ test getInput
	bl	testBackgrounds
	


end:
	bl	exit




@ eventually move to seperate file
/*---------------------- FUNCTIONS --------------------*/



/******************************************************
 * Purpose: To test printing all of the screens
 * will eventually make the print a general function
 *
 *
 ******************************************************/
testBackgrounds:
	push	{lr}

	@ call print background to test functionality of linking
	@ to print the backing to the screen, you only need to pass the image address
/*
	@ clear and print background
	ldr	r2, =clearBoard	@ pass the address for image to print
	bl	clearScreen
	ldr	r2, =splashStart
	bl	printBacking
	
	ldr	r0, =0x000FFFFF
	bl	delayMicroseconds	@ delay so that I can see image
	
	@ clear and print background
	ldr	r2, =clearBoard	@ pass the address for image to print
	bl	clearScreen
	ldr	r2, =splashQuit
	bl	printBacking

	ldr	r0, =0x000FFFFF
	bl	delayMicroseconds	@ delay so that I can see image
*/
	@ clear and print background
	@ldr	r2, =clearBoard	@ pass the address for image to print
	@bl	clearScreen
	ldr	r2, =gameBackground	@ pass the address for image to print
	bl	printBacking

	bl	drawPaddle		@ draw the paddle at the specified coordinates in its struct
	@ add clear screen function
	
	pop	{lr}
	bx	lr

.end


