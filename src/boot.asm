; biossom - a minimal, readable BIOS
; boot sector: loaded at 0000:7C00 by the BIOS, 512 bytes, ends in 0xAA55.
; Milestone 1: print "biossom" to VGA (int 10h) and serial (COM1).

BITS 16
ORG 0x7C00

%define COM1 0x3F8

start:
    cli                     ; no interrupts while we set up segments/stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; stack grows down from just below our code
    sti

    call serial_init

    mov si, msg
.print:
    lodsb                   ; al = [si], si++
    or  al, al
    jz  .done
    mov ah, 0x0E            ; BIOS teletype output (VGA)
    xor bx, bx              ; page 0
    int 0x10
    call serial_putc        ; same char on COM1
    jmp .print
.done:

halt:
    hlt
    jmp halt

; serial_init: set COM1 to 38400 8N1, no FIFO, no IRQs.
serial_init:
    mov dx, COM1+1          ; IER: disable all interrupts
    xor al, al
    out dx, al
    mov dx, COM1+3          ; LCR: set DLAB
    mov al, 0x80
    out dx, al
    mov dx, COM1+0          ; divisor low = 3 (38400 baud)
    mov al, 0x03
    out dx, al
    mov dx, COM1+1          ; divisor high = 0
    xor al, al
    out dx, al
    mov dx, COM1+3          ; LCR: 8 data bits, 1 stop, no parity, DLAB off
    mov al, 0x03
    out dx, al
    mov dx, COM1+2          ; FCR: no FIFO
    xor al, al
    out dx, al
    mov dx, COM1+4          ; MCR: DTR+RTS on
    mov al, 0x03
    out dx, al
    ret

; serial_putc: write AL to COM1, waiting for transmit-empty.
serial_putc:
    push ax
    push dx
.wait:
    mov dx, COM1+5          ; LSR
    in  al, dx
    test al, 0x20           ; THR empty?
    jz  .wait
    pop dx
    pop ax
    mov dx, COM1+0          ; THR
    out dx, al
    ret

msg db "biossom", 13, 10, 0

    times 510-($-$$) db 0
    dw 0xAA55               ; boot signature
