# barebios tasks

Done: [x]  In progress: [/]  Blocked: [!]

## Milestone 1 — boot sector

- [x] Boot sector loads at 0x7C00, prints string, 0xAA55 signature
- [x] COM1 serial output (38400 8N1) mirrored with VGA
- [x] Makefile: `make`, `make run`, `make run-serial`

## Core BIOS services

- [ ] int 16h keyboard: echo typed keys to VGA + serial
- [ ] IVT + own interrupt handlers (become a BIOS, not a bootloader)
- [ ] int 13h disk reads (CHS/LBA), load and jump to a stage 2
- [ ] int 15h e820 memory map + extended memory size
- [ ] int 1Ah RTC read (time/date)
- [ ] POST-style boot banner: memory size, drive list, setup hint

## Setup / UX

- [ ] Setup screen (classic text UI), settings stored on disk sector
- [ ] Boot menu (F12-style device select)
- [ ] Boot priority: floppy -> HDD -> fail message

## Platform

- [ ] VGA mode control via int 10h (text UI groundwork)
- [ ] Proper disk image with MBR (El Torito/HDD boot path)
- [ ] Serial console as first-class output everywhere

## Ambitious

- [ ] Boot a real kernel (bzImage or hobby kernel)
- [ ] coreboot payload build
- [ ] QEMU golden-output tests in CI (boot, assert serial output)

## Community

- [ ] Annotated source walkthrough doc (the differentiator)
- [ ] CONTRIBUTING.md + good first issue labels

## Won't do

- (empty — close items here with a reason)
