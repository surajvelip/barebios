NASM   ?= nasm
QEMU   ?= qemu-system-i386
BUILD  := build
IMG    := $(BUILD)/barebios.img

all: $(IMG)

$(BUILD)/boot.bin: src/boot.asm src/serial.inc | $(BUILD)
	$(NASM) -f bin -Isrc/ $< -o $@

$(BUILD)/stage2.bin: src/stage2.asm src/serial.inc | $(BUILD)
	$(NASM) -f bin -Isrc/ $< -o $@

$(IMG): $(BUILD)/boot.bin $(BUILD)/stage2.bin
	cat $^ > $@

$(BUILD):
	mkdir -p $(BUILD)

run: $(IMG)
	$(QEMU) -drive format=raw,file=$(IMG) -no-reboot

# headless run: serial (COM1) output only, in this terminal
run-serial: $(IMG)
	$(QEMU) -drive format=raw,file=$(IMG) -display none -serial stdio

clean:
	rm -rf $(BUILD)

.PHONY: all run run-serial clean
