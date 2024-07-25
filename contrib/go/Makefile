.PHONY: clean


potatoe: main.go
	go build -o potatoe main.go

bench: clean potatoe
	hyperfine -N "./potatoe"

clean:
	rm -rf potatoe
