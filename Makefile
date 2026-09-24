BOCHHOME  ?= $(HOME)/bochs-2.8
BOCHSRC    = bochsrc.bxrc
BIN_DIR    = bin
DISK_DIR   = dsk
BUILD_DIR  = build
OBJ_DIR    = $(BUILD_DIR)/obj
BOOT_DIR   = boot
KERNEL_DIR = kernel
SHELL := /bin/bash

export BOCHHOME
export DISK_DIR

REQUIRES_DIRS  = $(BIN_DIR) $(DISK_DIR) $(BUILD_DIR) $(OBJ_DIR) $(BOOT_DIR) $(KERNEL_DIR)
REQUIRES_FILES = $(BOOT_DIR)/bootsect.asm $(BOOT_DIR)/tknl.asm $(KERNEL_DIR)/mproc.c

all: clean pcheck compile run

clean:
	rm -rf $(BIN_DIR) $(DISK_DIR) $(BUILD_DIR)
	mkdir -p $(BIN_DIR) $(DISK_DIR) $(BUILD_DIR) $(OBJ_DIR)
	echo -e "\e[32mclean: success\e[0m"

pcheck:
	for rdir in $(REQUIRES_DIRS); do \
		if [ ! -d $$rdir ]; then \
			echo -e "\e[31mpcheck: undefined directory: $$rdir\e[0m"; \
			exit 1; \
		fi; \
	done

	for rfile in $(REQUIRES_FILES); do \
		if [ ! -f $$rfile ]; then \
			echo -e "\e[31mpcheck: undefined file: $$rfile\e[0m"; \
			exit 1; \
		fi; \
	done

	echo -e "\e[32mpcheck: success\e[0m"

compile:
	echo -e "\e[34mcompile: compiling...\e[0m"
	nasm -f bin $(BOOT_DIR)/bootsect.asm -o $(BIN_DIR)/bootsect.bin -I. # boot section
	nasm -f bin $(BOOT_DIR)/tknl.asm -o $(BIN_DIR)/tknl.bin -I. # to kernel
	nasm -f elf32 $(KERNEL_DIR)/libcyon0.asm -o $(OBJ_DIR)/libcyon0.o -I.
	nasm -f elf32 $(KERNEL_DIR)/libcyon.asm -o $(OBJ_DIR)/libcyon.o -I.
	# main process
	clang -m32 -target i686-elf -ffreestanding -nostdlib -nostdinc -c -I. \
		$(KERNEL_DIR)/mproc.c -o $(OBJ_DIR)/mproc.o -Weverything -O3 \
		-Wno-reserved-macro-identifier -Wno-missing-prototypes
	ld -m elf_i386 -T linker.ld $(OBJ_DIR)/mproc.o \
		$(OBJ_DIR)/libcyon0.o $(OBJ_DIR)/libcyon.o -o $(OBJ_DIR)/kernel.elf
	echo -e "\e[34compile: elf-to-binary...\e[0m"
	objcopy -O binary $(OBJ_DIR)/kernel.elf $(BIN_DIR)/kernel.bin
	echo -e "\e[34mcompile: wrinting...\e[0m"
	dd if=/dev/zero of=$(DISK_DIR)/boot.img bs=512 count=2880
	dd if=/dev/zero of=$(DISK_DIR)/kernel.hdd bs=512 count=2880
	dd if=$(BIN_DIR)/bootsect.bin of=$(DISK_DIR)/boot.img bs=512 count=1 conv=notrunc
	dd if=$(BIN_DIR)/tknl.bin of=$(DISK_DIR)/boot.img bs=512 count=1 seek=1 conv=notrunc
	dd if=$(BIN_DIR)/kernel.bin of=$(DISK_DIR)/kernel.hdd bs=512 count=2 conv=notrunc,sync
	echo -e "\e[32mcompile: success\e[0m"

ncheck:
	# make pcheck
	@if ! xxd -s 510 -l 2 "$(DISK_DIR)/boot.img" | grep -qi "55aa"; then \
		echo -e "\e[33ncheck: mundefined: no bootable devices\e[0m"; \
		exit 1; \
	fi
	echo -e "\e[32mncheck: success\e[0m"

run:
	~/bochs-2.8/bochs -f bochsrc.bxrc

dbg:
	~/bochs-2.8/bochdbg -f bochsrc.bxrc
