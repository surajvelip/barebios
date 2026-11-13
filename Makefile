NASM   ?= nasm
QEMU   ?= qemu-system-i386
BUILD  := build
IMG    := $(BUILD)/biome.img

all: $(IMG)

$(IMG): src/boot.asm | $(BUILD)
	$(NASM) -f bin $< -o $@

$(BUILD):
	mkdir -p $(BUILD)

run: $(IMG)
	$(QEMU) -drive format=raw,file=$(IMG) -no-reboot

# headless run for CI/testing: serial output, exit on ctrl-a x
run-serial: $(IMG)
	$(QEMU) -drive format=raw,file=$(IMG) -nographic -serial mon:stdio

clean:
	rm -rf $(BUILD)

.PHONY: all run run-serial clean
