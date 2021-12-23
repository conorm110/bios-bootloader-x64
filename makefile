build:
	nasm boot16.asm -f bin -o bin/boot16.bin
	nasm boot64.asm -f bin -o bin/boot64.bin
	nasm kernel.asm -f bin -o bin/kernel.bin
	nasm footer.asm -f bin -o bin/footer.bin
	cat bin/boot16.bin bin/boot64.bin bin/kernel.bin bin/footer.bin > bin/os.bin

clean:
	rm -rf bin/
	mkdir bin

run:
	qemu-system-x86_64 bin/os.bin