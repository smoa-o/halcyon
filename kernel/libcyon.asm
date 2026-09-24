[bits 32]

section .text

global usermain
usermain:
	xor eax, eax
	xor ebx, ebx
	mov ecx, .done
	mov edx, esp
	sysenter
.done:
	ret
