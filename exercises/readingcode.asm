READING CODE - STACK
;list the output of the following program assuming the input is as follows:
101
232
48
17

include PCMAC.INC
NEWLINE EQU _PutCh 13, 10

 .MODEL SMALL
 .STACK 100h
 .DATA
Message1 DB 'Total sold today,  $'
Message2 DB ' , is: $'


 .CODE
        EXTERN GetDec: NEAR, PutDec:NEAR
Main PROC
        mov ax, @data
        mov     ds, ax
	_GetDate
	push cx
	push dx
	push dx
	call SubInput ;send control to subprocedure
	mov bx, ax
	_PutStr Message1        
	pop dx
	mov al, dh
	mov ah, 0
	call PutDec
	_PutCh '/'
	pop dx	
	mov al, dl
	mov ah, 0
	call PutDec
	_PutCh '/'
	pop cx
	mov ax, cx
	call PutDec
	_PutStr Message2
	mov ax, bx
	call PutDec
	NEWLINE	
	
  mov al, 0 ;  Return code of 0
  mov ah, 4ch ; Exit back to MSDOS
  int 21h
Main ENDP

.Data      ;  re-enter the data segment for this procedure

MessageSub     DB 'Enter a number $'
Mystery      DW ?

.CODE  ; return to coding

SubInput PROC 
	mov cx, 4
myLoop:
	 _PutStr MessageSub
	call GetDec
	add Mystery, ax
	dec cx
	jnz myLoop
	mov ax, Mystery
	 ret

SubInput  ENDP

 END Main ; Tells where to start execution
