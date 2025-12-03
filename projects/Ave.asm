;---------------------------------------------------------------
; File Name: Ave.asm
; Written by: Marc Yebra
;
; Challenges:
; - Figuring out how to handle input and output using DOS interrupts (INT 21h)
; - Writing my own routine to convert the user’s ASCII input into actual numbers
; - Making sure the program didn’t crash from dividing by zero when no numbers were entered
; - Getting the output to display neatly by adding the right carriage return
;   and line feed bytes in the right spots
; - Troubleshooting issues in DOSBox, especially with file paths and linking
;   before everything finally assembled and ran correctly
;
; Time Spent: 5 hours to write, about 10 hours total including reviewing chapter material and planning
;
; Revision History
; ------------------------------------------------------------------------------------
; Date      | Revised By | Action
; ------------------------------------------------------------------------------------
; 11/25/25  | MY | Started drafting program on paper first and studied chapters
; 11/30/25  | MY | Created AVE.asm file
; 12/02/25  | MY | Added newline formatting so each prompt appears on its own line
; 12/02/25  | MY | Finalized code and compiled it through CMD and DOSBOX to prove it works
;---------------------------------------------------------------

.MODEL SMALL
.STACK 100h

.DATA
introMsg    DB "This program averages the positive integers you enter.",13,10
            DB "Type a positive number and press <Enter> each time.",13,10
            DB "Type 'q' or any letter to stop and see the average.",13,10,13,10,'$'

promptMsg   DB 13,10,"Enter a number (or 'q' to quit): $"
posMsg      DB 13,10,"Please enter a POSITIVE, NON-ZERO integer.",13,10,'$'
noNumMsg    DB 13,10,"No numbers were entered. Nothing to average.",13,10,'$'
resultMsg   DB 13,10,"The average of your numbers is: $"
newline     DB 13,10,'$'

INBUFLEN    EQU 10
inputBuf    DB INBUFLEN           ; max chars user may type
            DB 0                  ; actual count will be stored here
            DB INBUFLEN DUP(?)    ; the characters themselves

sum         DW 0
count       DW 0
average     DW 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; show instructions
    MOV DX, OFFSET introMsg
    MOV AH, 9
    INT 21h

input_loop:
    ; print prompt
    MOV DX, OFFSET promptMsg
    MOV AH, 9
    INT 21h

    ; read a line of input
    MOV DX, OFFSET inputBuf
    MOV AH, 0Ah
    INT 21h

    ; get first character typed
    MOV AL, [inputBuf+2]

    ; if user just pressed Enter, treat as quit
    CMP BYTE PTR [inputBuf+1], 0
    JE calculate_average

    ; quit if 'q' or 'Q'
    CMP AL, 'q'
    JE calculate_average
    CMP AL, 'Q'
    JE calculate_average

    ; if first char is not a digit, also quit
    CMP AL, '0'
    JB calculate_average
    CMP AL, '9'
    JA calculate_average

    ; first char is a digit: convert whole string to number in AX
    CALL str_to_num

    ; enforce positive, non-zero
    CMP AX, 0
    JLE not_positive

    ; add to sum and increment count
    ADD sum, AX
    INC count
    JMP input_loop

not_positive:
    MOV DX, OFFSET posMsg
    MOV AH, 9
    INT 21h
    JMP input_loop

;------------------------------------------
; Display average when quitting
;------------------------------------------
calculate_average:
    CMP count, 0
    JE no_numbers_entered

    MOV AX, sum
    MOV BX, count
    XOR DX, DX
    DIV BX
    MOV average, AX

    ; print result message
    MOV DX, OFFSET resultMsg
    MOV AH, 9
    INT 21h

    ; print average
    MOV AX, average
    CALL print_num

    ; newline
    MOV DX, OFFSET newline
    MOV AH, 9
    INT 21h
    JMP done

no_numbers_entered:
    MOV DX, OFFSET noNumMsg
    MOV AH, 9
    INT 21h

done:
    MOV AH, 4Ch        ; exit to DOS
    INT 21h
MAIN ENDP

;------------------------------------------
; Converts ASCII string in inputBuf to number in AX
;------------------------------------------
str_to_num PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX          ; BX = accumulator = 0
    LEA SI, inputBuf+2  ; point to first character

convert_loop:
    LODSB               ; AL = [SI], SI++
    CMP AL, 13          ; carriage return (Enter)?
    JE convert_done

    ; stop if not a digit
    CMP AL, '0'
    JB convert_done
    CMP AL, '9'
    JA convert_done

    SUB AL, '0'         ; make it 0–9
    MOV CL, AL          ; CL = digit
    MOV AX, BX          ; AX = current value
    MOV DX, 10
    MUL DX              ; AX = AX * 10
    ADD AX, CX          ; add digit
    MOV BX, AX          ; store back in BX
    JMP convert_loop

convert_done:
    MOV AX, BX          ; final value in AX
    POP DX
    POP CX
    POP BX
    RET
str_to_num ENDP

;------------------------------------------
; Prints integer in AX using DOS interrupt
;------------------------------------------
print_num PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JNE pn_not_zero

    ; special case: print '0'
    MOV DL, '0'
    MOV AH, 2
    INT 21h
    JMP pn_done

pn_not_zero:
    XOR CX, CX          ; digit count = 0

pn_div_loop:
    XOR DX, DX
    MOV BX, 10
    DIV BX              ; AX = AX/10, DX = remainder (0–9)
    PUSH DX             ; save remainder
    INC CX              ; count a digit
    CMP AX, 0
    JNE pn_div_loop

pn_print_loop:
    POP DX
    ADD DL, '0'         ; convert 0–9 to ASCII
    MOV AH, 2
    INT 21h             ; print character in DL
    LOOP pn_print_loop

pn_done:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_num ENDP

END MAIN
