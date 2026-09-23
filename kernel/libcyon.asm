[bits 32]

section .text
global Halt

; void Halt(void);
Halt:
	hlt
	jmp $
