START:
	MOV BX, 00	; Initialize main data register.
	MOV DX, 10h	; Shifting multiplier.
INP:
	MOV AH, 01	
	INT 21h		; Reads input and stores at AL.

	CMP AL, 20h	; If input is whitespace, process stack.
	JE PUSH_STACK_B
	CMP AL, 0ah	; If input is LF, print value on stack.
	JE FINISH_B
	CMP AL, 0Dh	; If input is CR, print value on stack.
	JE FINISH_B
			; If inputis an operand, differentiate and goto necessary label.
	CMP AL, 26h
	JE AMPERSAND
	CMP AL, 2Ah
	JE MULTIPLY
	CMP AL, 2Bh
	JE ADDITION
	CMP AL, 2Fh
	JE DIVISION
	CMP AL, 5Eh
	JE BXOR
	CMP AL, 7Ch
	JE BOR

	CMP AL, 40h	; If input is a numeric value, differentiate between letter an digit.
	JA LETTER
	JMP DIGIT
DIGIT:
	SUB AL, 30h	; Convert to real value from ASCII.
	MOV DX, 10h
	JMP CONCAT
LETTER:
	SUB AL, 37h	; Convert to real value from ASCII.
	MOV DX, 10h
	JMP CONCAT
CONCAT:			; Concatenates hexadecimal numbers.
	MOV CL, AL
	MOV AX, BX
	MUL DX		; Result stored in DX:AX.
	ADD AL, CL
	MOV BX, AX	; Data stored in BX.
	JMP INP
AMPERSAND:		; Binary AND operation.
	POP BX
	POP CX
	AND BX, CX
	MOV CX ,BX
	JMP INP
FINISH_B:		; Label to prevent (jump > 128) error.
	JMP FINISH
BOR:			; Binary OR operation
	POP BX
	POP CX
	OR BX, CX
	MOV CX, BX
	JMP INP
BXOR:			; Binary XOR operation
	POP BX
	POP CX
	XOR BX, CX
	MOV CX, BX
	JMP INP
DIVISION:		; Binary division operation
	POP BX
	POP CX
	MOV DX, 00	; Pay attention to DX, s,nce DX:AX is divident.
	MOV AX, CX
	DIV BX		; Quotient stored in AX
	MOV BX, AX
	MOV DX ,00	; Clear remainder stored in DX.
	MOV CX, BX
	JMP INP
PUSH_STACK_B:		; Label to prevent (jump > 128) error.
	JMP PUSH_STACK
ADDITION:		; Binary addition operation.
	POP BX
	POP CX
	ADD BX, CX
	MOV CX, BX
	JMP INP
MULTIPLY:		; Binary multiplication operation.
	POP BX
	POP CX
	MOV AX, BX
	MUL CX		; Result stored in DX:AX.
	MOV BX, AX
	MOV CX, BX
	JMP INP
PUSH_STACK:
	PUSH BX		; Push data stored in register BX to the stack.
	MOV CX, BX	; Data copied to CX, used in case data in BX got deleted by some input combination
	MOV BX, 00	; Data register refreshed to get next value.
	JMP INP
FINISH:
	MOV DX, 00	; Refresh DX to join division operation
	CMP BX, 00	; If data stored in BX is cleared, print data stored in CX instead of stack.
	JE EQUAL
	JMP CONVERSION
EQUAL:
	MOV BX, CX
	JMP CONVERSION
CONVERSION		; Converts hexadecimal number to printable characters.
	MOV AX, BX
	MOV CX, 10h
	DIV CX		; Remainder in DX, Quotient in AX.
	PUSH DX
	DIV CX
	PUSH DX
	DIV CX
	PUSH DX
	DIV CX
	PUSH DX
	MOV AX, 00
	MOV BX, 00
	MOV CX, 00
	MOV DX, 00
	MOV DL, 0Dh	; CR character printed to stdout.
	MOV AH, 02
	INT 21h
	MOV DL, 0Ah	; LF character printed to stdout.
	MOV AH, 02
	INT 21h 
	JMP PRINTER
PRINTER:		; Checks if hexadecimal digit is represented by a digit(0-9) or a letter(A-F).
	CMP CL, 4	; Prevents printing more than four character with counter register CL.
	JE EXIT
	INC CL
	POP BX
	CMP BX, 9
	JA PRINT_LETTER
	JMP PRINT_DIGIT
PRINT_LETTER:		; Converts hexadecimal digit to a printable character and prints it.
	ADD BX, 37h
	MOV DL, BL
	INT 21h
	JMP PRINTER
PRINT_DIGIT:		; Converts hexadecimal digit to printable character.
	ADD BX, 30h
	MOV DL, BL
	INT 21h
	JMP PRINTER
EXIT:			; Exits program and returns to OS.
	MOV AH, 4Ch
	MOV AL, 0
	INT 21h




