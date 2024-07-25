.PHONY: clean


potatoe: potatoe.c
	clang -o potatoe potatoe.c

bench: clean potatoe
	hyperfine -N "./potatoe"

clean:
	rm -rf potatoe
