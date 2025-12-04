; File Name: equation.asm
; Written by: Marc Yebra
; Challenges: I struggled with implementing user input in a DOS enviornment. Debugging the readnum to correctly 
; handle multiple digit input. I kept runnig into an issue where, no matter what I typed in, the result always
; came back as "A=807" because if uninitialized registers. And lastly, just confirming the operator precedence for 
; A = B * 3 + 6 / (X + D).
; Time Spent: Roughly 10 - 12 hours
; Revision History
; Date:       Revised By:  Actions:
; -------------------------------------------------------------------------------
; 11/07/25    MY           Initially started working on assingment 
; 11/10/25    MY           Finalized assignment without BONUS input section
; 11/11/25    MY           Refactored to include BONUS assignment with user input
; 11/11/25    MY           Fixed the ReadNum to process multi-digit inputs
; 11/11/25    MY           Verified correct output in DOSBOX

.MODEL  SMALL
.STACK  100h

.DATA
PROMPTB    DB 13, 10, 'Enter value for B: $'
PROMPTX    DB 13, 10, 'Enter value for X: $'
PROMPTD    DB 13, 10, 'Enter value for D: $'
RESULTMSG  DB 13, 10, 'The value of A is: $'

B          DW ?
X          DW ?
D          DW ?
A          DW ?

.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Input B
    MOV DX, OFFSET PROMPTB
    MOV AH, 9
    INT 21h
    CALL READNUM
    MOV B, AX

    ; Input X
    MOV DX, OFFSET PROMPTX
    MOV AH, 9
    INT 21h
    CALL READNUM
    MOV X, AX

    ; Input D
    MOV DX, OFFSET PROMPTD
    MOV AH, 9
    INT 21h
    CALL READNUM
    MOV D, AX

    ; A = B * 3 + 6 / (X + D)
    MOV AX, B
    MOV BX, 3
    IMUL BX
    MOV CX, AX          ; CX = B * 3

    MOV AX, X
    ADD AX, D           ; AX = X + D
    MOV BX, AX          ; BX = X + D

    MOV AX, 6
    CWD                 ; sign-extend into DX:AX
    IDIV BX             ; AX = 6 / (X + D)

    ADD AX, CX          ; AX = B * 3 + 6 / (X + D)
    MOV A, AX

    ; Final output
    MOV DX, OFFSET RESULTMSG
    MOV AH, 9
    INT 21h

    MOV AX, A
    CALL PRINTAX

    MOV AH, 4Ch
    INT 21h
MAIN ENDP


READNUM PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX          ; BX will accumulate the number

READLOOP:
    MOV AH, 1
    INT 21h             ; read char into AL

    CMP AL, 13          ; Enter?
    JE  DONE

    CMP AL, '0'
    JB  READLOOP        ; ignore if < '0'
    CMP AL, '9'
    JA  READLOOP        ; ignore if > '9'

    SUB AL, '0'         ; convert ASCII to digit
    MOV AH, 0

    MOV CX, 10
    PUSH AX             ; save digit
    MOV AX, BX
    MUL CX              ; AX = BX * 10
    POP CX              ; CX = digit
    ADD AX, CX          ; AX = BX * 10 + digit
    MOV BX, AX          ; BX = new value

    JMP READLOOP

DONE:
    MOV AX, BX          ; return value in AX

    POP DX
    POP CX
    POP BX
    RET
READNUM ENDP


PRINTAX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10
    XOR CX, CX          ; digit count = 0

CONVLOOP:
    XOR DX, DX
    DIV BX              ; AX / 10, remainder in DX
    PUSH DX             ; save remainder (digit)
    INC CX              ; increment digit count
    CMP AX, 0
    JNE CONVLOOP

PRINTLOOP:
    POP DX
    ADD DL, '0'         ; convert to ASCII
    MOV AH, 2
    INT 21h
    LOOP PRINTLOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINTAX ENDP

END MAIN

