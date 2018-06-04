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




/*----------------------- CODE ----------------------*/
.sect	.data
.global	main

main:

	ldr	r0, =frameBufferInfo
	bl	initFbInfo
	
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
	
	
	ldr	r2, =splashStart
	bl	printBacking
	
	ldr	r0, =0x000FFFFF
	bl	delayMicroseconds	@ delay so that I can see image

	ldr	r2, =splashQuit
	bl	printBacking

	ldr	r0, =0x000FFFFF
	bl	delayMicroseconds	@ delay so that I can see image

	@ to print the backing to the screen, you only need to pass the image address 
	ldr	r2, =gameBackground	@ pass the address for image to print
	bl	printBacking

	@ add clear screen function
	
	pop	{lr}
	bx	lr

.end


