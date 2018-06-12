/*****************************************************
 * CPSC 359 Assignment 2, Arkanoid
 * Dominic Demierre, Maha Asim, 
 * Jessica Pelley, Glenn Skelton
 *
 * Due June 12, 2018
 *
 *****************************************************/

.sect	.data

/* upper boundary of ball is a little off */
/* need to try and fix the refresh */

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

.global score
score:	.int 0

.global lives
lives:	.int 3


/*----------------------- CODE ----------------------*/
.sect	.data
.global	main

main:
	bl	setup				@ set up all buffers for the game proccesses
	@ print the starting screen		

	@ get user input to determine mode
	bl 	mainMenu			@ get user input for starting or quiting the game
	@ will only go on if select is pressed else it will terminate, r0 will have 0 or 1 

	cmp	r0, #0				@ if the function mainMenu returned 0, terminate the program
	beq	end				@ exit the program, will need to write a blank screen
	bne	startGame			@ if function returned 1, go on to the game loop

startGame:
	ldr	r5, =gameBackground
	mov	r2, r5				@ prepare the background image for function call
	bl	printBacking			@ print the background image
	bl	printLives
	bl	drawPaddle			@ draw the paddle on the scren
	bl	drawBall			@ draw the ball on the screen

wait:
	bl	Read_SNES			@ get the input from the SNES paddle
	ldr	r1, =0xFFFE	
	teq	r0, r1				@ test to see if the B button has been pressed to start
	beq	gameLoop			@ if the B button was pressed, start the game
	bne	wait				@ while the input is not B, keep waiting
gameLoop:
				
	bl	Read_SNES			@ get the input from the SNES paddle	
	mov	r4, r0	

	@ start button
	mvn	r1, r0				@ get the compliment of r0
	mov	r2, #0x8			@ for seeing if start was pressed
	and	r2, r2, r1			@ extract the bit for start
	lsr	r2, #3				@ shift the bit for testing if on for start
	teq	r2, #1				@ see if bit is turned on
	bleq	resetGame			@ if start was pressed, reset the game parameters
	bleq	startGame			@ go back to the start of the game

	@select button
	mvn	r1, r0				@ get the compliment of r0
	mov	r2, #0x4			@ for seeing if select was pressed
	and	r2, r2, r1			@ extract the bit for select
	lsr	r2, #2				@ shift the bit for testing if on for select
	teq	r2, #1				@ see if bit is turned on
	bleq	resetGame			@ if start was pressed, reset the game parameters
	bleq	main				@ if select was pressed, go back to the main menu

	
	// will need to clear here
	ldr	r0, =paddleImage
	bl	clearPaddle
	ldr	r0, =ballImage
	bl	clearBall
	@ loop of updates and drawing functions 
	mov	r0, r4
	bl	updatePaddle
	bl	updateBall
	mov	r2, r5
	bl	drawPaddle
	bl	drawBall
	@ delay frames
	mov	r0, #8000			
	lsl 	r0, #1				
	bl	delayMicroseconds		@ frame rate delay
	

	@ create if condition to only reprint the lives and score if they change
	bl	printLives			
	bl	printScore
		
	b	gameLoop

end:
	bl	exit				@ terminate the program




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
 * Main menu loop
 * call mainMenu function to wait for user input to start or exit
 *
 * check to see if up or down is pressed or A to go onto game loop
 * if nothing keep polling for input
 * return value will be 1 for going to main menu or 0 to quit
 ******************************************************/
mainMenu:	
	push	{r4, r5, lr}
	
	mov	r5, #0				@ defualt 0 for start screen and 1 for quit selection

	@ start with the start button selected
	ldr	r2, =splashStart
	bl	printBacking

readInLoop:
	bl	Read_SNES			@ get the input from the SNES paddle
	mov	r1, #0xFFFF			@ mask to check if a button was pushed or not
	teq	r0, r1				@ test to see if a button was pushed
	beq	readInLoop			@ if not go back and wait until it one is pushed
	
