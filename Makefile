all: clean init build-floppy-image deploy

link-macros-with-header:
	cat src/std.mac src/header.asm  > build/header.asm

build-header: link-macros-with-header
	nasm -f bin -o build/header.bin build/header.asm
	nasm -f macho -o build/header.o build/header.asm

build-kernel:
	(cd build/kernel-modules; clang -masm=intel -arch i386 -c ../../src/*.c)

link-kernel: build-kernel build-header
	ld build/header.o build/kernel-modules/*.o -U start -static -o build/kernel.o
	gobjcopy -O binary build/kernel.o build/kernel.bin

build-boot:
	nasm -f bin -o build/boot.bin src/boot.asm

link-header-and-boot:
	cat build/boot.bin build/header.bin > build/boot-header.bin

build-floppy-image: build-header build-boot link-header-and-boot
	cp build/base.img build/kernel.img
	dd if=build/boot-header.bin of=build/kernel.img conv=notrunc

deploy:
	bochs -qf bochsrc.txt

init: create-dirs create-base-floppy-image

create-dirs:
	mkdir -p build
	mkdir -p build/kernel-modules

create-base-floppy-image:
	dd if=/dev/zero of=base.img bs=512 count=2880
	mv base.img build/

clean:
	rm -rf build/
