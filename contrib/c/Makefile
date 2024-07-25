.PHONY: clean


potatoe: potatoe.c
	clang -O3 -o potatoe potatoe.c

bench: clean potatoe
	hyperfine -N "./potatoe"

clean:
	rm -rf potatoe
