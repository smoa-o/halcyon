[bits 32]

%include "sys/basic.asm"
%include "sys/device.asm"

section .text

Basic:
	cmp ebx, 1
	ja .invalid

	mov ebp, [.jumptable + ebx * 4]
	call ebp

	ret
.invalid:
	mov byte [0x700], 0x01 ; BADNUM
	mov eax, 0xffff
	ret
.jumptable:
	dd Halt
	dd GetErrorCode

Device:
	cmp ebx, 4
	ja .invalid

	mov ebp, [.jumptable + ebx * 4]
	call ebp

	ret
.invalid:
	mov byte [0x700], 0x01
	mov eax, 0xffff
	ret
.jumptable:
	dd CreateDevStream
	dd CreateDevBridge
	dd UpdateDevBridge
	dd UpdateDevStream
	dd DeleteDevStream
	dd DeleteDevBridge
