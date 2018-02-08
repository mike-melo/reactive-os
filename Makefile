all: clean init build-kernel deploy

link-modules:
	cat src/std.mac src/header.asm  > build/header.asm

build-source: link-modules
	nasm -f bin -o build/header.bin build/header.asm

build-boot:
	nasm -f bin -o build/boot.bin src/boot.asm

link-kernel-and-boot:
	cat build/boot.bin build/header.bin > build/boot-kernel.bin

build-kernel: build-source build-boot link-kernel-and-boot
	cp build/base.img build/kernel.img
	dd if=build/boot-kernel.bin of=build/kernel.img conv=notrunc

deploy:
	bochs -qf bochsrc.txt

init: create-dirs basegen

create-dirs:
	mkdir build

basegen:
	dd if=/dev/zero of=base.img bs=512 count=2880
	mv base.img build/

clean:
	rm -rf build/
