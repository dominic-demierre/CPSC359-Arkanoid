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
	//variables, should I leave r0-r3 open for parameters? Do I need parameters?

	push	{r4-r9, lr}

	xCoord	.req	r4
	yCoord	.req	r5
	colour	.req	r6
	height	.req	r7
	width	.req	r8
	hitFlag	.req	r9


	ldr	yCoord, [//base address where bricks start, +32 when we move up the game screen]
	ldr	xCoord, [//base address where bricks start, +/-64 as we print each row of bricks the x value goes from 0 to max over and over]

	//determining colour; maybe first 2 rows are blue, next 2 are purple, last 2 are grey.
	//so then colour is dependant on the yCoord
	if yCoord >= base addr for bricks and yCoord <= base+32:
		//ldr	colour, [//hex for blue; find later]
	if yCoord >= base+64 and yCoord <= base+96:
		//ldr	colour, [//hex for purple; find later]
	if yCoord > base+96:
		//ldr	colour, [//hex for dark grey; find later]

	
	//height = 32
	ldr	height, [#32]

	//width = 64
	ldr	width, [#64]

	bl drawShape		//branches to subroutine that takes values and draws pixels


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
