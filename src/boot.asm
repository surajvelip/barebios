; barebios - a minimal, readable BIOS
; boot sector: loaded at 0000:7C00, 512 bytes, ends in 0xAA55.
; Prints a banner, loads stage 2 from disk via int 13h, jumps to it.

BITS 16
ORG 0x7C00

%define STAGE2_SECTORS 4    ; sectors to load after the boot sector
%define STAGE2_ADDR    0x7E00  ; first free memory after the boot sector

start:
    cli                     ; no interrupts while we set up segments/stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; stack grows down from just below our code
    sti

    mov [boot_drive], dl    ; BIOS tells us the boot drive in DL

    call serial_init

    mov si, msg
.print:
    lodsb
    or  al, al
    jz  .loaded_msg
    mov ah, 0x0E            ; BIOS teletype output (VGA)
    xor bx, bx
    int 0x10
    call serial_putc        ; same char on COM1
    jmp .print
.loaded_msg:

    ; int 13h AH=02h: read STAGE2_SECTORS sectors starting at sector 2
    ; (sector 1 is this boot sector) into ES:BX = 0000:7E00.
    mov ah, 0x02
    mov al, STAGE2_SECTORS
    mov ch, 0               ; cylinder 0
    mov cl, 2               ; sector 2 (sectors are 1-based)
    mov dh, 0               ; head 0
    mov dl, [boot_drive]
    mov bx, STAGE2_ADDR     ; ES already 0
    int 0x13
    jc  disk_error

    jmp STAGE2_ADDR         ; hand off to stage 2

disk_error:
    mov si, errmsg
.errprint:
    lodsb
    or  al, al
    jz  halt
    mov ah, 0x0E
    xor bx, bx
    int 0x10
    call serial_putc
    jmp .errprint

halt:
    hlt
    jmp halt

%include "serial.inc"

msg        db "barebios", 13, 10, 0
errmsg     db "disk read failed", 13, 10, 0
boot_drive db 0

    times 510-($-$$) db 0
    dw 0xAA55               ; boot signature
