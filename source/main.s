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
/*	
	bl	printSplashStart
	
	ldr	r0, =0x00008000
	bl	delayMicroseconds	@ delay so that I can see image
	bl	printSplashQuit
*/
	ldr	r0, =0x00008000
	bl	delayMicroseconds	@ delay so that I can see image
	bl	getCoord
	bl	printBackground

	@ add clear screen function
	
	pop	{lr}
	bx	lr

.end


