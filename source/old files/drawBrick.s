/***************************************************************************************************************************************************************
	*NOTE
	*This is a very rough draft written mainly in gibbrish and pseudo-code
	*I will continue work on this later on (I am so hungry and tired)
	*Suggestions and critiques are VERY welcome!
	*Otherwise, I believe this is the general idea for the brick objects
	*However I do find this part of ARM and this entire assignment to be difficult for me to fully grasp and understand
****************************************************************************************************************************************************************/

//CPSC 359 Assignment 2: Arkanoid
//Jessica Pelley - Drawing bricks draft
//r4 = x
//r5 = y
//r6 = colour
//r7 = height
//r8 = width
//r9 = binary value where 0=not hit, 1=hit
//Just want to print bricks of different colors; blue, purple, and a dark grey/black
//bricks 32x64


.section .text

.global drawBrick


drawBrick:

	push	{r4-r9, lr}

	xCoord	.req	r4
	yCoord	.req	r5
	colour	.req	r6
	height	.req	r7
	width	.req	r8
	hitFlag	.req	r9


	ldr	yCoord, [#352]						//base address where bricks start, -32 when we move up the game screen
	ldr	xCoord, [#0]						//base address where bricks start, +64 as we print each row of bricks the x value goes from 0 to max over and over
	ldr	height, [#32]
	ldr	width, [#64]


	//Loop for printing bricks
loopTop:
	
	mov	colour, //hex purple					//init colour to puprle:3 hit
	
	cmp	yCoord, #224
	movgt	colour, //hex blue					//if yCoord is in range change colour to blue:2 hit

	cmp	yCoord, #288
	movgt	colour, //hex green					//if yCoord in range change to green:1 hit
	

	//move x, y and colour into r0, r1, and r2
	//need to give width and height?
	bl DrawPixel

	add	xCoord, #64						//move into location for next brick location horizontally
	cmp	xCoord, #768						//see if we've hit the end
	blt	loopTop							//if not, branch to top

	sub	yCoord, #32						//move to next row of bricks up
	mov	xCoord, #0						//reset x

	cmp	yCoord, #192						//top buffer + 32(height of brick)
	bgt	endLoop							//if we've printed to top row and y has hit where it should end, stop the loop
	b	loopTop							//otherwise branch to loopTop to start printing this row

endLoop:
	//end, reset x and y maybe?




	//hit flag; checks collision
	bl checkCollision

	if 0:
		//not hit, don't needs to do anything

	if 1:
		//is hit. Need to either:
			if grey: turn purple
			if purple: turn blue
			if blue: clear from screen
			else: no actual collisions, ball ignores


	pop	{r4-r9, pc}


.end
