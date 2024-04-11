/*
 * convolve.s
 *
 *  Created on: 29/01/2023
 *      Author: Hou Linxin
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global convolve

@ Start of executable code
.section .text

@ CG2028 Assignment 1, Sem 2, AY 2023/24
@ (c) ECE NUS, 2024

@ Write Student 1’s Name here: Oh Ken Wei
@ Write Student 2’s Name here: Heng Junxiang

@ You could create a look-up table of registers here:

@ R0 Address of h
@ R1 Address of x
@ R2 hlen
@ R3 xlen

@ R4 nConv = length of output array y
@ R5 y[i]
@ R6 index if loop 1 i
@ R7 x_start
@ R8 lenX --> x_end
@ R9 lenH --> h_start
@ R10 index of 2nd loop j
@ R11 Address of h
@ R13 Address of X

@ write your program from here:
convolve:
	PUSH {R14}

	@ Calculate and store nconv
	ADD R4, R2, R3
	SUB R4, #1

	@ move values to be used in loops
	MOV R8, R3
	MOV R9, R2
	MOV R11, R0
	MOV R13, R1

	@ initialise loop1
	MOV R6, #0

	@ Convolve
	BL LOOP1

	@ Pop address to main
	POP {R14}

	@ output Y
	LDR R0, =Y
	BX LR

LOOP1:
	PUSH {R14}

	@ temporarily store lenH in R2
	MOV R2, R9

	@ calc h_start
	SUB R9, #1
	CMP R9, R8
	IT LT
	MOV R9, R8

	@ calc x_end
	@ temporarily store i + 1 in R3
	ADD R3, R6, #1
	CMP R8, R3
	IT LT
	MOV R8, R3

	@ calc x_start
	SUBS R7, R2, R12
	IT MI
	MOV R7, #0

	@ initialize 2nd loop
	MOV R7, R10
	MOV R5, #0

	BL LOOP2

	@ store value of y[i] from R5 that we got from loop2
	STR R5, [Y, R6]

	@ Loop logic
	ADD R6, #1
	CMP R6, R4
	BLT LOOP1

	POP {R14}
	BX LR

LOOP2:
	@ R0 = h[h_start--]
	LDR R0, [R11, R9]
	SUB R9, #1

	@ R1 = x[j]
	LDR R1, [R10]

	@ Update y[i]
	MLA R5, R0, R1, R5

	@ loop logic
	ADD R10, #1

	CMP R10, R8
	BLT LOOP2

	BX LR


@ initialize output array, max size 20 words
@ Since max size of lenX and lenH is 10
.lcomm Y 80
