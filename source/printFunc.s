/******************************************
 * Practice writing pixels
 *
 *
 ******************************************/

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

	ldr	r5, =frameBufferInfo

	@ offset = (y * width) + x
	ldr	r3, [r5, #4]		@ r3 is the screen width
	mul	r1, r3
	add	offset, r0, r1		@ r4 is the offset computed

	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl	offset, #2

	ldr	r0, [r5]
	str	r2, [r0, offset]

	pop	{r4, r5, lr}
	bx	lr

/******************************************
 * Purpose: to print an image
 * r0 - x
 * r1 - y
 *
 * find way to make this a general function
 * for printing any background
 *
 ******************************************/
.global printBackground
printBackground:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	sAddr	.req	r10
	colour	.req	r9
	x	.req	r5
	y	.req	r6
	outCnt	.req	r7
	inCnt	.req	r8
	temp	.req	r3
	offset	.req	r4

	ldr	sAddr, =gameBackground
	add	colour, sAddr, #8 	@ address of first ascii
	mov	x, r0	@ store x
	mov	y, r1	@ store y

	mov	outCnt, #0 		@ height counter
outerLoop:
	ldr	temp, [sAddr, #4]
	cmp	outCnt, temp		@ compare counter with heigth
	@cmp	outCnt, #15
	bge	done

	mov	inCnt, #0 		@ counter
	mov	offset, #0		@ offset of x
printLoop:
	ldr	temp, [sAddr]
	cmp	inCnt, temp	@ compare counter with width
	@cmp	inCnt, #30
	bge	finishRow
	
	@ call pixel draw
	add	r0, x, offset	@ x + offset
	mov	r1, y
	ldr	r2, [colour]	@ get value of ascii at address r9
	@mov	r2, #0
	bl	DrawPixel		

	add	inCnt, #1
	add 	offset, #1			@ increment offset by 1
	add	colour, #4		@ move to next pixel colour (each is a word)
	b	printLoop

finishRow:
	add	outCnt, #1		@ increment counter
	ldr	temp, =frameBufferInfo
	ldr	temp, [temp, #4]
	add	x, temp		@ add width of screen 
	b	outerLoop
	
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
 * r0 - x
 * r1 - y
 * return: r0 - x, r1 - y
 ******************************************/
.global getCoord
getCoord:
	push	{r4, r5, lr}

	ldr	r0, =frameBufferInfo
	ldr	r1, [r0, #4]			@ width
	ldr	r2, [r0, #8]			@ height
	@ load picture dimensions
	ldr	r3, =gameBackground
	ldr	r4, [r3]			@ picture width
	ldr	r5, [r3, #4]
	
	lsr	r1, #1				@ divide size in half
	sub	r1, r4, lsr #1			@ subtract the image divided in half
	lsr	r2, #1				@ divide height in half
	sub	r2, r5, lsr #1			@ subtract image height divided in half

	mov	r0, r1
	mov	r1, r2	

	pop	{r4, r5, lr}
	bx	lr

.sect	.data


.end

