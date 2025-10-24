INCLUDE \masm615\Programs\PCMAC.inc 

.MODEL SMALL
.586
.STACK 100h

.DATA
TodayMsg DB 'Today is $'

.CODE
EXTRN PutDec:NEAR

MyDate PROC
    _Begin

    _PutStr TodayMsg

    _GetDate 

    mov bl, dl 
    push cx 

    mov al, dh
    mov ah, 0 
    call PutDec

    _PutCh '/'

    mov al, bl
    mov ah, 0
    call PutDec

    _PutCh '/'

    pop ax 
    call PutDec 

    _PutCh 13, 10

    _Exit 0 
    
MyDate ENDP
END MyDate