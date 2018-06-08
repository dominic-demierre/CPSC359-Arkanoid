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
.global test
test:
	.asciz	"test"

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

resetPositions:
	.int	0, 368		@ starting positions for paddle and ball (x,y of paddle; x, y of ball)


/*----------------------- CODE ----------------------*/
.sect	.data
.global	main

main:
	bl	setup
	
	@ run tests
	bl	testBackgrounds
	
	bl	testPaddle
	
end:
	bl	exit




@ eventually move to seperate file
/*---------------------- FUNCTIONS --------------------*/

/******************************************************
 * Setup GPIO register, pins and framebuffer
 *
 *
 ******************************************************/
setup:
	push	{lr}

	ldr	r0, =frameBufferInfo
	bl	initFbInfo

	ldr	r0, =GpioPtr			@ get address of pointer to initialize
	bl	initGpioPtr			@ set up base address

	mov	r0, #1				@ set for output in r1
	mov	r1, #9				@ pin 9 in r1 (Latch)
	bl	init_GPIO			@ set pin 9 to output

	mov	r0, #1				@ set for output in r1
	mov	r1, #11				@ pin 11 in r1 (Clock)
	bl	init_GPIO			@ set pin 11 to output

	mov	r0, #0				@ set for input in r1
	mov	r1, #10				@ pin 10 in r1 (Data)
	bl	init_GPIO			@ set pin 10 to input

	pop	{lr}
	bx	lr

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
testPaddle:
	push	{r4-r6, r10, lr}
	ldr	r4, =gameBackground
	ldr	r10, =paddleImage
	
	
inputLoop:
	bl	Read_SNES			@ get the input from the SNES paddle
	@ if start button is pressed reset the game
	mov	r1, #0xFFF7			@ move test mask to see if start was pressed
	teq	r0, r1				@ test to see if user pressed start
	
	@ if start was pressed, go to label resetPositions, write values in label into the paddle and ball labels to reset
	@ if select was pressed, branch to the main menu label (also reset values in paddle and ball)

	beq	endTestPaddle	

	@ loop of updates and drawing functions 
	bl	updatePaddle
	mov	r2, r4
	bl	printBacking
	bl	drawPaddle
	b	inputLoop
	
endTestPaddle:	
	pop	{r4-r6, r10, lr}
	bx	lr



.end