btnPressed:
	@ r0 contains the buttons pressed
	mov	r4, r0				@ store the button values in r4	for any function calls

	mvn	r0, r0				@ get the compliment of r0
	mov	r1, #0x10			@ for seeing if up was pressed
	mov	r2, #0x20			@ for seeing if down was pressed
	mov	r3, #0x100			@ value to see if A was pressed
	and	r1, r1, r0			@ extract the bit for up
	and	r2, r2, r0			@ extract the bit for down
	and	r3, r3, r0			@ extract the bit for down
	lsr	r1, #4				@ shift the bit for testing if on for up
	lsr	r2, #5				@ shift the bit for testing if on for down
	lsr	r3, #8				@ shift the bit for testing if on for A
	
	@ test if A was pressed first to see if it should go on
	teq	r3, #1				@ see if bit is turned on
	beq	aPressed			@ got to A pressed label if true to determine what mode to execute 
	teq	r2, #1				@ see if bit is turned on for DOWN
	beq	checkScreenFlag			@ if so determine which screen to change
 	teq	r1, #1				@ see if bit is turned on for UP
	beq	checkScreenFlag			@ if so determine which screen to change
	b	readOutLoop			@ if nothing valid was pressed, continue to read

checkScreenFlag:
	cmp	r5, #0				@ test to see what the flag bit is set to 
	beq	quitScreen			@ if flag is set to 0, got to quitScreen to change to quit screen image
	bne	startScreen			@ if flag is set to 1, got to startScreen to change to start screen image
	b	readOutLoop			@ error so exit

startScreen:
	teq	r2, #1				@ make sure that up wasn't pressed
	beq	readOutLoop			@ if so, continue back to reading input
	ldr	r2, =splashStart		@ get the start screen address
	bl	printBacking			@ print the start screen
	mov	r5, #0				@ change flag to 0 to signify that start screen is now enabled
	b	readOutLoop

quitScreen:
	teq	r1, #1				@ make sure that down wasn't pressed
	beq	readOutLoop			@ if so, continue back to reading input
	ldr	r2, =splashQuit			@ get the exit screen address
	bl	printBacking			@ print the exit screen
	mov	r5, #1				@ change flag to 1 to signify that quit screen is now enabled
	b	readOutLoop

aPressed:
	cmp	r5, #0				@ see which screen we are currently on
	moveq	r0, #1				@ if start was selected, return value of 1 to start game
	movne	r0, #0				@ if quit was selected, return 0 to terminate the game
	b	endMainLoop			@ terminate main menu loop	

readOutLoop:
	@ delay to eliminate any accidental multiple prints from odd elecetrical connection
	mov	r0, #5000			@ value to delay, multiplied by 2
	lsl 	r0, #1				@ delay is 10 miliseconds
	bl	delayMicroseconds		@ delay for 10 miliseconds

	bl	Read_SNES			@ get the input from the SNES paddle
	mov	r1, #0xFFFF			@ mask to check if a button was released
	cmp	r0, r1				@ test to see if a button was pushed	
	bne	readOutLoop			@ if not go back and wait until it one is pushed
	b	readInLoop			@ loop back to get input
	
endMainLoop:
	pop	{r4, r5, lr}
	bx	lr

/******************************************************
 * Purpose: To reset the ball and paddle positions
 *
 *
 ******************************************************/
resetGame:
	push	{lr}
	
	@ reset the paddle:
	ldr	r0, =paddleImage
	mov	r1, #0
	str	r1, [r0]
	mov	r1, #368
	str	r1, [r0, #4]
	
	@ reset the ball:
	ldr	r0, =ballImage
	mov	r1, #0
	str	r1, [r0]
	mov	r1, #368
	str	r1, [r0, #4]
	mov	r1, #12
	str	r1, [r0, #8]
	mov	r1, #4
	str	r1, [r0, #12]
	mov	r1, #0
	str	r1, [r0, #16]
	
	pop	{lr}
	bx	lr
	


.end


