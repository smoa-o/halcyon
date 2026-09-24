[bits 32]

%include "sys/basic.asm"

%if 0
%include "sys/device.asm"
%endif

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

%if 0
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
%endif
