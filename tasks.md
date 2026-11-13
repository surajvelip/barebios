# barebios tasks

Done: [x]  In progress: [/]  Blocked: [!]

## Milestone 1 — boot sector

- [x] Boot sector loads at 0x7C00, prints string, 0xAA55 signature
- [x] COM1 serial output (38400 8N1) mirrored with VGA
- [x] Makefile: `make`, `make run`, `make run-serial`
- [x] docs/ chapters (local-only, gitignored)

## Milestone 2 — interactive (next)

- [ ] Stage 2 loader: int 13h disk reads, jump past the 512-byte wall
- [ ] Serial command prompt: read line, parse, dispatch
- [ ] First commands: help, echo, dump <addr>, reboot
- [ ] int 16h keyboard input (VGA-side prompt too)

## Milestone 3 — programmable preboot

- [ ] Forth-style inner interpreter replaces ad-hoc parser
- [ ] Words for ports (in/out), memory (@/!), disk blocks
- [ ] Scriptable boot logic (read config, pick boot target)

## Core BIOS services

- [ ] IVT + own interrupt handlers (become a BIOS, not a bootloader)
- [ ] int 15h e820 memory map + extended memory size
- [ ] int 1Ah RTC read (time/date)
- [ ] POST-style boot banner: memory size, drive list, setup hint
- [ ] VGA mode control via int 10h (text UI groundwork)
- [ ] Proper disk image with MBR

## Owner features

- [ ] Text-file config on a FAT region (boot_order, serial baud, ...)
- [ ] Boot journal: flight-recorder region logging boot health events
- [ ] A/B boot failover: unhealthy slot A -> automatic slot B
- [ ] Watchdog arming at boot (OS must ping, hang -> reboot)
- [ ] Show-me-the-hash boot confirmation ("kernel changed, proceed?")
- [ ] Setup screen (classic text UI) for machines with a display
- [ ] Boot menu + priority: serial -> disk -> fail message

## Ambitious

- [ ] Boot a real kernel (bzImage or hobby kernel)
- [ ] coreboot payload build (real hardware: APU2 / ThinkPad X220)
- [ ] QEMU golden-output tests in CI (boot, assert serial output)
- [ ] RISC-V / ARM teaching ports (one codebase, three boot models)

## Community

- [ ] CONTRIBUTING.md + good first issue labels

## Won't do

- (empty — close items here with a reason)
