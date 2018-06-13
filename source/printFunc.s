
.sect	.text

/******************************************
 *
 * r0 - x
 * r1 - y
 * r2 - colour
 ******************************************/
.global DrawPixel
DrawPixel:
	push	{r4, r5, lr}

	offset	.req	r4

	ldr	r5, =frameBufferInfo		@ get the frame buffer address

	@ offset = (y * width) + x
	ldr	r3, [r5, #4]			@ r3 is the screen width
	mul	r1, r3				@ multiply the y value by the width
	add	offset, r0, r1			@ r4 is the offset computed

	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl	offset, #2			@ multiply the offset by 4

	ldr	r0, [r5]			@ get the base address to add offset to
	str	r2, [r0, offset]		@ store the pixel value in its approriate location

	.unreq	offset

	pop	{r4, r5, lr}
	bx	lr

/******************************************
 * Purpose: to print an image
 * r0 - x
 * r1 - y
 * r2 - the address to read in
 * find way to make this a general function
 * for printing any background
 *
 ******************************************/
.global printBacking
printBacking:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	mov	sAddr, r2			@ r2 has the address of the image to print, save in sAddr

	mov	r3, r2				@ move the image address into r3 to get coordinates
	bl	getCoord			@ get the coordinates of the image for printing
	@ return is in r0 - x, r1 - y	
	
	add	colour, sAddr, #8 		@ address of first ascii value
	mov	x, r0	@ store x		@ copy the x value into x
	mov	y, r1	@ store y		@ copy the y value into y to save

	mov	outCnt, #0 			@ height counter
outerLoop:
	ldr	temp, [sAddr, #4]		@ store the screen height in temp
	cmp	outCnt, temp			@ compare counter with heigth
	bge	done				@ if the pixels for height are done, exit

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x
printLoop:
	ldr	temp, [sAddr]			@ store the screen width in temp
	cmp	inCnt, temp			@ compare counter with width
	bge	finishRow			@ move to next row if current one is done printing
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset for function call
	mov	r1, y				@ move the y value into r1 to pass to function
	ldr	r2, [colour]			@ get value of ascii at address r9		
	bl	DrawPixel			@ print the pixel		

	add	inCnt, #1			@ increment the inner loop counter
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	printLoop			@ go back to print the next pixel in the row

finishRow:
	add	outCnt, #1			@ increment outer loop counter
	ldr	temp, =frameBufferInfo		@ get the frame buffers address and store in temp
	ldr	temp, [temp, #4]		@ get the width of the screen to add to x for next row
	add	x, temp				@ add width of screen 
	b	outerLoop			@ continue back to print the next row of pixels
	
done:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr

/*****************************************
 * prints current lives counter
 * takes no arguments, returns nothing
******************************************/

.global	printLives
printLives:
	push	{lr}

	mov	r0, #192			@x and y set manually
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	ldr	r2, =sprite_lives
	bl	drawSprite			@draw "lives:" sprite

	ldr	r3, =lives
	ldr	r3, [r3]			@get number of lives

	mov	r0, #304
	mov	r1, #448
	rsb	r1, r1, #0
	ldr	r2, =sprite_refs
	add	r2, r3, LSL #2			@find address of correct sprite
	ldr	r2, [r2]
	bl	drawSprite			@print correct sprite

	pop	{lr}
	bx	lr

/*******************************************
 * prints current score counter
 * takes no arguments, returns nothing
*******************************************/

.global	printScore
printScore:
	push	{r4, r5, r6, lr}
	
	temp	.req r4
	offset	.req r5
	score	.req r6

	mov	r0, #224			@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	ldr	r2, =sprite_score
	bl	drawSprite			@draw "score:" sprite

	ldr	r3, =score
	ldr	score, [r3]			@get score

	mov	offset, #0

ps_thousands:
	subs	temp, score, #1000		@test thousands
	movpl	score, temp			@if result >= 0 update score reg
	addpl	offset, #1			@increment offset

	bpl	ps_thousands			@continue testing thousands

	mov	r0, #112			@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	ldr	r2, =sprite_refs
	add	r2, offset, LSL #2		@find address of correct sprite
	ldr	r2, [r2]
	bl	drawSprite			@print correct sprite

	mov offset, #0
	
ps_hundreds:
	subs	temp, score, #100		@test hundreds
	movpl	score, temp			@if result >= 0 update score reg
	addpl	offset, #1			@increment offset

	bpl	ps_hundreds			@continue testing hundreds

	mov	r0, #80				@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	ldr	r2, =sprite_refs
	add	r2, offset, LSL #2		@find address of correct sprite
	ldr	r2, [r2]
	bl	drawSprite			@print correct sprite

	mov offset, #0

ps_tens:
	subs	temp, score, #10		@test tens
	movpl	score, temp			@if result >=0 update score reg
	addpl	offset, #1			@increment offset

	bpl	ps_tens				@continue testing tens

	mov	r0, #48				@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	ldr	r2, =sprite_refs
	add	r2, offset, LSL #2		@find address of correct sprite
	ldr	r2, [r2]
	bl	drawSprite			@print correct sprite

ps_ones:
	mov	r0, #16				@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	ldr	r2, =sprite_refs
	add	r2, score, LSL #2		@only ones remain in score reg
	ldr	r2, [r2]
	bl	drawSprite			@print correct sprite

	.unreq	temp
	.unreq	offset
	.unreq	score
	pop	{r4, r5, r6, lr}
	bx	lr

.global	clearScore
clearScore:
	push	{lr}

	mov	r0, #112			@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	bl	clearSprite

	mov	r0, #80				@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	bl	clearSprite

	mov	r0, #48				@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	bl	clearSprite
	
	mov	r0, #16				@x and y set manually
	rsb	r0, r0, #0			@x is negative
	mov	r1, #448
	rsb	r1, r1, #0			@y is negative
	bl	clearSprite

	pop	{lr}
	bx	lr

/******************************************
 * Purpose: to get the x/y value of an image
 * based on the size of the screen
 *
 * r3 - the address of the image
 * return: r0 - x, r1 - y
 ******************************************/
.global getCoord
getCoord:
	push	{r4, r5, lr}

	ldr	r0, =frameBufferInfo
	ldr	r1, [r0, #4]			@ width
	ldr	r2, [r0, #8]			@ height
	@ load picture dimensions
	@ r3 has the image address
	ldr	r4, [r3]			@ picture width
	ldr	r5, [r3, #4]
	
	lsr	r1, #1				@ divide size in half
	sub	r1, r4, lsr #1			@ subtract the image divided in half
	lsr	r2, #1				@ divide height in half
	sub	r2, r5, lsr #1			@ subtract image height divided in half

	mov	r0, r1				@ move the image x value into r0 to return
	mov	r1, r2				@ move the image y value into r1 to return

	pop	{r4, r5, lr}
	bx	lr

/*******************************************
 *
 *
 * could possibly combine some of these print functions into 1
 * r0 paddle
 *******************************************/
.global	drawPaddle
drawPaddle:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	ldr	sAddr, =paddleImage		@ get the paddle address
	mov	r3, sAddr			@ move the address into r3 for function call

	bl	getPaddleCoord			@ get the coordinates of where to draw the ball relative to the board
	@ return is in r0 - x, r1 - y	

	@ get paddle coordinate realtive to the screen
	add	colour, sAddr, #20 		@ address of first ascii
	mov	x, r0	@ store x		@ save the value of x returned from getCoord
	mov	y, r1	@ store y		@ save the value of y returned from getCoord

	mov	outCnt, #0 			@ height counter
paddleOuterLoop:
	ldr	temp, [sAddr, #12]		@ get the height of the paddle
	cmp	outCnt, temp			@ compare counter with heigth
	bge	paddlePrintDone			@ if the counter reaches the height, terminate

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x
paddlePrintLoop:
	ldr	temp, [sAddr, #8]		@ get the width of the paddle
	cmp	inCnt, temp			@ compare counter with width
	bge	paddleFinishRow			@ if the counter reaches the width, terminate
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset
	mov	r1, y				@ get the y value
	ldr	r2, [colour]			@ get value of ascii in colour
	bl	DrawPixel			@ draw the pixel in the (x,y) location	

	add	inCnt, #1			@ increment the loop counter by 1
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	paddlePrintLoop

paddleFinishRow:
	add	outCnt, #1			@ increment counter
	ldr	temp, =frameBufferInfo		@ get address of frame buffer to get the width value
	ldr	temp, [temp, #4]		@ go to the byte containing the width
	add	x, temp				@ add width of screen 
	b	paddleOuterLoop
	
paddlePrintDone:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr
/*******************************************
 *
 * maybe turn into one function with printPaddle
 *
 * r0 - address of object to clear
 *******************************************/
.global	clearPaddle
clearPaddle:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	ldr	sAddr, =paddleImage		@ get the paddle address
	mov	r3, sAddr			@ move the address into r3 for function call

	bl	getPaddleCoord			@ get the coordinates of where to draw the ball relative to the board
	@ return is in r0 - x, r1 - y	

	@ get paddle coordinate realtive to the screen
	add	colour, sAddr, #20 		@ address of first ascii
	mov	x, r0	@ store x		@ save the value of x returned from getCoord
	mov	y, r1	@ store y		@ save the value of y returned from getCoord

	mov	outCnt, #0 			@ height counter
clearPaddleOuterLoop:
	ldr	temp, [sAddr, #12]		@ get the height of the paddle
	cmp	outCnt, temp			@ compare counter with heigth
	bge	clearPaddlePrintDone		@ if the counter reaches the height, terminate

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x
clearPaddlePrintLoop:
	ldr	temp, [sAddr, #8]		@ get the width of the paddle
	cmp	inCnt, temp			@ compare counter with width
	bge	clearPaddleFinishRow			@ if the counter reaches the width, terminate
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset
	mov	r1, y				@ get the y value
	ldr	r2, =0x3B0275				@ get value of ascii in colour
	bl	DrawPixel			@ draw the pixel in the (x,y) location	

	add	inCnt, #1			@ increment the loop counter by 1
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	clearPaddlePrintLoop

clearPaddleFinishRow:
	add	outCnt, #1			@ increment counter
	ldr	temp, =frameBufferInfo		@ get address of frame buffer to get the width value
	ldr	temp, [temp, #4]		@ go to the byte containing the width
	add	x, temp				@ add width of screen 
	b	clearPaddleOuterLoop
	
clearPaddlePrintDone:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr

/****************************************
 *
 ****************************************/
.global	drawBall
drawBall:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	ldr	sAddr, =ballImage		@ get the ball address
	mov	r3, sAddr			@ move the address into r3 for function call

	bl	getBallCoord			@ get the coordinates of where to draw the ball relative to the board
	@ return is in r0 - x, r1 - y	

	@ get ball coordinate relative to the screen
	add	colour, sAddr, #20 		@ address of first ascii
	mov	x, r0	@ store x		@ save the value of x returned from getCoord
	mov	y, r1	@ store y		@ save the value of y returned from getCoord

	mov	outCnt, #0 			@ height counter

db_OuterLoop:
	ldr	temp, [sAddr, #8]		@ get the diameter of the ball
	cmp	outCnt, temp			@ compare counter with height
	bge	db_PrintDone			@ if the counter reaches the height, terminate

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x

db_PrintLoop:
	ldr	temp, [sAddr, #8]		@ get the diameter of the ball
	cmp	inCnt, temp			@ compare counter with diameter
	bge	db_FinishRow			@ if the counter reaches the width, terminate
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset
	mov	r1, y				@ get the y value
	ldr	r2, [colour]			@ get value of ascii in colour

	mov 	r3, #0xffffffff			@ load colour value to compare
	cmp 	r2, r3				@ if colour is black, don't print
	blne	DrawPixel			@ print the pixel

	add	inCnt, #1			@ increment the loop counter by 1
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	db_PrintLoop

db_FinishRow:
	add	outCnt, #1			@ increment counter
	ldr	temp, =frameBufferInfo		@ get address of frame buffer to get the width value
	ldr	temp, [temp, #4]		@ go to the byte containing the width
	add	x, temp				@ add width of screen 
	b	db_OuterLoop
	
db_PrintDone:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr
/****************************************
 *
 ****************************************/
.global	clearBall
clearBall:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	ldr	sAddr, =ballImage		@ get the ball address
	mov	r3, sAddr			@ move the address into r3 for function call

	bl	getBallCoord			@ get the coordinates of where to draw the ball relative to the board
	@ return is in r0 - x, r1 - y	

	@ get ball coordinate relative to the screen
	add	colour, sAddr, #20 		@ address of first ascii
	mov	x, r0	@ store x		@ save the value of x returned from getCoord
	mov	y, r1	@ store y		@ save the value of y returned from getCoord

	mov	outCnt, #0 			@ height counter

cb_OuterLoop:
	ldr	temp, [sAddr, #8]		@ get the diameter of the ball
	cmp	outCnt, temp			@ compare counter with height
	bge	cb_PrintDone			@ if the counter reaches the height, terminate

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x

cb_PrintLoop:
	ldr	temp, [sAddr, #8]		@ get the diameter of the ball
	cmp	inCnt, temp			@ compare counter with diameter
	bge	cb_FinishRow			@ if the counter reaches the width, terminate
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset
	mov	r1, y				@ get the y value
	ldr	r2, =0x3B0275			@ get value of ascii in colour
	bl	DrawPixel

	add	inCnt, #1			@ increment the loop counter by 1
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	cb_PrintLoop

cb_FinishRow:
	add	outCnt, #1			@ increment counter
	ldr	temp, =frameBufferInfo		@ get address of frame buffer to get the width value
	ldr	temp, [temp, #4]		@ go to the byte containing the width
	add	x, temp				@ add width of screen 
	b	cb_OuterLoop
	
cb_PrintDone:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr
/**************************************************
 * displays a counter sprite
 * r0 = x
 * r1 = y
 * r2 = sprite address
**************************************************/
.global drawSprite
drawSprite:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	mov	sAddr, r2			@ r2 has the address of the image to print, save in sAddr

	mov	r3, r2				@ move the image address into r3 to get coordinates
	bl	getSpriteCoord			@ get the coordinates of the image for printing
	@ return is in r0 - x, r1 - y
	
	add	colour, sAddr, #8 		@ address of first ascii value
	mov	x, r0	@ store x		@ copy the x value into x
	mov	y, r1	@ store y		@ copy the y value into y to save

	mov	outCnt, #0 			@ height counter
ds_outerLoop:
	ldr	temp, [sAddr, #4]		@ store the screen height in temp
	cmp	outCnt, temp			@ compare counter with heigth
	bge	ds_done				@ if the pixels for height are done, exit

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x
ds_printLoop:
	ldr	temp, [sAddr]			@ store the screen width in temp
	cmp	inCnt, temp			@ compare counter with width
	bge	ds_finishRow			@ move to next row if current one is done printing
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset for function call
	mov	r1, y				@ move the y value into r1 to pass to function
	ldr	r2, [colour]			@ get value of ascii at address r9

	mov 	r3, #0xff000000
	cmp 	r2, r3		
	blne	DrawPixel			@ print the pixel		

	add	inCnt, #1			@ increment the inner loop counter
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	ds_printLoop			@ go back to print the next pixel in the row

ds_finishRow:
	add	outCnt, #1			@ increment outer loop counter
	ldr	temp, =frameBufferInfo		@ get the frame buffers address and store in temp
	ldr	temp, [temp, #4]		@ get the width of the screen to add to x for next row
	add	x, temp				@ add width of screen 
	b	ds_outerLoop			@ continue back to print the next row of pixels
	
ds_done:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4, r5, r6, r7, r8, r9, r10, lr}
	bx	lr

/**************************************************
 * clears a counter sprite
 * r0 = x
 * r1 = y
 * r2 = sprite address
**************************************************/
clearSprite:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	ldr	sAddr, =sprite_refs
	ldr	sAddr, [sAddr]

	mov	r3, sAddr				@ move the image address into r3 to get coordinates
	bl	getSpriteCoord			@ get the coordinates of the image for printing
	@ return is in r0 - x, r1 - y

	mov	x, r0	@ store x		@ copy the x value into x
	mov	y, r1	@ store y		@ copy the y value into y to save

	mov	outCnt, #0 			@ height counter
cs_outerLoop:
	ldr	temp, [sAddr, #4]		@ store the screen height in temp
	cmp	outCnt, temp			@ compare counter with heigth
	bge	cs_done				@ if the pixels for height are done, exit

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x
cs_printLoop:
	ldr	temp, [sAddr]			@ store the screen width in temp
	cmp	inCnt, temp			@ compare counter with width
	bge	cs_finishRow			@ move to next row if current one is done printing
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset for function call
	mov	r1, y				@ move the y value into r1 to pass to function
	ldr	r2, =0x3B0275			@ get value of ascii in colour
	bl	DrawPixel

	add	inCnt, #1			@ increment the loop counter by 1
	add 	offset, #1			@ increment offset by 1
	add	colour, #4			@ move to next pixel colour (each is a word)
	b	cs_printLoop

cs_finishRow:
	add	outCnt, #1			@ increment counter
	ldr	temp, =frameBufferInfo		@ get address of frame buffer to get the width value
	ldr	temp, [temp, #4]		@ go to the byte containing the width
	add	x, temp				@ add width of screen 
	b	cs_outerLoop
	
cs_done:	
	.unreq	sAddr
	.unreq	colour
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr


/******************************************
 * Purpose: to get the x/y value of an image
 * based on the size of the screen
 *
 * r3 - the address of the image
 * return: r0 - x, r1 - y
 ******************************************/
.global getPaddleCoord
getPaddleCoord:
	push	{r4, r5, r6, r7, lr}

	ldr	r0, =frameBufferInfo
	ldr	r1, [r0, #4]			@ width
	ldr	r2, [r0, #8]			@ height
	@ load image dimensions
	@ r3 has the image address, maybe change to LDMIA
	ldmia	r3, {r4-r7}			@ r4 - x displacement, r5 - y disp, r6 - paddle width, r7 - paddle height
	
	lsr	r1, #1				@ divide width of screen in half
	sub	r1, r6, lsr #1			@ subtract half the image width
	add	r1, r4				@ add the x displacement to the location
	lsr	r2, #1				@ divide height in half
	add	r2, r7, lsr #1			@ add the image height//2 to the screen height//2
	add	r2, r5				@ add the displacement to the coordinate in r2 (y)
	mov	r0, r1				@ prepare for returning 
	mov	r1, r2				@ prepare for returning

	pop	{r4, r5, r6, r7, lr}
	bx	lr

/******************************************
 * Purpose: to get the x/y value of an image
 * based on the size of the screen
 *
 * r3 - the address of the image
 * return: r0 - x, r1 - y
 ******************************************/
.global	getBallCoord
getBallCoord:
	push	{r4, r5, r6, r7, lr}

	ldr	r0, =frameBufferInfo
	ldr	r1, [r0, #4]			@ width
	ldr	r2, [r0, #8]			@ height
	@ load image dimensions
	@ r3 has the image address, maybe change to LDMIA
	ldmia	r3, {r4-r6}			@ r4 - x displacement, r5 - y disp, r6 - ball diameter
	
	lsr	r1, #1				@ divide width of screen in half
	sub	r1, r6, lsr #1			@ subtract half the image width
	add	r1, r4				@ add the x displacement to the location
	lsr	r2, #1				@ divide height in half
	add	r2, r6, lsr #1			@ add the image height//2 to the screen height//2
	add	r2, r5				@ add the displacement to the coordinate in r2 (y)
	mov	r0, r1				@ prepare for returning 
	mov	r1, r2				@ prepare for returning

	pop	{r4, r5, r6, r7, lr}
	bx	lr

/************************************************
 * gets offset for a counter sprite
 * based on screen dimensions
 * r0 = x
 * r1 = y
 * r3 = sprite address
************************************************/

@ need to see if all of these get coord functions can be combined into one

.global getSpriteCoord
getSpriteCoord:
	push	{r4, r5, r6, r7, lr}

	mov	r4, r0
	mov	r5, r1

	ldr	r0, =frameBufferInfo
	ldr	r1, [r0, #4]			@ width
	ldr	r2, [r0, #8]			@ height
	@ load image dimensions
	@ r3 has the image address, maybe change to LDMIA
	ldmia	r3, {r6, r7}			@ r4 - x displacement, r5 - y disp, r6 - sprite width, r7 - sprite height
	
	lsr	r1, #1				@ divide width of screen in half
	sub	r1, r6, lsr #1			@ subtract half the image width
	add	r1, r4				@ add the x displacement to the location
	lsr	r2, #1				@ divide height in half
	add	r2, r7, lsr #1			@ add the image height//2 to the screen height//2
	add	r2, r5				@ add the displacement to the coordinate in r2 (y)
	mov	r0, r1				@ prepare for returning 
	mov	r1, r2				@ prepare for returning

	pop	{r4, r5, r6, r7, lr}
	bx	lr

/************************************************
 * gets offset for a counter sprite
 * based on screen dimensions
 * r0 = x
 * r1 = y
 * r3 = brick address
************************************************/
.global getBrickCoord
getBrickCoord:
	push	{r4-r5, lr}

	mov	r4, r0
	mov	r5, r1

	ldr	r0, =frameBufferInfo
	ldr	r1, [r0, #4]			@ width
	ldr	r2, [r0, #8]			@ height
	@ load image dimensions
	
	lsr	r1, #1				@ divide width of screen in half
	sub	r1, #384			@ get the edge of the background
	add	r1, r4				@ add the x displacement to the location
	lsr	r2, #1				@ divide height in half
	sub	r2, #448			@ get the top of the background
	add	r2, r5				@ add the displacement to the coordinate in r2 (y)
	mov	r0, r1				@ prepare for returning 
	mov	r1, r2				@ prepare for returning

	pop	{r4-r5, lr}
	bx	lr
/****************************************
 *
 *
 *
 * r0 is the x value for the brick to print
 * r1 is the y value for the brick to print
 * r2 is the integer value for the colour of the brick
 ****************************************/
.global	drawBrick
drawBrick:
	push	{r4-r10, lr}
	
	sAddr	.req	r10
	value	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4
	
	mov	value, r2			@ copy the brick value
	@cmp	value, #0			@ see if the brick has been broken
	@ldreq	sAddr, =purple			@ if so, print the background colour
	cmp	value, #1			@ see if the brick should be green
	ldreq	sAddr, =greenBrick		@ get the address of the green brick to print 
	cmp	value, #2			@ see if the brick should be yellow
	ldreq	sAddr, =yellowBrick		@ get the address for the yellow brick
	cmp	value, #3			@ see if the brick should be red
	ldreq	sAddr, =redBrick		@ get the address for the yellow brick
	@ r0 - x, r1 - y
	bl	getBrickCoord			@ get the coordinates to print the brick
	mov	x, r0				@ copy the x value over
	mov	y, r1				@ copy the y value over
	
	mov	outCnt, #0 			@ height counter
brickOuterLoop:
	mov	temp, #32			@ height of the brick for printing
	cmp	outCnt, temp			@ compare counter with height
	bge	brickPrintDone			@ if the counter reaches the height, terminate

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of x
brickPrintLoop:
	mov	temp, #64			@ width of the brick
	cmp	inCnt, temp			@ compare counter with diameter
	bge	brickFinishRow			@ if the counter reaches the width, terminate
	
	@ call pixel draw
	add	r0, x, offset			@ x + offset
	mov	r1, y				@ get the y value
	cmp	value, #0			@ see if the brick was supposed to be empty
	ldreq	r2, =0x3B0275
	ldrne	r2, [sAddr]			@ get the colour of the pixel
	bl	DrawPixel			@ go print the brick to the screen

	add	inCnt, #1			@ increment the loop counter by 1
	add 	offset, #1			@ increment offset by 1
	add	sAddr, #4			@ move to next pixel colour (each is a word)
	b	brickPrintLoop

brickFinishRow:
	add	outCnt, #1			@ increment counter
	ldr	temp, =frameBufferInfo		@ get address of frame buffer to get the width value
	ldr	temp, [temp, #4]		@ go to the byte containing the width
	add	x, temp				@ add width of screen 
	b	brickOuterLoop
	
brickPrintDone:	
	.unreq	sAddr
	.unreq	value
	.unreq	x
	.unreq	y
	.unreq	outCnt
	.unreq	inCnt
	.unreq	temp
	.unreq	offset
	pop	{r4-r10, lr}
	bx	lr

/****************************************
 *
 *
 *
 * r0 is the brick array
 * 
 ****************************************/
.global	printBricks
printBricks:
	push	{r4-r10, lr}
	
	@ starts at 32, 160
	@ need the brick array
	x	.req	r4			@ the starting y location for printing
	y	.req	r5			@ the starting x location for printing
	inCnt	.req	r6			@ width to add to print the next brick
	outCnt	.req	r7			@ height to add to print the next brick
	offset	.req	r8			@ width offset per row
	array	.req	r9			@ brick value array
	sAddr	.req	r10			@ temporary values
	
	ldr	array, =bricksList		@ copy the brick array into array
	ldr	sAddr, =brickStart		@ get the starting value of x
	ldr	x, [sAddr]			@ get the value of the y starting location
	ldr	y, [sAddr, #4]			@ get the value of x
	
	mov	outCnt, #0 			@ height counter
arrayOuterLoop:
	cmp	outCnt, #3			@ compare counter with height
	bge	arrayPrintDone			@ if the counter reaches the height, terminate

	mov	inCnt, #0 			@ counter
	mov	offset, #0			@ offset of the array
arrayPrintLoop:
	cmp	inCnt, #11			@ compare counter number of bricks per row
	bge	arrayFinishRow			@ if the counter reaches the width, terminate
	
	@ call brick draw
	mov	r0, x				@ move x to call print brick function
	mov	r1, y				@ move y to call print brick function
	ldr	r2, [array]			@ get the next array value for brick strength
	@r0 - x coordinate, r1 - y coordinate, r2 - brick colour value
	bl	drawBrick			@ go print the brick to the screen

	add	inCnt, #1			@ increment the loop counter by 1
	add 	array, #4			@ increment offset by 1 for the brick array (bytes)
	add	x, #64				@ move x forward to the next brick location
	b	arrayPrintLoop

arrayFinishRow:
	add	outCnt, #1			@ increment counter
	ldr	x, [sAddr]			@ reset x to start next row
	add	y, #32				@ move the y location up one row
	b	arrayOuterLoop
	
arrayPrintDone:	

	pop	{r4-r10, lr}
	bx	lr

.end
