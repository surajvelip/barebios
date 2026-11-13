; serial.inc - 16550 UART (COM1) routines, shared by boot sector and stage 2.
; Uses I/O port COM1 (0x3F8). Polls only: no interrupts, no FIFO.

%define COM1 0x3F8

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

; serial_getc: block until a byte arrives, return it in AL.
serial_getc:
    push dx
.wait:
    mov dx, COM1+5          ; LSR
    in  al, dx
    test al, 0x01           ; data ready?
    jz  .wait
    mov dx, COM1+0          ; RBR
    in  al, dx
    pop dx
    ret

; serial_puts: write NUL-terminated string at DS:SI to COM1.
serial_puts:
    push ax
    push si
.next:
    lodsb
    or  al, al
    jz  .done
    call serial_putc
    jmp .next
.done:
    pop si
    pop ax
    ret
