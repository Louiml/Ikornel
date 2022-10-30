kernel_source_files := $(shell find src/kernel -name *.c)
kernel_object_files := $(patsubst src/kernel/%.c, build/%.o, $(kernel_source_files))
x86_64_c_source_files := $(shell find src/ -name *.c)
x86_64_c_object_files := $(patsubst src/%.c, build/%.o, $(x86_64_c_source_files))
x86_64_asm_source_files := $(shell find src/boot -name *.asm)
x86_64_asm_object_files := $(patsubst src/boot/%.asm, build/%.o, $(x86_64_asm_source_files))
x86_64_object_files := $(x86_64_c_object_files) $(x86_64_asm_object_files)
$(kernel_object_files): build/kernel/%.o : src/kernel/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src/intf -ffreestanding $(patsubst build/%.o, src/%.c, $@) -o $@
$(x86_64_c_object_files): build/%.o : src/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I src -ffreestanding $(patsubst build/%.o, src/%.c, $@) -o $@
$(x86_64_asm_object_files): build/%.o : src/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/%.o, src/%.asm, $@) -o $@
.PHONY: build-x86_64
build-x86_64: $(kernel_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64 && \
	x86_64-elf-ld -n -o dist/kernel.bin -T targets/linker.ld $(kernel_object_files) $(x86_64_object_files) && \
	cp kernel.bin targets/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/kernel.iso targets/iso
