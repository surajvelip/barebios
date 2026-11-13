# barebios

A minimal, readable BIOS. Small enough for one person to read end to end.

**Status: early days, work in progress.** It boots and answers on
serial. It is not a usable BIOS yet. Most of the roadmap is still
unchecked. `tasks.md` has the full, current list.

## What works today

- Boot sector loads at `0000:7C00`, prints to VGA and COM1 (38400 8N1)
- Stage 2 loader reads itself off disk via `int 13h`, past the
  512-byte wall
- Serial command prompt: `help`, `version`, `echo`, `dump <hexaddr>`,
  `clear`, `reboot`

## Build and run

Requires `nasm` and `qemu-system-i386` (or `qemu-system-x86_64`, set
`QEMU=`).

```
make            # builds build/barebios.img
make run        # boots it in QEMU with a display
make run-serial # headless, serial in this terminal
```

With `run-serial` you get a `barebios>` prompt. It understands CR as
Enter, like a real serial terminal. Scripts should send `\r`, not `\n`.

## Layout

```
src/boot.asm    the boot sector, loaded at 0000:7C00, ends in 0xAA55
src/stage2.asm  loaded past the 512-byte wall, hosts the REPL
src/serial.inc  COM1 helpers
tasks.md        the roadmap ledger
Makefile        build + run targets
build/          generated images (gitignored)
```

## Roadmap

- Done: boot sector, serial output, stage 2 loader, serial REPL
- Next: `int 16h` keyboard input, then a Forth-style command language
- Later: real interrupt services (IVT + handlers), e820 memory map,
  booting an actual kernel

`tasks.md` has the complete list, including the ambitious bits.

## License

MIT
