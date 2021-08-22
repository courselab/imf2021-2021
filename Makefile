decode: cypher_fix.o unlock.o decode.o libcypher.so
	gcc -m32 cypher_fix.o decode.o unlock.o -L. -lcypher -o decode.bin

unlock.o: unlock.c
	gcc -c -m32 $< -o unlock.o

cypher_fix.o: cypher_fix.S
	as -32 $< -o cypher_fix.o

run: decode
	LD_LIBRARY_PATH=. ./decode.bin $(args)

clean:
	rm -f decode.bin

tar:
	tar zcvf decode.tar.gz Makefile cypher_fix.S unlock.c decode.o libcypher.so

