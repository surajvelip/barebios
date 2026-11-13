# biossom

A minimal, readable BIOS. Small enough for one person to read end to end.

## Goals

- Boot in QEMU from a raw floppy/hard disk image
- Implement classic BIOS interrupt services, step by step:
  - `int 10h` video (teletype already works)
  - `int 16h` keyboard
  - `int 13h` disk reads
- Eventually load and hand off to a real bootloader

## Build and run

Requires `nasm` and `qemu-system-i386` (or `qemu-system-x86_64`, set `QEMU=`).

```
make        # builds build/biossom.img
make run    # boots it in QEMU
```

You should see `biossom` printed on the emulated screen.

## Layout

```
src/boot.asm   the boot sector, loaded at 0000:7C00, ends in 0xAA55
Makefile       build + run targets
build/         generated images (gitignored)
```

## Roadmap

- [x] Boot sector prints a string
- [ ] Keyboard input via int 16h (echo typed keys)
- [ ] Real interrupt service routines + IVT entries
- [ ] Disk load: read sectors via int 13h, jump to a stage 2
- [ ] Memory map (int 15h / e820)
- [ ] Boot a small kernel or bootloader

## License

MIT
