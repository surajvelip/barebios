NASM   ?= nasm
QEMU   ?= qemu-system-i386
BUILD  := build
IMG    := $(BUILD)/biossom.img

all: $(IMG)

$(IMG): src/boot.asm | $(BUILD)
	$(NASM) -f bin $< -o $@

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
