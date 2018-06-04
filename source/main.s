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
	

	@ call print background to test functionality of linking
	bl	printBackground


end:
	bl	exit




@ eventually move to seperate file
/*---------------------- FUNCTIONS --------------------*/

/*****************************************************
 * Purpose: To print the main background image.
 *
 *
 *
 *
 *****************************************************/
printBackground:
	push	{lr}

	bl	getCoord		@ get coordinate of the center + offset for pixels
	bl	printImage		@ return value is the params for next
		
	pop 	{lr}
	bx	lr




.end


