decode: libcypher.so libcrack.so decode.o
	gcc -m32 decode.o -L. -Wl,-rpath='$$ORIGIN' -lcrack -lcypher -o decode

bypass.o: bypass.c
	gcc -m32 -c $< -o $@

cfix.o: cfix.S
	as -32 $< -o $@

libcrack.so: bypass.o cfix.o
	gcc -m32 --shared $^ -o $@

.PHONY: clean dist
clean:
	rm -f decode bypass.o cfix.o libcrack.so

dist:
	tar zcvf decode.tar.gz Makefile cfix.S bypass.c decode.o libcypher.so

