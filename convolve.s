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

@ R0 Address of h --> Address of Y
@ R1 Address of x
@ R2 lenH
@ R3 lenX

@ R4 nConv = length of output array y
@ R5 y[i]
@ R6 index if loop 1 i
@ R7 x_start --> index j
@ R8 lenX --> x_end
@ R9 lenH --> h_start
@ R10 Address of X
@ R11 Address of h
@ R12 index j

@ write your program from here:
convolve:
    PUSH {R4, R5, R6, R7, R8, R9, R10, R11, R14}

    @ Calculate and store nconv
    ADD R4, R2, R3
    SUB R4, #1

    @ move values to be used in loops
    MOV R8, R3
    MOV R9, R2
    MOV R11, R0
    MOV R10, R1

    @ initialise loop1
    MOV R6, #0

    LDR R0, =Y

    @ Convolve
    BL LOOP1

    LDR R0, =Y

    @ Pop address to main
    POP {R4, R5, R6, R7, R8, R9, R10, R11, R14}

    BX LR

LOOP1:
    PUSH {R4, R6, R8, R9, R14}

    @ temporarily store lenH in R2
    MOV R2, R9

    @ x_start = MAX(0,i-lenH+1);
    @ x_end   = MIN(i+1,lenX);
    @ h_start = MIN(i,lenH-1);

    @ calc h_start
    SUB R9, #1
    CMP R9, R6
    IT HS
    MOVHS R9, R6

    @ calc x_end
    @ temporarily store i + 1 in R3
    ADD R3, R6, #1
    CMP R8, R3
    IT HS
    MOVHS R8, R3

    @ calc x_start
    SUBS R7, R3, R2
    IT MI
    MOVMI R7, #0

    @ initialize 2nd loop
    MOV R12, R7
    MOV R5, #0

    BL LOOP2

    @ store value of y[i] from R5 that we got from loop2
    STR R5, [R0], #4

    @ restore values
    POP {R4, R6, R8, R9, R14}

    @ Loop logic
    ADD R6, #1
    CMP R6, R4
    BLT LOOP1

    BX LR

LOOP2:
    @ R8 = h[h_start--]
    LSL R9, R9, #2
    LDR R4, [R11, R9]
    LSR R9, R9, #2
    SUB R9, #1

    @ R6 = x[j]
    LSL R12, R12, #2
    LDR R6, [R10, R12]
    LSR R12, R12, #2

    @ Update y[i]
    MLA R5, R6, R4, R5

    @ loop logic
    ADD R12, #1
    CMP R12, R8
    BLT LOOP2

    BX LR


@ initialize output array, max size 20 words
@ Since max size of lenX and lenH is 10
.lcomm Y 80
