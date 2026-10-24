.PHONY: clean bench

potatoe: potatoe.dart
	dart compile exe potatoe.dart -o potatoe

bench: clean potatoe
	hyperfine -N "./potatoe"

clean:
	rm -rf potatoe
