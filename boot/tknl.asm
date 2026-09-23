[bits 16]
section tknl vstart=0x7e00

tkmain:
    cli
    mov bp, 0x8000
    mov sp, bp
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call st_a20
    call st_gdt
    call st_pm

    hlt
    jmp $

; ============================================================
; A20: Fast Gate via keyboard controller
; ============================================================
st_a20:
    call .wait1
    mov al, 0xad
    out 0x64, al          ; disable keyboard

    call .wait1
    mov al, 0xd0
    out 0x64, al          ; read output port

    call .wait2
    in al, 0x60
    or al, 2
    push ax

    call .wait1
    mov al, 0xd1
    out 0x64, al          ; write output port

    call .wait1
    pop ax
    out 0x60, al          ; set A20 bit

    call .wait1
    mov al, 0xae
    out 0x64, al          ; re-enable keyboard
    ret

.wait1:
    in al, 0x64
    test al, 1
    jnz .wait1
    ret

.wait2:
    in al, 0x64
    test al, 1
    jz .wait2
    ret

; ============================================================
; GDT
; ============================================================
st_gdt:
    lgdt [GdtDescriptor]
    ret

; ============================================================
; Enter protected mode and jump to 32-bit code
; ============================================================
st_pm:
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_start

; ---- GDT table ----
align 4
GdtStart:
    dq 0x0000000000000000          ; null
    dq 0x00cf9a000000ffff          ; code (base=0, limit=4GB, DPL=0, executable)
    dq 0x00cf92000000ffff          ; data (base=0, limit=4GB, DPL=0, writable)
GdtEnd:

GdtDescriptor:
    dw GdtEnd - GdtStart - 1
    dd GdtStart

; ============================================================
; 32-bit protected mode
; ============================================================
[bits 32]
pm_start:
    ; Set up data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; ---- ATA PIO Read: load 1 sector from LBA 0 into 0x100000 ----
    call ata_read

    ; Jump to loaded kernel
    jmp 0x08:0x100000

; ============================================================
; ata_read: reads 1 sector (512 bytes) from LBA 0 to EDI
; EDI must be set before calling
; ============================================================
ata_read:
    pushad

    ; Select master, LBA mode
    mov dx, 0x1f6
    mov al, 0xe0
    out dx, al

    ; Wait for BSY=0
    mov dx, 0x1f7
.bsy_loop:
    in al, dx
    test al, 0x80
    jnz .bsy_loop

    ; Wait for DRDY=1
    in al, dx
    test al, 0x40
    jz .bsy_loop

    ; Sector count = 1
    mov dx, 0x1f2
    mov al, 1
    out dx, al

    ; LBA 0 (low, mid, high)
    xor al, al
    inc dx              ; 0x1f3
    out dx, al          ; LBA 0-7 = 0
    inc dx              ; 0x1f4
    out dx, al          ; LBA 8-15 = 0
    inc dx              ; 0x1f5
    out dx, al          ; LBA 16-23 = 0

    ; Drive/head = master, LBA, high nibble = 0
    inc dx              ; 0x1f6
    mov al, 0xe0
    out dx, al

    ; Send READ SECTORS command
    inc dx              ; 0x1f7
    mov al, 0x20
    out dx, al

    ; Wait for BSY=0 and DRQ=1
.drq_loop:
    in al, dx
    test al, 0x80       ; BSY?
    jnz .drq_loop
    test al, 0x08       ; DRQ?
    jz .drq_loop

    ; Read 256 words (512 bytes) from data port
    mov dx, 0x1f0
    mov edi, 0x100000
    mov ecx, 256
    rep insw

    popad
    ret

