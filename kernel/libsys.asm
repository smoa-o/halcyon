[bits 32]

section .text

global Halt
Halt:
	hlt
	ret

global GetErrorCode
GetErrorCode:
	mov ax, [0x701]
	mov [0x700], ax
	mov eax, 0xffff
	ret
