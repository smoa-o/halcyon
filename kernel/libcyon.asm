[bits 32]

section .text

global usermain
usermain:
	mov eax, 0
	mov ecx, .done
	mov edx, esp
	sysenter
.done:
	ret
