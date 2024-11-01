asm: asm_array.asm
	fasm asm_array.asm

c: asm array.c
	gcc array.c asm_array.o -o myprog

run: c myprog
	./myprog

clean:
	rm -f *.o