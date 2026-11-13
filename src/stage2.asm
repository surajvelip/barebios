; barebios stage 2 - interactive serial prompt.
; Loaded at 0000:7E00 by the boot sector. Runs a read-eval-print loop
; on COM1. This is the foundation that a Forth interpreter will
; replace later.

BITS 16
ORG 0x7E00

%define BUFLEN 64

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    call serial_init        ; harmless to re-init; keeps stage 2 standalone

    mov si, banner
    call serial_puts

repl:
    mov si, prompt
    call serial_puts
    call readline           ; fills linebuf, echoes keystrokes

    mov si, linebuf
    cmp byte [si], 0        ; empty line -> prompt again
    je  repl

    mov di, cmd_help
    call str_eq
    je  do_help

    mov si, linebuf
    mov di, cmd_version
    call str_eq
    je  do_version

    mov si, linebuf
    mov di, cmd_clear
    call str_eq
    je  do_clear

    mov si, linebuf
    mov di, cmd_reboot
    call str_eq
    je  do_reboot

    mov si, linebuf
    mov di, cmd_echo
    call str_prefix         ; "echo " prefix -> echo the rest
    je  do_echo

    mov si, linebuf
    mov di, cmd_dump
    call str_prefix         ; "dump " prefix -> hex dump
    je  do_dump

    mov si, msg_unknown
    call serial_puts
    jmp repl

do_help:
    mov si, msg_help
    call serial_puts
    jmp repl

do_version:
    mov si, msg_version
    call serial_puts
    jmp repl

do_clear:
    mov si, seq_clear       ; ANSI: clear screen, cursor home
    call serial_puts
    jmp repl

do_echo:
    mov si, linebuf+5       ; skip "echo "
    call serial_puts
    call newline
    jmp repl

do_dump:
    mov si, linebuf+5       ; skip "dump "
    call parse_hex          ; -> BX = value, CF set on error
    jc  dump_bad
    mov cx, 16
.dump_loop:
    mov al, [bx]
    call print_hex
    mov al, ' '
    call serial_putc
    inc bx
    loop .dump_loop
    call newline
    jmp repl
dump_bad:
    mov si, msg_dump_bad
    call serial_puts
    jmp repl

do_reboot:
    int 0x19                ; reload the boot sector: full restart

; --- helpers -----------------------------------------------------------

; readline: read a line from COM1 into linebuf (NUL-terminated).
; Handles backspace/DEL, echoes input, ignores overflow.
readline:
    mov di, linebuf         ; DI walks the buffer (16-bit mode can't index CX)
.next:
    call serial_getc
    cmp al, 13              ; CR = end of line
    je  .done
    cmp al, 8               ; BS
    je  .bs
    cmp al, 127             ; DEL
    je  .bs
    cmp di, linebuf+BUFLEN-1
    jae .next               ; buffer full: drop the key
    mov [di], al
    inc di
    call serial_putc        ; echo
    jmp .next
.bs:
    cmp di, linebuf
    jbe .next
    dec di
    mov byte [di], 0
    mov al, 8               ; erase on terminal: BS, space, BS
    call serial_putc
    mov al, ' '
    call serial_putc
    mov al, 8
    call serial_putc
    jmp .next
.done:
    mov byte [di], 0
    call newline
    ret

; str_eq: ZF=1 if NUL-terminated DS:SI and DS:DI are identical.
str_eq:
    push ax
.next:
    mov al, [di]
    cmp al, [si]
    jne .out
    or  al, al
    jz  .out                ; both hit NUL -> equal
    inc si
    inc di
    jmp .next
.out:
    pop ax
    ret

; str_prefix: ZF=1 if DS:SI starts with NUL-terminated DS:DI.
str_prefix:
    push ax
.next:
    mov al, [di]
    or  al, al
    jz  .eq                 ; prefix exhausted -> match
    cmp al, [si]
    jne .out
    inc si
    inc di
    jmp .next
.eq:
    xor al, al              ; set ZF
.out:
    pop ax
    ret

; parse_hex: parse up to 4 hex digits at DS:SI -> BX. CF on no digits.
parse_hex:
    push ax
    push cx
    xor bx, bx
    xor cx, cx              ; digit count
.next:
    lodsb
    call hex_digit          ; AL -> nibble in AL, CF if not hex
    jc  .done
    shl bx, 4
    or  bl, al
    inc cx
    cmp cx, 4
    jb  .next
.done:
    or  cx, cx              ; CF if zero digits consumed
    jz  .bad
    clc
    jmp .out
.bad:
    stc
.out:
    pop cx
    pop ax
    ret

; hex_digit: AL ASCII -> nibble value in AL, or CF if not hex.
hex_digit:
    cmp al, '0'
    jb  .bad
    cmp al, '9'
    jbe .num
    cmp al, 'A'
    jb  .bad
    cmp al, 'F'
    jbe .upper
    cmp al, 'a'
    jb  .bad
    cmp al, 'f'
    ja  .bad
    sub al, 'a'-10
    ret
.upper:
    sub al, 'A'-10
    ret
.num:
    sub al, '0'
    ret
.bad:
    stc
    ret

; print_hex: print AL as two hex digits on COM1.
print_hex:
    push ax
    push cx
    mov cl, al
    shr al, 4
    call .nibble
    mov al, cl
    and al, 0x0F
    call .nibble
    pop cx
    pop ax
    ret
.nibble:
    cmp al, 10
    jb  .num
    add al, 'A'-10-'0'
.num:
    add al, '0'
    call serial_putc
    ret

; newline: CR+LF on COM1.
newline:
    push ax
    mov al, 13
    call serial_putc
    mov al, 10
    call serial_putc
    pop ax
    ret

%include "serial.inc"

; --- data --------------------------------------------------------------

banner:      db 13, 10, "barebios stage 2 - type 'help'", 13, 10, 0
prompt:      db "barebios> ", 0
cmd_help:    db "help", 0
cmd_version: db "version", 0
cmd_clear:   db "clear", 0
cmd_reboot:  db "reboot", 0
cmd_echo:    db "echo ", 0
cmd_dump:    db "dump ", 0
msg_help:    db "help            this list", 13, 10
             db "version         firmware version", 13, 10
             db "echo <text>     print text", 13, 10
             db "dump <hexaddr>  16 bytes from low memory", 13, 10
             db "clear           clear the terminal", 13, 10
             db "reboot          restart via int 19h", 13, 10, 0
msg_version: db "barebios 0.2 (stage 2 REPL)", 13, 10, 0
msg_unknown: db "unknown command (try 'help')", 13, 10, 0
msg_dump_bad: db "usage: dump <hexaddr>", 13, 10, 0
seq_clear:   db 27, "[2J", 27, "[H", 0

linebuf:     times BUFLEN db 0

    times (4*512)-($-$$) db 0   ; pad to the sectors the boot sector loads
