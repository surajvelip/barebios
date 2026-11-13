; biome - a minimal, readable BIOS
; boot sector: loaded at 0000:7C00 by the BIOS, 512 bytes, ends in 0xAA55.
; Milestone 1: print "biome" and hang.

BITS 16
ORG 0x7C00

start:
    cli                     ; no interrupts while we set up segments/stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; stack grows down from just below our code
    sti

    mov si, msg
.print:
    lodsb                   ; al = [si], si++
    or  al, al
    jz  .done
    mov ah, 0x0E            ; BIOS teletype output
    xor bx, bx              ; page 0
    int 0x10
    jmp .print
.done:

halt:
    hlt
    jmp halt

msg db "biome", 13, 10, 0

    times 510-($-$$) db 0
    dw 0xAA55               ; boot signature
