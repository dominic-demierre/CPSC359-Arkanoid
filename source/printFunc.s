
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
	pop	{r4, r5, r6, r7, r8, r9, r10, lr}
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
 *
 *
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

	mov 	r3, #0xffffff
	cmp 	r2, r3
	blne	DrawPixel

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


/*------------------- VARIABLES --------------------*/
.sect	.data

	

.end

3